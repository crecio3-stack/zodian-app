import { router, useLocalSearchParams } from 'expo-router';
import React, { useMemo } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { getCosmicBlueprint } from '../data/cosmicBlueprint';
import { useStoredBirthdate } from '../hooks/useStoredBirthdate';
import { useStoredName } from '../hooks/useStoredName';
import { colors, spacing } from '../styles/theme';
import { radius, type } from '../styles/tokens';
import { getChineseSign, getWesternSign } from '../utils/astrology';

function splitLeadAndBody(text: string) {
  const clean = (text || '').trim();
  if (!clean) return { lead: '', body: '' };

  const firstPeriod = clean.indexOf('. ');
  if (firstPeriod === -1) {
    return { lead: clean, body: '' };
  }

  return {
    lead: clean.slice(0, firstPeriod + 1),
    body: clean.slice(firstPeriod + 2),
  };
}

export default function BlueprintScreen() {
  const { selectedDate } = useStoredBirthdate(new Date());
  const { name } = useStoredName();
  const params = useLocalSearchParams();

  const westernSign = useMemo(
    () => String((params as any)?.westernSign || getWesternSign(selectedDate)),
    [params, selectedDate]
  );
  const chineseSign = useMemo(
    () => String((params as any)?.chineseSign || getChineseSign(selectedDate)),
    [params, selectedDate]
  );

  const blueprint = useMemo(
    () => getCosmicBlueprint(westernSign as any, chineseSign as any),
    [westernSign, chineseSign]
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Text style={styles.eyebrow}>COSMIC BLUEPRINT</Text>
          <Text style={styles.combo}>{blueprint.comboTitle}</Text>
          <Text style={styles.title}>{blueprint.comboSubtitle}</Text>
          <Text style={styles.subtitle}>
            {name?.trim() ? `${name.trim()}, ${blueprint.signature}` : blueprint.signature}
          </Text>
          <View style={styles.attributionCard}>
            <Text style={styles.attributionLabel}>Method</Text>
            <Text style={styles.attributionText}>
              This blueprint combines Western expression and Eastern instinct to build a fuller, behavior-focused identity model.
            </Text>
            <Pressable
              onPress={() => router.push('/theory')}
              style={({ pressed }) => [styles.theoryLink, pressed && { opacity: 0.85 }]}
            >
              <Text style={styles.theoryLinkText}>Why this system works</Text>
            </Pressable>
          </View>
        </View>

        {blueprint.sections.map((section) => (
          <View key={section.key} style={styles.card}>
            <Text style={styles.cardTitle}>{section.title}</Text>
            <Text style={styles.cardLead}>{splitLeadAndBody(section.body).lead}</Text>
            {splitLeadAndBody(section.body).body ? (
              <Text style={styles.cardBody}>{splitLeadAndBody(section.body).body}</Text>
            ) : null}
          </View>
        ))}

        <View style={styles.actions}>
          <Pressable onPress={() => router.back()} style={({ pressed }) => [styles.backButton, pressed && { opacity: 0.9 }]}>
            <Text style={styles.backButtonText}>Back</Text>
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
    padding: spacing.lg,
    paddingBottom: 120,
  },
  header: {
    marginBottom: 14,
  },
  eyebrow: {
    ...type.label,
    color: colors.accent,
    marginBottom: 10,
  },
  combo: {
    ...type.title2,
    color: colors.accentBright,
    fontWeight: '800',
    marginBottom: 2,
  },
  title: {
    ...type.title,
    color: colors.text,
    marginBottom: 10,
  },
  subtitle: {
    ...type.bodySmall,
    color: colors.textSoft,
    lineHeight: 22,
  },
  attributionCard: {
    marginTop: 14,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 12,
    gap: 7,
  },
  attributionLabel: {
    ...type.label,
    color: colors.accent,
  },
  attributionText: {
    ...type.bodySmall,
    color: colors.textSoft,
    lineHeight: 20,
  },
  theoryLink: {
    alignSelf: 'flex-start',
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.03)',
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  theoryLinkText: {
    ...type.label,
    color: colors.accentSoft,
  },
  card: {
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 18,
    marginBottom: 12,
  },
  cardTitle: {
    ...type.label,
    color: colors.accent,
    marginBottom: 7,
  },
  cardLead: {
    ...type.body,
    color: colors.text,
    lineHeight: 24,
    fontWeight: '600',
    marginBottom: 6,
  },
  cardBody: {
    ...type.bodySmall,
    color: colors.textSoft,
    lineHeight: 22,
  },
  actions: {
    marginTop: 8,
    gap: 0,
    alignItems: 'flex-start',
  },
  backButton: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  backButtonText: {
    ...type.label,
    color: colors.accentSoft,
  },
});