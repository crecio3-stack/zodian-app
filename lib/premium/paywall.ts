/**
 * Premium/paywall management layer
 * 
 * Centralizes all premium feature gating and purchase logic
 * (StoreKit 2 integration ready, currently mocked)
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import { PREMIUM_FEATURES, PREMIUM_PRICING } from '../../lib/config/constants';

export interface PremiumSubscription {
  isActive: boolean;
  source?: 'trial' | 'purchase' | 'lifetime';
  purchasedAt?: number;
  expiresAt?: number;
  purchaseId?: string; // StoreKit 2 ID
}

const PREMIUM_KEY = 'zodian:premium:v1';

/**
 * Check if premium is active (including expiry)
 */
export async function isPremiumActive(): Promise<boolean> {
  try {
    const raw = await AsyncStorage.getItem(PREMIUM_KEY);
    if (!raw) return false;

    const sub: PremiumSubscription = JSON.parse(raw);
    if (!sub.isActive) return false;

    // Check expiry
    if (sub.expiresAt && sub.expiresAt < Date.now()) {
      return false;
    }

    return true;
  } catch {
    return false;
  }
}

/**
 * Get premium subscription info
 */
export async function getPremiumSubscription(): Promise<PremiumSubscription | null> {
  try {
    const raw = await AsyncStorage.getItem(PREMIUM_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

/**
 * Activate premium (mock for now, will integrate StoreKit 2)
 */
export async function activatePremium(source: 'trial' | 'purchase' | 'lifetime' = 'purchase'): Promise<void> {
  const sub: PremiumSubscription = {
    isActive: true,
    source,
    purchasedAt: Date.now(),
    // Yearly subscription expires in 365 days
    expiresAt: source === 'lifetime' ? undefined : Date.now() + 365 * 24 * 60 * 60 * 1000,
  };

  await AsyncStorage.setItem(PREMIUM_KEY, JSON.stringify(sub));
}

/**
 * Deactivate premium
 */
export async function deactivatePremium(): Promise<void> {
  await AsyncStorage.setItem(PREMIUM_KEY, JSON.stringify({ isActive: false }));
}

/**
 * Check if specific feature is locked
 */
export function isFeatureLocked(featureName: keyof typeof PREMIUM_FEATURES, isPremium: boolean): boolean {
  const feature = PREMIUM_FEATURES[featureName];
  if (!feature) return false;
  return feature.locked && !isPremium;
}

/**
 * Get premium benefits text
 */
export function getPremiumBenefits(): Array<{ title: string; body: string }> {
  return [
    {
      title: 'Deeper daily readings',
      body: 'Unlock a richer emotional layer beneath each day\'s message.',
    },
    {
      title: 'Advanced compatibility',
      body: 'See attachment rhythm, chemistry style, and long-term potential.',
    },
    {
      title: 'Premium dating guidance',
      body: 'Get more personalized love insight tailored to your signs.',
    },
    {
      title: 'Stronger ritual experience',
      body: 'Turn Zodian into a daily habit with more meaningful guidance.',
    },
  ];
}

/**
 * Get pricing options
 */
export function getPricingOptions(): Array<{
  id: string;
  label: string;
  duration: string;
  price: string;
  savings?: string;
}> {
  return [
    {
      id: 'monthly',
      label: 'Monthly',
      duration: 'per month',
      price: `$${PREMIUM_PRICING.MONTHLY.price.toFixed(2)}`,
    },
    {
      id: 'yearly',
      label: 'Yearly',
      duration: 'per year',
      price: `$${PREMIUM_PRICING.YEARLY.price.toFixed(2)}`,
      savings: 'Save 33%',
    },
  ];
}

/**
 * Validate receipt (stub for StoreKit 2)
 * TODO: Implement actual StoreKit 2 validation
 */
export async function validateReceipt(receipt: string): Promise<boolean> {
  // In production, send to Apple servers
  // For now, just mark as valid
  return true;
}

/**
 * Restore purchases (for users who bought on another device)
 * TODO: Implement with StoreKit 2
 */
export async function restorePurchases(): Promise<boolean> {
  // In production, query StoreKit 2 for user's subscriptions
  // For now, check localStorage
  try {
    const sub = await getPremiumSubscription();
    return sub?.isActive ?? false;
  } catch {
    return false;
  }
}

/**
 * Check if trial is available
 */
export async function isTrialAvailable(): Promise<boolean> {
  try {
    const raw = await AsyncStorage.getItem(PREMIUM_KEY);
    if (!raw) return true; // First time user

    const sub: PremiumSubscription = JSON.parse(raw);
    return sub.source !== 'trial'; // Only one trial allowed
  } catch {
    return true;
  }
}

/**
 * Start trial
 */
export async function startTrial(): Promise<void> {
  const sub: PremiumSubscription = {
    isActive: true,
    source: 'trial',
    purchasedAt: Date.now(),
    expiresAt: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 day trial
  };

  await AsyncStorage.setItem(PREMIUM_KEY, JSON.stringify(sub));
}

/**
 * Get time until premium expires (in ms)
 */
export async function getTimeUntilExpiry(): Promise<number | null> {
  try {
    const sub = await getPremiumSubscription();
    if (!sub?.expiresAt) return null;

    const remaining = sub.expiresAt - Date.now();
    return remaining > 0 ? remaining : null;
  } catch {
    return null;
  }
}

/**
 * Format time until expiry as readable string
 */
export async function getExpiryText(): Promise<string | null> {
  const remaining = await getTimeUntilExpiry();
  if (!remaining) return null;

  const days = Math.ceil(remaining / (24 * 60 * 60 * 1000));
  return days === 1 ? 'expires tomorrow' : `expires in ${days} days`;
}
