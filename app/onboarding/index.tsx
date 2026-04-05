import { router } from 'expo-router';
import React, { useEffect } from 'react';
import { View } from 'react-native';
import { getOnboardingStep, onboardingRouteForStep } from '../../lib/storage/onboardingProgress';

export default function OnboardingIndex() {
  useEffect(() => {
    let mounted = true;

    (async () => {
      const step = await getOnboardingStep();
      if (!mounted) return;
      router.replace(onboardingRouteForStep(step));
    })();

    return () => {
      mounted = false;
    };
  }, []);

  return <View style={{ flex: 1 }} />;
}