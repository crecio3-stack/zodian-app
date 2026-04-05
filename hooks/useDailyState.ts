import { useCallback, useEffect, useMemo, useState } from 'react';
import { EVENTS, trackAppEvent } from '../lib/analytics/analytics';
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
  const [lastCompletionOutcome, setLastCompletionOutcome] = useState<{
    restarted: boolean;
    previousStreak: number;
    currentStreak: number;
    previousLastCompletedDate?: string;
    completedOn: string;
  } | null>(null);

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
      const previousStreak = await loadStreakState();
      const result = await markTodayCompleted();
      if (result.record) setTodayRitual(result.record);
      setStreak(result.streak);
      const summ = await computeHomeSummary();
      setSummary(summ);

      const todayKey = result.record?.date ?? summ.todayDate;
      const previousLastCompletedDate = previousStreak.lastCompletedDate;
      const previousDate = previousLastCompletedDate ? new Date(`${previousLastCompletedDate}T00:00:00`) : null;
      const yesterday = new Date(`${todayKey}T00:00:00`);
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayKey = `${yesterday.getFullYear()}-${`${yesterday.getMonth() + 1}`.padStart(2, '0')}-${`${yesterday.getDate()}`.padStart(2, '0')}`;

      const restarted =
        Boolean(previousDate) &&
        previousLastCompletedDate !== yesterdayKey &&
        previousLastCompletedDate !== todayKey &&
        result.streak.currentStreak === 1;

      if (
        restarted
      ) {
        trackAppEvent(EVENTS.STREAK_RESTARTED, {
          previousStreak: previousStreak.currentStreak,
          previousLastCompletedDate,
          resumedOn: todayKey,
        }).catch(() => {});
      }

      const completionOutcome = {
        restarted,
        previousStreak: previousStreak.currentStreak,
        currentStreak: result.streak.currentStreak,
        previousLastCompletedDate,
        completedOn: todayKey,
      };

      setLastCompletionOutcome(completionOutcome);

      autoSyncAfterMutation();
      return {
        ...result,
        completionOutcome,
      };
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
      lastCompletionOutcome,
      revealToday,
      completeToday,
      refresh,
      updateProfile,
    }),
    [loading, profile, todayRitual, summary, streak, lastCompletionOutcome, revealToday, completeToday, refresh, updateProfile]
  );

  return api;
}

export type UseDailyStateReturn = ReturnType<typeof useDailyState>;
