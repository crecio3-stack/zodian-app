/**
 * Reusable loading and state pattern components
 * 
 * StandardizedUI for:
 * - Skeleton loaders
 * - Empty states
 * - Error states
 * - Loading spinners
 */

import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { colors } from '../styles/theme';
import { spacing, typography } from '../styles/tokens';

/**
 * Skeleton loader (for cards)
 */
export function SkeletonLoader({ width = '100%', height = 100, borderRadius = 12 }) {
  return (
    <LinearGradient
      colors={['rgba(255,255,255,0.02)', 'rgba(255,255,255,0.05)', 'rgba(255,255,255,0.02)']}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={[
        styles.skeleton,
        {
          width: typeof width === 'number' ? width : undefined,
          height,
          borderRadius,
        },
      ]}
    />
  );
}

/**
 * Loading card skeleton
 */
export function SkeletonCard() {
  return (
    <View style={styles.cardSkeleton}>
      <SkeletonLoader width="100%" height={120} borderRadius={12} />
      <View style={{ gap: spacing.sm }}>
        <SkeletonLoader width="70%" height={16} borderRadius={4} />
        <SkeletonLoader width="100%" height={12} borderRadius={4} />
        <SkeletonLoader width="90%" height={12} borderRadius={4} />
      </View>
    </View>
  );
}

/**
 * Loading spinner overlay
 */
export function LoadingSpinner({ message = 'Loading...' }) {
  return (
    <View style={styles.spinnerContainer}>
      <ActivityIndicator size="large" color={colors.accent} />
      {message && <Text style={styles.spinnerText}>{message}</Text>}
    </View>
  );
}

/**
 * Empty state
 */
export function EmptyState({
  icon = 'cloud-offline-outline',
  title = 'Nothing here',
  message = 'Check back later',
  action,
  actionLabel = 'Try again',
}: {
  icon?: string;
  title?: string;
  message?: string;
  action?: () => void;
  actionLabel?: string;
}) {
  return (
    <View style={styles.emptyContainer}>
      <Ionicons name={icon as any} size={56} color={colors.accentMuted} style={styles.emptyIcon} />
      <Text style={styles.emptyTitle}>{title}</Text>
      <Text style={styles.emptyMessage}>{message}</Text>
      {action && (
        <Pressable style={styles.emptyButton} onPress={action}>
          <Text style={styles.emptyButtonText}>{actionLabel}</Text>
        </Pressable>
      )}
    </View>
  );
}

/**
 * Error state
 */
export function ErrorState({
  message = 'Something went wrong',
  action,
  actionLabel = 'Retry',
}: {
  message?: string;
  action?: () => void;
  actionLabel?: string;
}) {
  return (
    <View style={styles.errorContainer}>
      <Ionicons name="alert-circle-outline" size={48} color={colors.danger} style={styles.errorIcon} />
      <Text style={styles.errorTitle}>Error</Text>
      <Text style={styles.errorMessage}>{message}</Text>
      {action && (
        <Pressable style={styles.errorButton} onPress={action}>
          <Text style={styles.errorButtonText}>{actionLabel}</Text>
        </Pressable>
      )}
    </View>
  );
}

/**
 * Locked state (for premium features)
 */
export function LockedState({
  feature = 'Premium feature',
  message = 'Upgrade to premium to unlock',
  onUnlock,
}: {
  feature?: string;
  message?: string;
  onUnlock?: () => void;
}) {
  return (
    <View style={styles.lockedContainer}>
      <Ionicons name="lock-closed-outline" size={48} color={colors.accent} style={styles.lockedIcon} />
      <Text style={styles.lockedTitle}>{feature}</Text>
      <Text style={styles.lockedMessage}>{message}</Text>
      {onUnlock && (
        <Pressable style={styles.lockedButton} onPress={onUnlock}>
          <Text style={styles.lockedButtonText}>Unlock Premium</Text>
        </Pressable>
      )}
    </View>
  );
}

