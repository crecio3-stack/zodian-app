import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, spacing } from '../styles/theme';
import { GlassCard } from './GlassCard';

type Props = {
  title: string;
  description: string;
  onPress: () => void;
};

export function LockedCard({ title, description, onPress }: Props) {
  return (
    <Pressable onPress={onPress}>
      <GlassCard style={styles.card}>
        <View style={styles.badge}>
          <Text style={styles.badgeText}>Premium</Text>
        </View>

        <Text style={styles.lock}>✦</Text>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.description}>{description}</Text>

        <View style={styles.ctaRow}>
          <Text style={styles.cta}>Unlock</Text>
          <Text style={styles.arrow}>→</Text>
        </View>
      </GlassCard>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    marginBottom: spacing.md,
  },
  badge: {
    alignSelf: 'flex-start',
    marginBottom: 14,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: 'rgba(201,168,97,0.12)',
    borderWidth: 1,
    borderColor: colors.border,
  },
  badgeText: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '700',
  },
  lock: {
    fontSize: 22,
    marginBottom: 10,
    color: colors.accentSoft,
  },
  title: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 8,
  },
  description: {
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 20,
  },
  ctaRow: {
    marginTop: 16,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  cta: {
    color: colors.accent,
    fontSize: 14,
    fontWeight: '700',
  },
  arrow: {
    color: colors.accent,
    fontSize: 16,
    fontWeight: '700',
  },
});