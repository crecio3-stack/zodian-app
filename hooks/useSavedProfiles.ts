import AsyncStorage from '@react-native-async-storage/async-storage';
import { useCallback, useEffect, useState } from 'react';

const SAVED_KEY = 'zodian.savedProfiles.v1';
const SKIPPED_KEY = 'zodian.skippedProfiles.v1';

export function useSavedProfiles() {
  const [saved, setSaved] = useState<string[]>([]);
  const [skipped, setSkipped] = useState<string[]>([]);

  const load = useCallback(async () => {
    try {
      const [s, k] = await Promise.all([
        AsyncStorage.getItem(SAVED_KEY),
        AsyncStorage.getItem(SKIPPED_KEY),
      ]);
      setSaved(s ? JSON.parse(s) : []);
      setSkipped(k ? JSON.parse(k) : []);
    } catch (err) {
      // best-effort: swallow and leave arrays empty
      console.warn('useSavedProfiles: failed to load', err);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const persist = useCallback(async (key: string, next: string[]) => {
    try {
      await AsyncStorage.setItem(key, JSON.stringify(next));
    } catch (err) {
      console.warn('useSavedProfiles: failed to persist', err);
    }
  }, []);

  const addSaved = useCallback(async (id: string) => {
    setSaved((prev) => {
      if (prev.includes(id)) return prev;
      const next = [...prev, id];
      persist(SAVED_KEY, next);
      (async () => {
        try { (await import('../lib/ai/analytics')).trackEvent('explore.save', { id }); } catch {}
      })();
      return next;
    });
  }, [persist]);

  const addSkipped = useCallback(async (id: string) => {
    setSkipped((prev) => {
      if (prev.includes(id)) return prev;
      const next = [...prev, id];
      persist(SKIPPED_KEY, next);
      (async () => {
        try { (await import('../lib/ai/analytics')).trackEvent('explore.skip', { id }); } catch {}
      })();
      return next;
    });
  }, [persist]);

  const reset = useCallback(async () => {
    setSaved([]);
    setSkipped([]);
    try {
      await Promise.all([
        AsyncStorage.removeItem(SAVED_KEY),
        AsyncStorage.removeItem(SKIPPED_KEY),
      ]);
      (await import('../lib/ai/analytics')).trackEvent('explore.reset');
    } catch {}
  }, []);

  return {
    saved,
    skipped,
    addSaved,
    addSkipped,
    reset,
  } as const;
}
