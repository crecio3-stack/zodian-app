import AsyncStorage from '@react-native-async-storage/async-storage';
import type {
    MilestoneRecord,
    RewardActivity,
    RewardActivityKind,
    RewardActivitySource,
    RewardGrantResult,
    RewardSpendResult,
    RewardsPerks,
    RewardsWallet,
    SwipeAllowance,
} from '../../types/reward';

const KEYS = {
  MILESTONES: 'zodian:milestones:v1',
  WALLET: 'zodian:rewardsWallet:v1',
  ACTIVITIES: 'zodian:rewardActivities:v1',
  PERKS: 'zodian:rewardPerks:v1',
};

export const STAR_DUST = {
  currencyName: 'Star Dust',
  baseDailySwipes: 3,
  dailyRitual: 15,
  shareRitual: 8,
  sponsorVideo: 12,
  sponsorDailyLimit: 2,
  extraSwipePackSize: 10,
  shop: {
    goDeeperPass: 45,
    extraSwipesPack: 25,
  },
  milestoneBonus: {
    3: 10,
    7: 25,
    14: 40,
    30: 80,
  } as Record<number, number>,
};

const DEFAULT_WALLET: RewardsWallet = {
  balance: 0,
  lifetimeEarned: 0,
  adWatchCountToday: 0,
  claimedMilestones: [],
  updatedAt: undefined,
};

const DEFAULT_PERKS: RewardsPerks = {
  extraSwipesRemaining: 0,
  swipeUsageCount: 0,
  updatedAt: undefined,
};

const nowIso = () => new Date().toISOString();
const nowMs = () => Date.now();

