import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors, radius, spacing } from '../styles/theme';

type DailyRitualCardProps = {
  title: string;
  body: string;
  accent?: 'soft' | 'highlight';
};

export function DailyRitualCard({
  title,
  body,
  accent = 'soft',
}: DailyRitualCardProps) {
  const isHighlight = accent === 'highlight';

  return (
    <View style={[styles.card, isHighlight && styles.cardHighlight]}>
      <Text style={[styles.title, isHighlight && styles.titleHighlight]}>
        {title}
      </Text>
      <Text style={[styles.body, isHighlight && styles.bodyHighlight]}>
        {body}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.cardStrong,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.xl,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.md,
    marginBottom: spacing.sm,
    shadowColor: colors.shadow,
    shadowOpacity: 0.18,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 10 },
    elevation: 8,
  },
  cardHighlight: {
    backgroundColor: 'rgba(214, 181, 107, 0.12)',
    borderColor: 'rgba(214, 181, 107, 0.22)',
  },
  title: {
    color: colors.accentSoft,
    fontSize: 12,
    letterSpacing: 1.8,
    marginBottom: 10,
    textTransform: 'uppercase',
    fontWeight: '700',
  },
  titleHighlight: {
    color: colors.accent,
  },
  body: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 24,
  },
  bodyHighlight: {
    color: colors.text,
  },
});