import { useCallback, useEffect, useMemo, useState } from 'react';
import {
    computeHomeSummary,
    createTodayRitualIfMissing,
    getTodayRecord,
    loadStreakState,
    loadUserProfile,
    markTodayCompleted,
    markTodayRevealed,
    saveUserProfile,
} from '../lib/storage/dailyStateService';
import { useAuth } from './useAuth';

/**
 * useDailyState
 *
 * - loading: initial loading state
 * - todayRitual: full record for today or null
 * - summary: Home-friendly summary
 * - revealToday(): mark revealed
 * - completeToday(): mark completed (updates streak)
 * - refresh(): reloads everything
 *
 * Note: This hook keeps logic out of screens. Screens should call these methods.
 */
export function useDailyState(defaultSigns?: { western?: string; chinese?: string }) {
  const { autoSyncAfterMutation } = useAuth();
  const [loading, setLoading] = useState(true);
  const [todayRitual, setTodayRitual] = useState<Awaited<ReturnType<typeof getTodayRecord>>>(null);
  const [summary, setSummary] = useState<Awaited<ReturnType<typeof computeHomeSummary>> | null>(null);
  const [profile, setProfile] = useState<Awaited<ReturnType<typeof loadUserProfile>>>(null);
  const [streak, setStreak] = useState<Awaited<ReturnType<typeof loadStreakState>> | null>(null);

  const loadAll = useCallback(async () => {
    setLoading(true);
    try {
      const [user, rec, st, summ] = await Promise.all([
        loadUserProfile(),
        getTodayRecord(),
        loadStreakState(),
        computeHomeSummary(),
      ]);

      // if no record exists and defaultSigns provided, create one automatically
      let today = rec;
      if (!today && defaultSigns?.western && defaultSigns?.chinese) {
        today = await createTodayRitualIfMissing({
          westernSign: defaultSigns.western,
          chineseSign: defaultSigns.chinese,
        });
      }

      setProfile(user);
      setTodayRitual(today);
      setStreak(st);
      setSummary(summ);
    } catch (err) {
      console.error('useDailyState.loadAll error', err);
    } finally {
      setLoading(false);
    }
  }, [defaultSigns]);

  useEffect(() => {
    loadAll();
    // intentionally run once on mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const revealToday = useCallback(async () => {
    try {
      const rec = await markTodayRevealed();
      if (rec) {
        // refresh summary and record
        const summ = await computeHomeSummary();
        setTodayRitual(rec);
        setSummary(summ);
      }
    } catch (err) {
      console.error('revealToday error', err);
    }
  }, []);

  const completeToday = useCallback(async () => {
    try {
      const result = await markTodayCompleted();
      if (result.record) setTodayRitual(result.record);
      setStreak(result.streak);
      const summ = await computeHomeSummary();
      setSummary(summ);
      autoSyncAfterMutation();
      return result;
    } catch (err) {
      console.error('completeToday error', err);
      return undefined;
    }
  }, [autoSyncAfterMutation]);

  const refresh = useCallback(async () => {
    await loadAll();
  }, [loadAll]);

  const updateProfile = useCallback(async (next: NonNullable<Awaited<ReturnType<typeof loadUserProfile>>>) => {
    await saveUserProfile(next);
    setProfile(next);
    autoSyncAfterMutation();
  }, [autoSyncAfterMutation]);

  const api = useMemo(
    () => ({
      loading,
      profile,
      todayRitual,
      summary,
      streak,
      revealToday,
      completeToday,
      refresh,
      updateProfile,
    }),
    [loading, profile, todayRitual, summary, streak, revealToday, completeToday, refresh, updateProfile]
  );

  return api;
}

export type UseDailyStateReturn = ReturnType<typeof useDailyState>;
