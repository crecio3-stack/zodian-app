import { router } from 'expo-router';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { colors, spacing } from '../styles/theme';
import { radius, type } from '../styles/tokens';

const pillars = [
  {
    title: 'Two Lenses, One Person',
    body: 'Western astrology describes how your personality expresses itself day-to-day. Chinese astrology adds a deeper behavioral pattern tied to motivation, timing, and long-range temperament. Used together, they create a fuller map of relational behavior.',
  },
  {
    title: 'Trait Layering',
    body: 'Single-sign readings can feel vague because they describe only one axis of identity. Layering two systems increases specificity: one sign explains your style, while the other explains your instinct under stress, attraction, and commitment.',
  },
  {
    title: 'Pattern Consistency',
    body: 'The goal is not fortune telling. The goal is pattern recognition: communication rhythm, attachment pace, conflict style, and growth edge. Repeated pattern language helps users make clearer decisions in dating and self-development.',
  },
  {
    title: 'Practical Application',
    body: 'Zodian converts this synthesis into behavior prompts: what to do today, how to connect better, and where your blind spots usually appear. Theory matters only if it changes choices in real life.',
  },
];

export default function TheoryScreen() {
  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.eyebrow}>THEORY</Text>
        <Text style={styles.title}>Why East + West Together</Text>
        <Text style={styles.subtitle}>
          Zodian uses an East-West synthesis framework to translate personality patterns into practical dating guidance.
        </Text>

        <View style={styles.note}>
          <Text style={styles.noteLabel}>Approach</Text>
          <Text style={styles.noteBody}>
            We layer Western expression with Eastern instinct to improve clarity around communication style, attachment rhythm, and growth edges.
          </Text>
        </View>

        {pillars.map((item) => (
          <View key={item.title} style={styles.card}>
            <Text style={styles.cardTitle}>{item.title}</Text>
            <Text style={styles.cardBody}>{item.body}</Text>
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
  eyebrow: {
    ...type.label,
    color: colors.accent,
    marginBottom: 8,
  },
  title: {
    ...type.title,
    color: colors.text,
    marginBottom: 8,
  },
  subtitle: {
    ...type.bodySmall,
    color: colors.textSoft,
    lineHeight: 22,
    marginBottom: 14,
  },
  note: {
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 12,
    marginBottom: 12,
  },
  noteLabel: {
    ...type.label,
    color: colors.accent,
    marginBottom: 6,
  },
  noteBody: {
    ...type.bodySmall,
    color: colors.textSoft,
    lineHeight: 20,
  },
  card: {
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 14,
    marginBottom: 10,
  },
  cardTitle: {
    ...type.label,
    color: colors.accent,
    marginBottom: 6,
  },
  cardBody: {
    ...type.body,
    color: colors.text,
    lineHeight: 23,
  },
  actions: {
    marginTop: 8,
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
