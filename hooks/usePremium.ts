import AsyncStorage from '@react-native-async-storage/async-storage';
import { useCallback, useEffect, useState } from 'react';

const PREMIUM_STORAGE_KEY = 'zodian_premium_enabled';

export function usePremium() {
  const [isPremium, setIsPremium] = useState(false);
  const [hasLoaded, setHasLoaded] = useState(false);

  useEffect(() => {
    let isMounted = true;

    const loadPremium = async () => {
      try {
        const value = await AsyncStorage.getItem(PREMIUM_STORAGE_KEY);
        if (!isMounted) return;
        setIsPremium(value === 'true');
      } catch {
        if (!isMounted) return;
        setIsPremium(false);
      } finally {
        if (isMounted) {
          setHasLoaded(true);
        }
      }
    };

    loadPremium();

    return () => {
      isMounted = false;
    };
  }, []);

  const enablePremium = useCallback(async () => {
    await AsyncStorage.setItem(PREMIUM_STORAGE_KEY, 'true');
    setIsPremium(true);
  }, []);

  const disablePremium = useCallback(async () => {
    await AsyncStorage.setItem(PREMIUM_STORAGE_KEY, 'false');
    setIsPremium(false);
  }, []);

  const togglePremium = useCallback(async () => {
    const nextValue = !isPremium;
    await AsyncStorage.setItem(PREMIUM_STORAGE_KEY, nextValue ? 'true' : 'false');
    setIsPremium(nextValue);
  }, [isPremium]);

  return {
    isPremium,
    hasLoaded,
    enablePremium,
    disablePremium,
    togglePremium,

    // aliases so your existing screens keep working
    unlockPremium: enablePremium,
  };
}