/**
 * Success state
 */
export function SuccessState({
  title = 'Success!',
  message = 'Operation completed',
  icon = 'checkmark-circle-outline',
  action,
  actionLabel = 'Continue',
}: {
  title?: string;
  message?: string;
  icon?: string;
  action?: () => void;
  actionLabel?: string;
}) {
  return (
    <View style={styles.successContainer}>
      <Ionicons name={icon as any} size={56} color={colors.success} style={styles.successIcon} />
      <Text style={styles.successTitle}>{title}</Text>
      <Text style={styles.successMessage}>{message}</Text>
      {action && (
        <Pressable style={styles.successButton} onPress={action}>
          <Text style={styles.successButtonText}>{actionLabel}</Text>
        </Pressable>
      )}
    </View>
  );
}

/**
 * Inline loading state (smaller variant)
 */
export function InlineLoader({ message = 'Loading' }) {
  return (
    <View style={styles.inlineLoader}>
      <ActivityIndicator size="small" color={colors.accent} />
      {message && <Text style={styles.inlineLoaderText}>{message}</Text>}
    </View>
  );
}

// Styles
const styles = StyleSheet.create({
  skeleton: {
    backgroundColor: 'rgba(255,255,255,0.04)',
  },

  cardSkeleton: {
    gap: spacing.md,
    paddingHorizontal: spacing.screenPadding,
    paddingVertical: spacing.md,
  },

  spinnerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: spacing.md,
  },

  spinnerText: {
    ...typography.body,
    color: colors.textMuted,
  },

  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.lg,
    gap: spacing.md,
  },

  emptyIcon: {
    marginBottom: spacing.md,
    opacity: 0.6,
  },

  emptyTitle: {
    ...typography.title,
    color: colors.text,
    textAlign: 'center',
  },

  emptyMessage: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
  },

  emptyButton: {
    marginTop: spacing.md,
    backgroundColor: `rgba(${colors.accent === '#D6B56B' ? '214,181,107' : '255,255,255'},0.1)`,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 8,
    minWidth: 160,
    alignItems: 'center',
  },

  emptyButtonText: {
    ...typography.button,
    color: colors.accent,
  },

  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.lg,
    gap: spacing.md,
  },

  errorIcon: {
    marginBottom: spacing.md,
  },

  errorTitle: {
    ...typography.title,
    color: colors.danger,
    textAlign: 'center',
  },

  errorMessage: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
  },

  errorButton: {
    marginTop: spacing.md,
    backgroundColor: `rgba(180,95,95,0.1)`,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 8,
    minWidth: 160,
    alignItems: 'center',
  },

  errorButtonText: {
    ...typography.button,
    color: colors.danger,
  },

  lockedContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.lg,
    gap: spacing.md,
  },

  lockedIcon: {
    marginBottom: spacing.md,
  },

  lockedTitle: {
    ...typography.title,
    color: colors.text,
    textAlign: 'center',
  },

  lockedMessage: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
  },

  lockedButton: {
    marginTop: spacing.md,
    backgroundColor: colors.accent,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 8,
    minWidth: 200,
    alignItems: 'center',
  },

  lockedButtonText: {
    ...typography.button,
    color: 'white',
  },

  successContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.lg,
    gap: spacing.md,
  },

  successIcon: {
    marginBottom: spacing.md,
  },

  successTitle: {
    ...typography.title,
    color: colors.success,
    textAlign: 'center',
  },

  successMessage: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
  },

  successButton: {
    marginTop: spacing.md,
    backgroundColor: colors.success,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 8,
    minWidth: 160,
    alignItems: 'center',
  },

  successButtonText: {
    ...typography.button,
    color: 'white',
  },

  inlineLoader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.sm,
    paddingVertical: spacing.md,
  },

  inlineLoaderText: {
    ...typography.bodySmall,
    color: colors.textMuted,
  },
});
