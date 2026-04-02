import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { premiumTheme } from '../../styles/premiumTheme';
import { radius, spacing, typography } from '../../styles/tokens';

type Props = {
  onReset: () => void;
};

export default function EmptyExploreState({ onReset }: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.symbol}>✦</Text>
      <Text style={styles.title}>You’ve seen all your aligned connections</Text>
      <Text style={styles.body}>
        New people appear as energy shifts.
        {'\n'}Check back soon — your next match may already be forming.
      </Text>

      <Pressable onPress={onReset} style={styles.button}>
        <Text style={styles.buttonText}>Reset deck</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: premiumTheme.colors.border,
    backgroundColor: premiumTheme.colors.card,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.lg,
  },
  symbol: {
    fontSize: 26,
    color: premiumTheme.colors.accent,
    marginBottom: spacing.md,
  },
  title: {
    ...typography.title2,
    color: premiumTheme.colors.text,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  body: {
    ...typography.body,
    color: premiumTheme.colors.textMuted,
    textAlign: 'center',
    marginBottom: spacing.sm,
  },
  button: {
    alignSelf: 'center',
    minWidth: 220,
    marginTop: spacing.sm,
    marginBottom: spacing.md,
    borderWidth: 1,
    borderColor: premiumTheme.colors.border,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
    backgroundColor: 'rgba(201,168,97,0.06)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: {
    ...typography.label,
    color: premiumTheme.colors.accent,
    textAlign: 'center',
  },
});