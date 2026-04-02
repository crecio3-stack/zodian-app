import AsyncStorage from '@react-native-async-storage/async-storage';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { DAILY_FATES, FateArchetype } from '../data/dailyFates';

type DailyFateState = {
  dateKey: string;
  revealed: boolean;
  streak: number;
};

type SignInput = {
  westernSign: string;
  chineseSign: string;
};

const STORAGE_KEY = 'zodian_daily_fate_state_v1';

function getDateKey(date = new Date()) {
  const year = date.getFullYear();
  const month = `${date.getMonth() + 1}`.padStart(2, '0');
  const day = `${date.getDate()}`.padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function getYesterdayDateKey(date = new Date()) {
  const copy = new Date(date);
  copy.setDate(copy.getDate() - 1);
  return getDateKey(copy);
}

function hashString(input: string) {
  let hash = 0;

  for (let i = 0; i < input.length; i += 1) {
    hash = (hash << 5) - hash + input.charCodeAt(i);
    hash |= 0;
  }

  return Math.abs(hash);
}

function resolveDailyFate({
  westernSign,
  chineseSign,
  dateKey,
}: SignInput & { dateKey: string }): FateArchetype {
  const seed = `${westernSign}-${chineseSign}-${dateKey}`;
  const index = hashString(seed) % DAILY_FATES.length;
  return DAILY_FATES[index];
}

export function useDailyFate({ westernSign, chineseSign }: SignInput) {
  const todayKey = useMemo(() => getDateKey(), []);
  const [loading, setLoading] = useState(true);
  const [revealed, setRevealed] = useState(false);
  const [streak, setStreak] = useState(1);

  const fate = useMemo(
    () =>
      resolveDailyFate({
        westernSign,
        chineseSign,
        dateKey: todayKey,
      }),
    [westernSign, chineseSign, todayKey]
  );

  useEffect(() => {
    let mounted = true;

    async function loadState() {
      try {
        const raw = await AsyncStorage.getItem(STORAGE_KEY);
        const parsed: DailyFateState | null = raw ? JSON.parse(raw) : null;

        if (!mounted) return;

        // No stored state: initialize for today (counts as an open)
        if (!parsed) {
          const initState: DailyFateState = { dateKey: todayKey, revealed: false, streak: 1 };
          try { await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(initState)); } catch {}
          setRevealed(false);
          setStreak(1);
          setLoading(false);
          return;
        }

        // If stored state is for today, use it
        if (parsed.dateKey === todayKey) {
          setRevealed(parsed.revealed);
          setStreak(parsed.streak || 1);
          setLoading(false);
          return;
        }

        // New day: treat this open as today's visit, and persist updated streak
        setRevealed(false);

        let nextStreak = 1;
        if (parsed.dateKey === getYesterdayDateKey()) {
          nextStreak = (parsed.streak || 1) + 1;
        } else {
          nextStreak = 1;
        }

        const todayState: DailyFateState = { dateKey: todayKey, revealed: false, streak: nextStreak };
        try { await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(todayState)); } catch {}

        setStreak(nextStreak);
        setLoading(false);
      } catch {
        if (!mounted) return;
        setRevealed(false);
        setStreak(1);
        setLoading(false);
      }
    }

    loadState();

    return () => {
      mounted = false;
    };
  }, [todayKey]);

  const reveal = useCallback(async () => {
    const nextState: DailyFateState = {
      dateKey: todayKey,
      revealed: true,
      streak,
    };

    setRevealed(true);
    try { await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(nextState)); } catch {}
  }, [todayKey, streak]);

  const markOpened = useCallback(async () => {
    try {
      const raw = await AsyncStorage.getItem(STORAGE_KEY);
      const parsed: DailyFateState | null = raw ? JSON.parse(raw) : null;
      if (parsed && parsed.dateKey === todayKey) {
        // already recorded today
        return;
      }

      let nextStreak = 1;
      if (parsed && parsed.dateKey === getYesterdayDateKey()) {
        nextStreak = (parsed.streak || 1) + 1;
      }

      const todayState: DailyFateState = { dateKey: todayKey, revealed: false, streak: nextStreak };
      await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(todayState));
      setRevealed(false);
      setStreak(nextStreak);
    } catch {}
  }, [todayKey]);

  return {
    loading,
    revealed,
    streak,
    todayKey,
    fate,
    reveal,
    markOpened,
  };
}
