import AsyncStorage from '@react-native-async-storage/async-storage';

const ONBOARDING_PROGRESS_KEY = 'zodian:onboarding_progress:v1';

export type OnboardingStep = 'welcome' | 'name' | 'birthdate' | 'reveal' | 'theory' | 'complete';

export async function saveOnboardingStep(step: OnboardingStep) {
  try {
    await AsyncStorage.setItem(ONBOARDING_PROGRESS_KEY, step);
  } catch {
    // best-effort persistence only
  }
}

export async function getOnboardingStep(): Promise<OnboardingStep | null> {
  try {
    const raw = await AsyncStorage.getItem(ONBOARDING_PROGRESS_KEY);
    if (!raw) return null;

    if (
      raw === 'welcome' ||
      raw === 'name' ||
      raw === 'birthdate' ||
      raw === 'reveal' ||
      raw === 'theory' ||
      raw === 'complete'
    ) {
      return raw;
    }

    return null;
  } catch {
    return null;
  }
}

export async function clearOnboardingProgress() {
  try {
    await AsyncStorage.removeItem(ONBOARDING_PROGRESS_KEY);
  } catch {
    // best-effort cleanup only
  }
}

export function onboardingRouteForStep(step: OnboardingStep | null): '/onboarding/welcome' | '/onboarding/name' | '/onboarding/birthdate' | '/onboarding/reveal' | '/onboarding/theory' | '/(tabs)' {
  switch (step) {
    case 'name':
      return '/onboarding/name';
    case 'birthdate':
      return '/onboarding/birthdate';
    case 'reveal':
      return '/onboarding/reveal';
    case 'theory':
      return '/onboarding/theory';
    case 'complete':
      return '/(tabs)';
    case 'welcome':
    default:
      return '/onboarding/welcome';
  }
}