function toDateKey(d: Date | string = new Date()): string {
  const date = typeof d === 'string' ? new Date(d) : d;
  const yyyy = date.getFullYear();
  const mm = `${date.getMonth() + 1}`.padStart(2, '0');
  const dd = `${date.getDate()}`.padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

function safeParse<T>(raw: string | null, fallback: T): T {
  if (!raw) return fallback;
  try {
    return JSON.parse(raw) as T;
  } catch (err) {
    console.warn('rewardsService.safeParse failed', err);
    return fallback;
  }
}

function trackEvent(name: string, payload?: Record<string, any>) {
  try {
    // @ts-ignore
    if (globalThis?.analytics?.track) {
      // @ts-ignore
      globalThis.analytics.track(name, payload);
    } else {
      console.debug(`[analytics] ${name}`, payload ?? {});
    }
  } catch {}
}

function createActivity(input: {
  amount: number;
  kind: RewardActivityKind;
  source: RewardActivitySource;
  title: string;
  detail: string;
  dateKey: string;
}): RewardActivity {
  return {
    id: `${Date.now()}-${Math.floor(Math.random() * 10000)}`,
    amount: input.amount,
    kind: input.kind,
    source: input.source,
    title: input.title,
    detail: input.detail,
    dateKey: input.dateKey,
    createdAt: nowIso(),
  };
}

function normalizePerks(perks: RewardsPerks, dateKey: string, now = nowMs()): RewardsPerks {
  const next: RewardsPerks = {
    ...DEFAULT_PERKS,
    ...perks,
  };

  if (!next.goDeeperPassExpiresAt || next.goDeeperPassExpiresAt <= now) {
    next.goDeeperPassExpiresAt = undefined;
  }

  if (next.extraSwipesDate !== dateKey) {
    next.extraSwipesDate = undefined;
    next.extraSwipesRemaining = 0;
  }

  if (next.swipeUsageDate !== dateKey) {
    next.swipeUsageDate = undefined;
    next.swipeUsageCount = 0;
  }

  return next;
}

function computeSwipeAllowance(perks: RewardsPerks): SwipeAllowance {
  const used = perks.swipeUsageCount ?? 0;
  const baseLeft = Math.max(0, STAR_DUST.baseDailySwipes - used);
  const bonusLeft = perks.extraSwipesRemaining ?? 0;
  const totalLeft = baseLeft + bonusLeft;

  return {
    used,
    baseLeft,
    bonusLeft,
    totalLeft,
    totalLimit: used + totalLeft,
  };
}

export function hasActiveGoDeeperPass(perks: RewardsPerks | null | undefined, now = nowMs()): boolean {
  return Boolean(perks?.goDeeperPassExpiresAt && perks.goDeeperPassExpiresAt > now);
}

export async function loadMilestoneHistory(): Promise<MilestoneRecord[]> {
  try {
    const raw = await AsyncStorage.getItem(KEYS.MILESTONES);
    return safeParse<MilestoneRecord[]>(raw, []);
  } catch (err) {
    console.error('loadMilestoneHistory error', err);
    return [];
  }
}

export async function loadRewardsWallet(): Promise<RewardsWallet> {
  try {
    const raw = await AsyncStorage.getItem(KEYS.WALLET);
    const parsed = safeParse<RewardsWallet>(raw, DEFAULT_WALLET);
    return {
      ...DEFAULT_WALLET,
      ...parsed,
      claimedMilestones: Array.isArray(parsed.claimedMilestones) ? parsed.claimedMilestones : [],
    };
  } catch (err) {
    console.error('loadRewardsWallet error', err);
    return DEFAULT_WALLET;
  }
}

async function saveRewardsWallet(wallet: RewardsWallet): Promise<RewardsWallet> {
  const next = { ...wallet, updatedAt: nowIso() };
  await AsyncStorage.setItem(KEYS.WALLET, JSON.stringify(next));
  return next;
}

export async function loadRewardActivities(): Promise<RewardActivity[]> {
  try {
    const raw = await AsyncStorage.getItem(KEYS.ACTIVITIES);
    return safeParse<RewardActivity[]>(raw, []);
  } catch (err) {
    console.error('loadRewardActivities error', err);
    return [];
  }
}

async function saveRewardActivities(activities: RewardActivity[]): Promise<void> {
  await AsyncStorage.setItem(KEYS.ACTIVITIES, JSON.stringify(activities));
}

async function prependRewardActivity(activity: RewardActivity): Promise<void> {
  const activities = await loadRewardActivities();
  const next = [activity, ...activities];
  if (next.length > 120) next.length = 120;
  await saveRewardActivities(next);
}

export async function loadRewardPerks(date?: Date | string): Promise<RewardsPerks> {
  const dateKey = toDateKey(date);

  try {
    const raw = await AsyncStorage.getItem(KEYS.PERKS);
    const parsed = safeParse<RewardsPerks>(raw, DEFAULT_PERKS);
    const normalized = normalizePerks(parsed, dateKey);
    if (JSON.stringify(parsed) !== JSON.stringify(normalized)) {
      await AsyncStorage.setItem(KEYS.PERKS, JSON.stringify({ ...normalized, updatedAt: nowIso() }));
    }
    return normalized;
  } catch (err) {
    console.error('loadRewardPerks error', err);
    return DEFAULT_PERKS;
  }
}

async function saveRewardPerks(perks: RewardsPerks): Promise<RewardsPerks> {
  const next = { ...perks, updatedAt: nowIso() };
  await AsyncStorage.setItem(KEYS.PERKS, JSON.stringify(next));
  return next;
}

async function grantStarDust(input: {
  amount: number;
  source: RewardActivitySource;
  title: string;
  detail: string;
  date?: Date | string;
  mutateWallet?: (wallet: RewardsWallet, dateKey: string) => RewardsWallet;
}): Promise<RewardGrantResult> {
  const wallet = await loadRewardsWallet();
  const dateKey = toDateKey(input.date);
  const baseWallet = input.mutateWallet?.(wallet, dateKey) ?? wallet;
  const updatedWallet = await saveRewardsWallet({
    ...baseWallet,
    balance: baseWallet.balance + input.amount,
    lifetimeEarned: baseWallet.lifetimeEarned + input.amount,
  });

  const activity = createActivity({
    amount: input.amount,
    kind: 'earn',
    source: input.source,
    title: input.title,
    detail: input.detail,
    dateKey,
  });

  await prependRewardActivity(activity);
  trackEvent('rewards.star_dust_earned', {
    source: input.source,
    amount: input.amount,
    balance: updatedWallet.balance,
  });

  return {
    awarded: true,
    amount: input.amount,
    wallet: updatedWallet,
    activity,
  };
}

async function spendStarDust(input: {
  amount: number;
  source: RewardActivitySource;
  title: string;
  detail: string;
  date?: Date | string;
  mutatePerks?: (perks: RewardsPerks, dateKey: string) => RewardsPerks;
}): Promise<RewardSpendResult> {
  const wallet = await loadRewardsWallet();
  const dateKey = toDateKey(input.date);
  const perks = await loadRewardPerks(dateKey);

  if (wallet.balance < input.amount) {
    return { success: false, amount: input.amount, reason: 'insufficient_balance', wallet, perks };
  }

  const nextPerks = input.mutatePerks ? input.mutatePerks(perks, dateKey) : perks;
  const updatedWallet = await saveRewardsWallet({
    ...wallet,
    balance: wallet.balance - input.amount,
  });
  const savedPerks = await saveRewardPerks(nextPerks);

  const activity = createActivity({
    amount: input.amount,
    kind: 'spend',
    source: input.source,
    title: input.title,
    detail: input.detail,
    dateKey,
  });

  await prependRewardActivity(activity);
  trackEvent('rewards.star_dust_spent', {
    source: input.source,
    amount: input.amount,
    balance: updatedWallet.balance,
  });

  return {
    success: true,
    amount: input.amount,
    wallet: updatedWallet,
    perks: savedPerks,
    activity,
  };
}

export async function claimDailyCompletionReward(date?: Date | string): Promise<RewardGrantResult> {
  const wallet = await loadRewardsWallet();
  const dateKey = toDateKey(date);

  if (wallet.lastDailyCompletionAwardedDate === dateKey) {
    return { awarded: false, amount: 0, reason: 'already_claimed', wallet };
  }

  return grantStarDust({
    amount: STAR_DUST.dailyRitual,
    source: 'daily-ritual',
    title: 'Daily ritual completed',
    detail: `You anchored today's practice and collected ${STAR_DUST.dailyRitual} ${STAR_DUST.currencyName}.`,
    date,
    mutateWallet: (current, earnedDate) => ({
      ...current,
      lastDailyCompletionAwardedDate: earnedDate,
    }),
  });
}

export async function claimShareReward(date?: Date | string): Promise<RewardGrantResult> {
  const wallet = await loadRewardsWallet();
  const dateKey = toDateKey(date);

  if (wallet.lastSharedDate === dateKey) {
    return { awarded: false, amount: 0, reason: 'already_claimed', wallet };
  }

  return grantStarDust({
    amount: STAR_DUST.shareRitual,
    source: 'share-ritual',
    title: 'Reading shared',
    detail: `Sharing today's reading earns ${STAR_DUST.shareRitual} ${STAR_DUST.currencyName} once per day.`,
    date,
    mutateWallet: (current, earnedDate) => ({
      ...current,
      lastSharedDate: earnedDate,
    }),
  });
}

export async function claimSponsorVideoReward(date?: Date | string): Promise<RewardGrantResult> {
  const wallet = await loadRewardsWallet();
  const dateKey = toDateKey(date);
  const isSameDay = wallet.adWatchDate === dateKey;
  const watchCount = isSameDay ? wallet.adWatchCountToday : 0;

  if (watchCount >= STAR_DUST.sponsorDailyLimit) {
    return { awarded: false, amount: 0, reason: 'limit_reached', wallet };
  }

  const remainingAfterClaim = STAR_DUST.sponsorDailyLimit - (watchCount + 1);

  return grantStarDust({
    amount: STAR_DUST.sponsorVideo,
    source: 'watch-ad',
    title: 'Sponsor spotlight watched',
    detail: `A sponsor spotlight adds ${STAR_DUST.sponsorVideo} ${STAR_DUST.currencyName}. ${remainingAfterClaim} watch${remainingAfterClaim === 1 ? '' : 'es'} left today.`,
    date,
    mutateWallet: (current, earnedDate) => ({
      ...current,
      adWatchDate: earnedDate,
      adWatchCountToday: (current.adWatchDate === earnedDate ? current.adWatchCountToday : 0) + 1,
    }),
  });
}

export async function claimStreakMilestoneReward(streak: number, date?: Date | string): Promise<RewardGrantResult> {
  const wallet = await loadRewardsWallet();
  const bonus = STAR_DUST.milestoneBonus[streak];

  if (!bonus) {
    return { awarded: false, amount: 0, reason: 'not_eligible', wallet };
  }

  if (wallet.claimedMilestones.includes(streak)) {
    return { awarded: false, amount: 0, reason: 'already_claimed', wallet };
  }

  await addMilestoneRecord({ streak, label: `${streak}-day`, date });

  return grantStarDust({
    amount: bonus,
    source: 'streak-milestone',
    title: `${streak}-day streak bonus`,
    detail: `Your streak milestone unlocked ${bonus} ${STAR_DUST.currencyName}.`,
    date,
    mutateWallet: (current) => ({
      ...current,
      claimedMilestones: [...current.claimedMilestones, streak].sort((a, b) => a - b),
    }),
  });
}

export async function redeemGoDeeperPass(date?: Date | string): Promise<RewardSpendResult> {
  const perks = await loadRewardPerks(date);
  if (hasActiveGoDeeperPass(perks)) {
    return {
      success: false,
      amount: STAR_DUST.shop.goDeeperPass,
      reason: 'already_active',
      wallet: await loadRewardsWallet(),
      perks,
    };
  }

  const expiresAt = nowMs() + 24 * 60 * 60 * 1000;
  return spendStarDust({
    amount: STAR_DUST.shop.goDeeperPass,
    source: 'redeem-go-deeper',
    title: 'Go Deeper Pass unlocked',
    detail: `Unlocked 24 hours of Go Deeper access for ${STAR_DUST.shop.goDeeperPass} ${STAR_DUST.currencyName}.`,
    date,
    mutatePerks: (current) => ({
      ...current,
      goDeeperPassExpiresAt: expiresAt,
    }),
  });
}

export async function redeemExtraSwipesPack(date?: Date | string): Promise<RewardSpendResult> {
  return spendStarDust({
    amount: STAR_DUST.shop.extraSwipesPack,
    source: 'redeem-extra-swipes',
    title: 'Extra swipes unlocked',
    detail: `Added ${STAR_DUST.extraSwipePackSize} extra swipes for today for ${STAR_DUST.shop.extraSwipesPack} ${STAR_DUST.currencyName}.`,
    date,
    mutatePerks: (current, dateKey) => ({
      ...current,
      extraSwipesDate: dateKey,
      extraSwipesRemaining: (current.extraSwipesDate === dateKey ? current.extraSwipesRemaining : 0) + STAR_DUST.extraSwipePackSize,
    }),
  });
}

export async function getSwipeAllowance(date?: Date | string): Promise<SwipeAllowance> {
  const perks = await loadRewardPerks(date);
  return computeSwipeAllowance(perks);
}

export async function consumeSwipeAllowance(date?: Date | string): Promise<SwipeAllowance> {
  const dateKey = toDateKey(date);
  const perks = await loadRewardPerks(dateKey);
  const allowance = computeSwipeAllowance(perks);

  if (allowance.totalLeft <= 0) {
    return allowance;
  }

  const nextPerks: RewardsPerks = {
    ...perks,
    swipeUsageDate: dateKey,
    swipeUsageCount: allowance.used + 1,
    extraSwipesRemaining:
      allowance.used >= STAR_DUST.baseDailySwipes ? Math.max(0, allowance.bonusLeft - 1) : allowance.bonusLeft,
  };

  await saveRewardPerks(nextPerks);
  return computeSwipeAllowance(nextPerks);
}

export async function syncRewardsForCompletedRitual(input: {
  streak: number;
  date?: Date | string;
}): Promise<RewardGrantResult[]> {
  const rewards = await Promise.all([
    claimDailyCompletionReward(input.date),
    claimStreakMilestoneReward(input.streak, input.date),
  ]);

  return rewards.filter((reward) => reward.awarded);
}

export async function addMilestoneRecord(input: {
  streak: number;
  label?: string;
  date?: Date | string;
}): Promise<MilestoneRecord> {
  try {
    const list = await loadMilestoneHistory();
    const dateKey = toDateKey(input.date);
    const createdAt = nowIso();
    const id = `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
    const rec: MilestoneRecord = {
      id,
      streak: input.streak,
      label: input.label ?? `${input.streak}-day`,
      dateKey,
      createdAt,
    };

    const duplicate = list.find((item) => item.streak === rec.streak && item.dateKey === rec.dateKey);
    if (duplicate) {
      return duplicate;
    }

    list.unshift(rec);
    if (list.length > 200) list.length = 200;
    await AsyncStorage.setItem(KEYS.MILESTONES, JSON.stringify(list));
    trackEvent('rewards.milestone_earned', { streak: rec.streak, id: rec.id });
    return rec;
  } catch (err) {
    console.error('addMilestoneRecord error', err);
    throw err;
  }
}

export async function clearMilestoneHistory(): Promise<void> {
  try {
    await AsyncStorage.removeItem(KEYS.MILESTONES);
    trackEvent('rewards.history_cleared');
  } catch (err) {
    console.error('clearMilestoneHistory error', err);
  }
}

export async function clearRewardProgress(): Promise<void> {
  try {
    await AsyncStorage.multiRemove([KEYS.MILESTONES, KEYS.WALLET, KEYS.ACTIVITIES, KEYS.PERKS]);
    trackEvent('rewards.progress_cleared');
  } catch (err) {
    console.error('clearRewardProgress error', err);
  }
}
