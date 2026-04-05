/**
 * Retention hooks and triggers
 * 
 * Handles:
 * - Streak notifications
 * - Milestone celebrations
 * - Re-engagement prompts
 * - Achievement unlocks
 */

import { useEffect, useRef, useState } from 'react';
import { EVENTS, trackEvent } from '../lib/analytics/analytics';
import { CONFIG } from '../lib/config/constants';

function getDateDiffInDays(fromDate: string, toDate: string) {
  const from = new Date(`${fromDate}T00:00:00`);
  const to = new Date(`${toDate}T00:00:00`);
  return Math.floor((to.getTime() - from.getTime()) / CONFIG.TIME.DAY);
}

/**
 * Hook to check and trigger retention notifications
 */
export function useStreakNotifications(
  streak: number | null,
  rewards: any[],
  onMilestone?: (milestone: { label: string; streak: number }) => void
) {
  const [lastNotifiedStreak, setLastNotifiedStreak] = useState<number | null>(null);

  useEffect(() => {
    if (!streak || streak === lastNotifiedStreak) return;

    // Check if this is a milestone
    const milestone = CONFIG.MESSAGING.STREAK_MILESTONES.find((m) => m === streak);
    if (milestone) {
      trackEvent(EVENTS.STREAK_UPDATED, { streak });

      const achievement = Object.values(CONFIG.ACHIEVEMENTS).find((a) => a.streak === streak);
      if (achievement && onMilestone) {
        onMilestone(achievement);
      }

      setLastNotifiedStreak(streak);
    }
  }, [streak, lastNotifiedStreak, onMilestone]);
}

/**
 * Re-engagement check - returns true if user hasn't used app in N days
 */
export function useReengagementCheck(lastActivityTime?: number, dayThreshold = 3): boolean {
  const [shouldReengage, setShouldReengage] = useState(false);

  useEffect(() => {
    if (!lastActivityTime) return;

    const daysSinceActivity = (Date.now() - lastActivityTime) / CONFIG.TIME.DAY;
    if (daysSinceActivity >= dayThreshold) {
      setShouldReengage(true);
      trackEvent('user.needs_reengagement', { daysSinceActivity });
    }
  }, [lastActivityTime, dayThreshold]);

  return shouldReengage;
}

/**
 * Premium unlock prompt trigger
 * Shows premium modal after N free actions
 */
export function usePremiumUnlockPrompt(
  isPremium: boolean,
  actionCount: number,
  triggerPoint = 3,
  onPrompt?: () => void
) {
  const [hasPrompted, setHasPrompted] = useState(false);

  useEffect(() => {
    if (isPremium || hasPrompted) return;

    if (actionCount >= triggerPoint) {
      trackEvent(EVENTS.PREMIUM_VIEWED, { actionCount, triggerPoint });
      onPrompt?.();
      setHasPrompted(true);
    }
  }, [actionCount, triggerPoint, isPremium, hasPrompted, onPrompt]);
}

/**
 * First-time user celebration
 * Triggered on first ritual reveal/completion
 */
export function useFirstActionCelebration(
  actionName: 'reveal' | 'complete',
  isFirstTime: boolean,
  onCelebrate?: () => void
) {
  useEffect(() => {
    if (isFirstTime) {
      trackEvent(`user.first_${actionName}`, {});
      onCelebrate?.();
    }
  }, [isFirstTime, actionName, onCelebrate]);
}

/**
 * Check if user is on a losing streak (missed days)
 */
export function useStreakAtRisk(
  streak: number,
  lastCompletedDate?: string
): { atRisk: boolean; daysUntilReset: number } {
  const [state, setState] = useState({ atRisk: false, daysUntilReset: 0 });
  const lastTrackedKeyRef = useRef<string | null>(null);

  useEffect(() => {
    if (!lastCompletedDate) return;

    const last = new Date(lastCompletedDate);
    const now = new Date();

    // Start of today
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const lastEnd = new Date(last.getFullYear(), last.getMonth(), last.getDate() + 1);

    const daysSinceLast = Math.floor((todayStart.getTime() - lastEnd.getTime()) / CONFIG.TIME.DAY);
    const daysUntilReset = Math.max(0, 1 - daysSinceLast); // Grace period of 1 day
    const atRisk = daysSinceLast > 0 && daysSinceLast <= 1;

    setState({
      atRisk,
      daysUntilReset,
    });

    const trackingKey = `${lastCompletedDate}:${daysSinceLast}:${streak}`;
    if (atRisk && lastTrackedKeyRef.current !== trackingKey) {
      trackEvent(EVENTS.STREAK_AT_RISK, {
        streak,
        lastCompletedDate,
        daysSinceLast,
        daysUntilReset,
      });
      lastTrackedKeyRef.current = trackingKey;
    }
  }, [lastCompletedDate, streak]);

  return state;
}

export function useDailyReturnTracking(input: {
  todayDate?: string;
  lastCompletedDate?: string;
  revealed?: boolean;
  completed?: boolean;
  streak?: number;
}) {
  const trackedDateRef = useRef<string | null>(null);

  useEffect(() => {
    if (!input.todayDate || trackedDateRef.current === input.todayDate) return;

    const gapDays = input.lastCompletedDate ? getDateDiffInDays(input.lastCompletedDate, input.todayDate) : null;
    const returnType = !input.lastCompletedDate
      ? 'new_user'
      : gapDays === 0
        ? 'same_day_return'
        : gapDays === 1
          ? 'next_day_return'
          : 'after_gap';

    trackEvent(EVENTS.DAILY_RETURNED, {
      todayDate: input.todayDate,
      lastCompletedDate: input.lastCompletedDate,
      gapDays,
      returnType,
      revealed: Boolean(input.revealed),
      completed: Boolean(input.completed),
      streak: input.streak ?? 0,
    });

    trackedDateRef.current = input.todayDate;
  }, [input.completed, input.lastCompletedDate, input.revealed, input.streak, input.todayDate]);
}

/**
 * Track premium conversion metrics
 */
export function usePremiumConversionTracking(isPremium: boolean, wasFreeBefore: boolean) {
  useEffect(() => {
    if (isPremium && wasFreeBefore) {
      trackEvent(EVENTS.PREMIUM_PURCHASED, {
        timestamp: Date.now(),
      });
    }
  }, [isPremium, wasFreeBefore]);
}

/**
 * Daily active user check
 * Tracks if user completed action today
 */
export function useDailyActiveUser(completedToday: boolean) {
  useEffect(() => {
    if (completedToday) {
      trackEvent('user.daily_active', {
        date: new Date().toISOString().split('T')[0],
      });
    }
  }, [completedToday]);
}

/**
 * Feature usage tracking
 * Track which premium features users interact with
 */
export const trackFeatureUsage = (featureName: string, properties?: Record<string, any>) => {
  trackEvent(`feature.${featureName}`, {
    timestamp: Date.now(),
    ...properties,
  });
};

/**
 * Funnel tracking for onboarding → core loop
 */
export const trackFunnelEvent = (stage: string, metadata?: Record<string, any>) => {
  trackEvent(`funnel.${stage}`, {
    timestamp: Date.now(),
    ...metadata,
  });
};
