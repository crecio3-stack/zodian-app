import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React, { useMemo, useState } from 'react';
import { FlatList, Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GlassCard } from '../../components/GlassCard';
import { people } from '../../data/people';
import { zodiacProfiles } from '../../data/zodiacProfiles';
import { usePremium } from '../../hooks/usePremium';
import { useSavedProfiles } from '../../hooks/useSavedProfiles';
import { colors, radius, spacing, typography } from '../../styles/theme';

type ConnectionItem = {
  id: string;
  name: string;
  signs: string;
  score: number;
  strengths: string[];
  friction: string;
  spark: string;
};

function computeCompatibilityScore(seedText: string) {
  const seed = seedText.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
  return 68 + (seed % 31);
}

function buildBreakdown(name: string) {
  return {
    strengths: ['Magnetic chemistry', 'Balanced communication', 'Shared momentum'],
    friction: 'Watch pacing differences when one person needs reassurance first.',
    spark: `${name} brings a complementary energy that amplifies your natural rhythm.`,
  };
}

export default function ConnectionsScreen() {
  const { saved } = useSavedProfiles();
  const { isPremium, enablePremium } = usePremium();
  const [selected, setSelected] = useState<ConnectionItem | null>(null);

  const items = useMemo<ConnectionItem[]>(() => {
    return saved
      .map((id) => {
        const person = people.find((p) => p.id === id);
        if (person) {
          const score = computeCompatibilityScore(`${person.westernSign}${person.chineseSign}${id}`);
          const breakdown = buildBreakdown(person.name);
          return {
            id,
            name: person.name,
            signs: `${person.westernSign} / ${person.chineseSign}`,
            score,
            ...breakdown,
          };
        }

        const zodiac = zodiacProfiles.find((z) => z.id === id);
        if (!zodiac) return null;

        const score = computeCompatibilityScore(`${zodiac.sign}${zodiac.vibe}${id}`);
        const breakdown = buildBreakdown(zodiac.sign);
        return {
          id,
          name: zodiac.sign,
          signs: `${zodiac.element} / ${zodiac.vibe}`,
          score,
          ...breakdown,
        };
      })
      .filter(Boolean) as ConnectionItem[];
  }, [saved]);

  const averageScore = useMemo(() => {
    if (!items.length) return 0;
    return Math.round(items.reduce((sum, item) => sum + item.score, 0) / items.length);
  }, [items]);

  return (
    <SafeAreaView style={styles.safeArea}>
      <LinearGradient
        colors={[colors.background, colors.backgroundAlt, colors.background]}
        style={StyleSheet.absoluteFill}
      />

      <FlatList
        data={items}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <>
            <View style={styles.topMetaRow}>
              <Text style={styles.kicker}>CONNECTIONS</Text>
              <View style={styles.metaPill}>
                <Text style={styles.metaPillText}>{items.length} active</Text>
              </View>
            </View>

            <View style={styles.heroCard}>
              <Text style={styles.heroTitle}>Your active matches</Text>
              <Text style={styles.heroSubtitle}>
                Intentional connections shaped by your cosmic profile.
              </Text>

              <View style={styles.heroStatsRow}>
                <View style={styles.heroStatPill}>
                  <Text style={styles.heroStatLabel}>Connections</Text>
                  <Text style={styles.heroStatValue}>{items.length}</Text>
                </View>
                <View style={styles.heroStatPill}>
                  <Text style={styles.heroStatLabel}>Avg. alignment</Text>
                  <Text style={styles.heroStatValue}>{averageScore}%</Text>
                </View>
              </View>
            </View>

            <View style={styles.betaCard}>
              <Text style={styles.betaLabel}>Cosmic Connections (beta)</Text>
              <Text style={styles.betaBody}>
                {isPremium
                  ? 'Premium beta is active. Enhanced compatibility depth and chat-first experiences are rolling out next.'
                  : 'Premium beta unlocks deeper compatibility layers, richer connection signals, and upcoming guided chat.'}
              </Text>

              {!isPremium ? (
                <Pressable
                  style={styles.betaCta}
                  onPress={async () => {
                    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
                    await enablePremium();
                  }}
                >
                  <Text style={styles.betaCtaText}>Unlock premium beta</Text>
                </Pressable>
              ) : null}
            </View>

            {items.length ? <Text style={styles.sectionHeading}>Matched people</Text> : null}
          </>
        }
        renderItem={({ item }) => (
          <Pressable onPress={() => setSelected(item)}>
            <GlassCard style={styles.card}>
              <View style={styles.rowTop}>
                <View>
                  <Text style={styles.name}>{item.name}</Text>
                  <Text style={styles.signs}>{item.signs}</Text>
                </View>
                <View style={styles.scorePill}>
                  <Text style={styles.scoreText}>{item.score}%</Text>
                </View>
              </View>
            </GlassCard>
          </Pressable>
        )}
        ItemSeparatorComponent={() => <View style={{ height: 10 }} />}
        ListEmptyComponent={
          <View style={styles.emptyWrap}>
            <Text style={styles.emptyTitle}>No connections yet</Text>
            <Text style={styles.emptySubtitle}>Find your alignment</Text>
            <Pressable
              style={styles.findButton}
              onPress={() => router.push('/(tabs)/match')}
              accessibilityRole="button"
              accessibilityLabel="Find more matches"
            >
              <Text style={styles.findButtonText}>Find more matches</Text>
            </Pressable>
          </View>
        }
        ListFooterComponent={
          items.length ? (
            <Pressable
              style={styles.findButton}
              onPress={() => router.push('/(tabs)/match')}
              accessibilityRole="button"
              accessibilityLabel="Find more matches"
            >
              <Text style={styles.findButtonText}>Find more matches</Text>
            </Pressable>
          ) : null
        }
      />

      <Modal
        visible={Boolean(selected)}
        transparent
        animationType="slide"
        onRequestClose={() => setSelected(null)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalSheet}>
            <View style={styles.handle} />
            {selected ? (
              <>
                <Text style={styles.modalEyebrow}>COMPATIBILITY BREAKDOWN</Text>
                <Text style={styles.modalTitle}>{selected.name}</Text>
                <Text style={styles.modalSigns}>{selected.signs}</Text>

                <View style={styles.modalScoreWrap}>
                  <Text style={styles.modalScore}>{selected.score}%</Text>
                  <Text style={styles.modalScoreLabel}>Overall alignment</Text>
                </View>

                <GlassCard style={styles.modalCard}>
                  <Text style={styles.sectionLabel}>WHY THIS WORKS</Text>
                  {selected.strengths.map((s) => (
                    <Text key={s} style={styles.modalBullet}>• {s}</Text>
                  ))}
                </GlassCard>

                <GlassCard style={styles.modalCard}>
                  <Text style={styles.sectionLabel}>WATCH FOR</Text>
                  <Text style={styles.modalBody}>{selected.friction}</Text>
                </GlassCard>

                <GlassCard style={styles.modalCard}>
                  <Text style={styles.sectionLabel}>FUTURE CHAT</Text>
                  <Text style={styles.modalBody}>Chat unlock is coming soon. You will be able to start a guided cosmic conversation here.</Text>
                </GlassCard>

                <View style={styles.modalActions}>
                  <Pressable
                    style={styles.primaryButton}
                    onPress={() => {
                      setSelected(null);
                      router.push('/compatibility');
                    }}
                  >
                    <Text style={styles.primaryButtonText}>View full compatibility</Text>
                  </Pressable>
                  <Pressable style={styles.secondaryButton} onPress={() => setSelected(null)}>
                    <Text style={styles.secondaryButtonText}>Close</Text>
                  </Pressable>
                </View>
              </>
            ) : null}
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.sm,
    paddingBottom: 120,
  },
  topMetaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  kicker: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700',
  },
  metaPill: {
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  metaPillText: {
    color: colors.textMuted,
    fontSize: 11,
    fontWeight: '700',
  },
  heroCard: {
    borderRadius: 26,
    padding: 20,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    marginBottom: 12,
  },
  heroTitle: {
    color: colors.accentBright,
    ...typography.title,
    marginBottom: 6,
  },
  heroSubtitle: {
    color: colors.textSoft,
    ...typography.body,
    fontSize: 15,
    lineHeight: 22,
    marginBottom: 12,
  },
  heroStatsRow: {
    flexDirection: 'row',
    gap: 10,
  },
  heroStatPill: {
    flex: 1,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: 'rgba(230, 183, 92, 0.12)',
    backgroundColor: 'rgba(255,255,255,0.02)',
    paddingVertical: 10,
    paddingHorizontal: 12,
  },
  heroStatLabel: {
    color: colors.textMuted,
    fontSize: 11,
    marginBottom: 4,
  },
  heroStatValue: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '700',
  },
  betaCard: {
    borderRadius: 20,
    padding: 16,
    marginBottom: 14,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(214,181,107,0.08)',
  },
  betaLabel: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1,
    marginBottom: 8,
    textTransform: 'uppercase',
  },
  betaBody: {
    color: colors.textSoft,
    fontSize: 14,
    lineHeight: 21,
  },
  betaCta: {
    marginTop: 12,
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    paddingVertical: 12,
    alignItems: 'center',
  },
  betaCtaText: {
    color: '#111111',
    fontWeight: '800',
  },
  sectionHeading: {
    color: colors.text,
    fontSize: 16,
    fontWeight: '700',
    marginBottom: 10,
  },
  card: {
    borderRadius: radius.lg,
  },
  rowTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  name: {
    color: colors.text,
    fontSize: 22,
    fontWeight: '700',
    marginBottom: 4,
  },
  signs: {
    color: colors.textMuted,
    fontSize: 14,
  },
  scorePill: {
    backgroundColor: colors.secondaryAccentGlow,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  scoreText: {
    color: colors.accentBright,
    fontWeight: '700',
    fontSize: 16,
  },
  emptyWrap: {
    marginTop: 64,
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
  },
  emptyTitle: {
    color: colors.text,
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 8,
    textAlign: 'center',
  },
  emptySubtitle: {
    color: colors.textMuted,
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 20,
  },
  findButton: {
    marginTop: 18,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(214,181,107,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 13,
    paddingHorizontal: 16,
  },
  findButtonText: {
    color: colors.accent,
    fontSize: 15,
    fontWeight: '700',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.55)',
    justifyContent: 'flex-end',
  },
  modalSheet: {
    backgroundColor: colors.backgroundAlt,
    borderTopLeftRadius: radius.xl,
    borderTopRightRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.lg,
  },
  handle: {
    alignSelf: 'center',
    width: 44,
    height: 5,
    borderRadius: 999,
    marginTop: 10,
    marginBottom: 14,
    backgroundColor: colors.textFaint,
  },
  modalEyebrow: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2,
    marginBottom: 8,
  },
  modalTitle: {
    color: colors.accentBright,
    ...typography.title2,
  },
  modalSigns: {
    color: colors.textMuted,
    marginTop: 4,
    marginBottom: spacing.sm,
  },
  modalScoreWrap: {
    marginBottom: spacing.sm,
  },
  modalScore: {
    color: colors.text,
    fontSize: 42,
    fontWeight: '800',
  },
  modalScoreLabel: {
    color: colors.textMuted,
  },
  modalCard: {
    marginTop: spacing.sm,
  },
  sectionLabel: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '700',
    marginBottom: 8,
    letterSpacing: 1,
  },
  modalBody: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 22,
  },
  modalBullet: {
    color: colors.textSoft,
    fontSize: 14,
    lineHeight: 21,
    marginBottom: 4,
  },
  modalActions: {
    marginTop: spacing.md,
    gap: spacing.sm,
  },
  primaryButton: {
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    paddingVertical: 13,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: '#111111',
    fontWeight: '800',
  },
  secondaryButton: {
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    paddingVertical: 12,
    alignItems: 'center',
    backgroundColor: colors.card,
  },
  secondaryButtonText: {
    color: colors.text,
    fontWeight: '700',
  },
});
