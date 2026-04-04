import { useFocusEffect } from 'expo-router';
import { useCallback, useEffect, useMemo, useState } from 'react';
import {
    addMilestoneRecord,
    claimSponsorVideoReward,
    clearRewardProgress,
    consumeSwipeAllowance,
    getSwipeAllowance,
    hasActiveGoDeeperPass,
    loadMilestoneHistory,
    loadRewardActivities,
    loadRewardPerks,
    loadRewardsWallet,
    redeemExtraSwipesPack,
    redeemGoDeeperPass,
} from '../lib/storage/rewardsService';
import type { MilestoneRecord, RewardActivity, RewardsPerks, RewardsWallet, SwipeAllowance } from '../types/reward';
import { useAuth } from './useAuth';

const DEFAULT_WALLET: RewardsWallet = {
  balance: 0,
  lifetimeEarned: 0,
  adWatchCountToday: 0,
  claimedMilestones: [],
};

const DEFAULT_PERKS: RewardsPerks = {
  extraSwipesRemaining: 0,
  swipeUsageCount: 0,
};

const DEFAULT_ALLOWANCE: SwipeAllowance = {
  used: 0,
  baseLeft: 3,
  bonusLeft: 0,
  totalLeft: 3,
  totalLimit: 3,
};

export function useRewards() {
  const { autoSyncAfterMutation } = useAuth();
  const [loading, setLoading] = useState(true);
  const [wallet, setWallet] = useState<RewardsWallet>(DEFAULT_WALLET);
  const [perks, setPerks] = useState<RewardsPerks>(DEFAULT_PERKS);
  const [swipeAllowance, setSwipeAllowance] = useState<SwipeAllowance>(DEFAULT_ALLOWANCE);
  const [activities, setActivities] = useState<RewardActivity[]>([]);
  const [history, setHistory] = useState<MilestoneRecord[]>([]);

  const prependActivity = useCallback((activity?: RewardActivity) => {
    if (!activity) return;
    setActivities((prev) => [activity, ...prev].slice(0, 120));
  }, []);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [nextHistory, nextWallet, nextActivities, nextPerks, nextSwipeAllowance] = await Promise.all([
        loadMilestoneHistory(),
        loadRewardsWallet(),
        loadRewardActivities(),
        loadRewardPerks(),
        getSwipeAllowance(),
      ]);
      setHistory(nextHistory);
      setWallet(nextWallet);
      setActivities(nextActivities);
      setPerks(nextPerks);
      setSwipeAllowance(nextSwipeAllowance);
    } catch (err) {
      console.error('useRewards.load error', err);
      setHistory([]);
      setWallet(DEFAULT_WALLET);
      setActivities([]);
      setPerks(DEFAULT_PERKS);
      setSwipeAllowance(DEFAULT_ALLOWANCE);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load])
  );

  const add = useCallback(async (params: { streak: number; label?: string; date?: Date | string }) => {
    try {
      const rec = await addMilestoneRecord(params);
      setHistory((prev) => {
        const found = prev.find((item) => item.id === rec.id);
        if (found) return prev;
        const next = [rec, ...prev];
        if (next.length > 200) next.length = 200;
        return next;
      });
      return rec;
    } catch (err) {
      console.error('useRewards.add error', err);
      throw err;
    }
  }, []);

  const clear = useCallback(async () => {
    try {
      await clearRewardProgress();
      setHistory([]);
      setWallet(DEFAULT_WALLET);
      setActivities([]);
      setPerks(DEFAULT_PERKS);
      setSwipeAllowance(DEFAULT_ALLOWANCE);
      autoSyncAfterMutation();
    } catch (err) {
      console.error('useRewards.clear error', err);
    }
  }, [autoSyncAfterMutation]);

  const watchSponsorSpotlight = useCallback(async () => {
    const result = await claimSponsorVideoReward();
    setWallet(result.wallet);
    prependActivity(result.activity);
    if (result.awarded) {
      autoSyncAfterMutation();
    }
    return result;
  }, [autoSyncAfterMutation, prependActivity]);

  const unlockGoDeeperPass = useCallback(async () => {
    const result = await redeemGoDeeperPass();
    setWallet(result.wallet);
    setPerks(result.perks);
    prependActivity(result.activity);
    if (result.success) {
      autoSyncAfterMutation();
    }
    return result;
  }, [autoSyncAfterMutation, prependActivity]);

  const unlockExtraSwipes = useCallback(async () => {
    const result = await redeemExtraSwipesPack();
    setWallet(result.wallet);
    setPerks(result.perks);
    prependActivity(result.activity);
    setSwipeAllowance(await getSwipeAllowance());
    if (result.success) {
      autoSyncAfterMutation();
    }
    return result;
  }, [autoSyncAfterMutation, prependActivity]);

  const consumeSwipe = useCallback(async () => {
    const nextAllowance = await consumeSwipeAllowance();
    setSwipeAllowance(nextAllowance);
    setPerks(await loadRewardPerks());
    autoSyncAfterMutation();
    return nextAllowance;
  }, [autoSyncAfterMutation]);

  const hasGoDeeperPass = useMemo(() => hasActiveGoDeeperPass(perks), [perks]);

  return {
    loading,
    history,
    wallet,
    perks,
    swipeAllowance,
    activities,
    hasGoDeeperPass,
    add,
    load,
    clear,
    consumeSwipe,
    watchSponsorSpotlight,
    unlockGoDeeperPass,
    unlockExtraSwipes,
  };
}

export type UseRewardsReturn = ReturnType<typeof useRewards>;
