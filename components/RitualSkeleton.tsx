import React from 'react';
import { StyleSheet, View } from 'react-native';
import { colors, radius, spacing } from '../styles/theme';

export function RitualSkeleton() {
  return (
    <View style={styles.container} accessibilityLiveRegion="polite">
      <View style={styles.header}>
        <View style={styles.title} />
        <View style={styles.sub} />
      </View>

      <View style={styles.steps}>
        {[0, 1, 2].map((i) => (
          <View key={i} style={styles.step}>
            <View style={styles.stepTitle} />
            <View style={styles.stepBody} />
          </View>
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: spacing.md,
  },
  header: {
    marginBottom: spacing.sm,
  },
  title: {
    width: '60%',
    height: 28,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderRadius: 6,
    marginBottom: 8,
  },
  sub: {
    width: '40%',
    height: 14,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderRadius: 4,
  },
  steps: {
    gap: 12,
  },
  step: {
    backgroundColor: colors.cardStrong,
    borderRadius: radius.lg,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.02)',
  },
  stepTitle: {
    width: '45%',
    height: 16,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderRadius: 4,
    marginBottom: 6,
  },
  stepBody: {
    width: '90%',
    height: 44,
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderRadius: 6,
  },
});
