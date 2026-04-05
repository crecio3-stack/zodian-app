import { useCallback, useEffect, useState } from 'react';
import { EVENTS, trackEvent } from '../lib/analytics/analytics';
import {
    activatePremium,
    deactivatePremium,
    getPremiumSubscription,
    isPremiumActive,
    startTrial,
    type PremiumSubscription,
} from '../lib/premium/paywall';

  type PremiumAnalyticsContext = Record<string, unknown>;

export function usePremium() {
  const [isPremium, setIsPremium] = useState(false);
  const [hasLoaded, setHasLoaded] = useState(false);
  const [subscription, setSubscription] = useState<PremiumSubscription | null>(null);

  useEffect(() => {
    let isMounted = true;

    const load = async () => {
      try {
        const [active, sub] = await Promise.all([isPremiumActive(), getPremiumSubscription()]);
        if (!isMounted) return;
        setIsPremium(active);
        setSubscription(sub);
      } catch {
        if (!isMounted) return;
        setIsPremium(false);
      } finally {
        if (isMounted) setHasLoaded(true);
      }
    };

    load();

    return () => {
      isMounted = false;
    };
  }, []);

  const enablePremium = useCallback(async (
    source: 'purchase' | 'lifetime' = 'purchase',
    analyticsContext?: PremiumAnalyticsContext,
  ) => {
    const wasFreeBefore = !isPremium;
    await activatePremium(source);
    setIsPremium(true);
    const sub = await getPremiumSubscription();
    setSubscription(sub);

    if (wasFreeBefore) {
      trackEvent(EVENTS.PREMIUM_PURCHASED, { source, ...analyticsContext });
    }
  }, [isPremium]);

  const disablePremium = useCallback(async () => {
    await deactivatePremium();
    setIsPremium(false);
    setSubscription(null);
  }, []);

  const enableTrial = useCallback(async (analyticsContext?: PremiumAnalyticsContext) => {
    await startTrial();
    setIsPremium(true);
    const sub = await getPremiumSubscription();
    setSubscription(sub);
    trackEvent(EVENTS.PREMIUM_TRIAL_STARTED, analyticsContext ?? {});
  }, []);

  const togglePremium = useCallback(async () => {
    if (isPremium) {
      await disablePremium();
    } else {
      await enablePremium();
    }
  }, [isPremium, enablePremium, disablePremium]);

  const refreshPremium = useCallback(async () => {
    try {
      const active = await isPremiumActive();
      setIsPremium(active);
      if (active) {
        const sub = await getPremiumSubscription();
        setSubscription(sub);
      }
    } catch {
      // Silent fail, keep current state
    }
  }, []);

  return {
    isPremium,
    hasLoaded,
    subscription,
    enablePremium,
    disablePremium,
    enableTrial,
    togglePremium,
    refreshPremium,

    // Legacy aliases so existing screens keep working
    unlockPremium: enablePremium,
  };
}