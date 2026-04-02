// filepath: /Users/christianrecio/zodian/hooks/useRewards.ts
import { useCallback, useEffect, useState } from 'react';
import { addMilestoneRecord, clearMilestoneHistory, loadMilestoneHistory } from '../lib/storage/rewardsService';
import type { MilestoneRecord } from '../types/reward';

export function useRewards() {
  const [loading, setLoading] = useState(true);
  const [history, setHistory] = useState<MilestoneRecord[]>([]);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const h = await loadMilestoneHistory();
      setHistory(h);
    } catch (err) {
      console.error('useRewards.load error', err);
      setHistory([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const add = useCallback(
    async (params: { streak: number; label?: string; date?: Date | string }) => {
      try {
        const rec = await addMilestoneRecord(params);
        // refresh list (fast local update)
        setHistory((prev) => {
          const found = prev.find((p) => p.id === rec.id);
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
    },
    []
  );

  const clear = useCallback(async () => {
    try {
      await clearMilestoneHistory();
      setHistory([]);
    } catch (err) {
      console.error('useRewards.clear error', err);
    }
  }, []);

  return { loading, history, add, load, clear };
}

export type UseRewardsReturn = ReturnType<typeof useRewards>;
