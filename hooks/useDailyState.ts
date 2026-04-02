// filepath: /Users/christianrecio/zodian/hooks/useDailyState.ts
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
import type { DailyRitualRecord, DailyStateSummary, StreakState, UserProfile } from '../types/dailyState';

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
  const [loading, setLoading] = useState(true);
  const [todayRitual, setTodayRitual] = useState<DailyRitualRecord | null>(null);
  const [summary, setSummary] = useState<DailyStateSummary | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [streak, setStreak] = useState<StreakState | null>(null);

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
      const { record, streak: newStreak } = await markTodayCompleted();
      // update local state
      if (record) setTodayRitual(record);
      setStreak(newStreak);
      const summ = await computeHomeSummary();
      setSummary(summ);
    } catch (err) {
      console.error('completeToday error', err);
    }
  }, []);

  const refresh = useCallback(async () => {
    await loadAll();
  }, [loadAll]);

  const updateProfile = useCallback(async (next: UserProfile) => {
    await saveUserProfile(next);
    setProfile(next);
  }, []);

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
