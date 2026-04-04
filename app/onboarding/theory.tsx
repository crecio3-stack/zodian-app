import { router } from 'expo-router';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { colors, spacing } from '../../styles/theme';
import { radius } from '../../styles/tokens';

const pillars = [
  {
    title: 'Two Lenses, One Person',
    body: 'Western astrology describes your visible style and expression. Eastern astrology describes deeper instinct, timing, and underlying motivation. Together, they produce a fuller behavioral map.',
  },
  {
    title: 'More Specific, Less Generic',
    body: 'Single-sign readings can feel broad. Layering two systems increases precision by explaining both how you show up and how you react under pressure, attraction, and commitment.',
  },
  {
    title: 'Built for Real Decisions',
    body: 'The point is practical pattern recognition: communication rhythm, attachment pace, conflict style, and growth edge. Better pattern awareness leads to better dating choices.',
  },
];

export default function OnboardingTheoryScreen() {
  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.stepPill}>STEP 4 OF 4</Text>
        <Text style={styles.title}>Why This Combo Works</Text>
        <Text style={styles.subtitle}>
          Your identity combines Western expression with Eastern instinct so your guidance reflects how you actually move through relationships.
        </Text>

        {pillars.map((item) => (
          <View key={item.title} style={styles.card}>
            <Text style={styles.cardTitle}>{item.title}</Text>
            <Text style={styles.cardBody}>{item.body}</Text>
          </View>
        ))}

        <View style={styles.actions}>
          <Pressable onPress={() => router.back()} style={({ pressed }) => [styles.secondaryButton, pressed && { opacity: 0.9 }]}>
            <Text style={styles.secondaryText}>Back to reveal</Text>
          </Pressable>
          <Pressable onPress={() => router.replace('/(tabs)')} style={({ pressed }) => [styles.primaryButton, pressed && { opacity: 0.95 }]}>
            <Text style={styles.primaryText}>Enter Zodian</Text>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    paddingHorizontal: spacing.lg,
    paddingTop: 24,
    paddingBottom: 36,
  },
  stepPill: {
    alignSelf: 'flex-start',
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.2)',
    backgroundColor: 'rgba(216,184,107,0.08)',
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 6,
    color: colors.accent,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 2,
    marginBottom: 16,
  },
  title: {
    color: colors.text,
    fontSize: 34,
    lineHeight: 40,
    fontWeight: '700',
    marginBottom: 10,
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 16,
  },
  card: {
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.14)',
    backgroundColor: 'rgba(255,255,255,0.03)',
    padding: 14,
    marginBottom: 10,
  },
  cardTitle: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1,
    textTransform: 'uppercase',
    marginBottom: 8,
  },
  cardBody: {
    color: colors.text,
    fontSize: 15,
    lineHeight: 23,
  },
  actions: {
    marginTop: 8,
    gap: 10,
  },
  primaryButton: {
    borderRadius: 999,
    backgroundColor: colors.accent,
    alignItems: 'center',
    paddingVertical: 15,
  },
  primaryText: {
    color: colors.background,
    fontSize: 16,
    fontWeight: '800',
  },
  secondaryButton: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.16)',
    backgroundColor: 'rgba(255,255,255,0.04)',
    alignItems: 'center',
    paddingVertical: 14,
  },
  secondaryText: {
    color: colors.text,
    fontSize: 15,
    fontWeight: '600',
  },
});
