import React, { useMemo, useState } from 'react';
import {
    Modal,
    Pressable,
    ScrollView,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { GlassCard } from '../../components/GlassCard';
import { useStoredBirthdate } from '../../hooks/useStoredBirthdate';
import { colors, radius, spacing } from '../../styles/theme';
import {
    getChineseSign,
    getWesternSign,
} from '../../utils/astrology';

type MatchProfile = {
  id: string;
  name: string;
  western: string;
  chinese: string;
  score: number;
  archetype: string;
  insight: string;
  strengths: string[];
  friction: string;
};

const mockMatches: MatchProfile[] = [
  {
    id: '1',
    name: 'Alex',
    western: 'Aries',
    chinese: 'Rat',
    score: 82,
    archetype: 'Magnetic Tension',
    insight:
      'Fast chemistry, strong curiosity, and a dynamic that feels alive right away.',
    strengths: ['Playful chemistry', 'Great banter', 'High attraction'],
    friction:
      'One of you wants reassurance while the other needs space to process.',
  },
  {
    id: '2',
    name: 'Jordan',
    western: 'Leo',
    chinese: 'Dragon',
    score: 91,
    archetype: 'Velvet Fire',
    insight:
      'This pairing feels warm, confident, and naturally drawn to shared momentum.',
    strengths: ['Strong mutual pull', 'Confidence boost', 'Fun date energy'],
    friction:
      'Too much pride at once can turn small tension into unnecessary distance.',
  },
  {
    id: '3',
    name: 'Cameron',
    western: 'Aquarius',
    chinese: 'Monkey',
    score: 76,
    archetype: 'Curious Orbit',
    insight:
      'A mentally stimulating bond with surprising emotional depth underneath it.',
    strengths: ['Interesting conversations', 'Fresh energy', 'Memorable spark'],
    friction:
      'One person may intellectualize while the other wants clearer emotional signals.',
  },
];

export default function CompatibilityScreen() {
  const { selectedDate } = useStoredBirthdate(new Date());
  const myWestern = getWesternSign(selectedDate);
  const myChinese = getChineseSign(selectedDate);

  const [selectedMatch, setSelectedMatch] = useState<MatchProfile | null>(null);

  const intro = useMemo(() => {
    return `${myWestern} × ${myChinese}`;
  }, [myWestern, myChinese]);

  // Track impressions
  React.useEffect(() => {
    (async () => {
      try { (await import('../../lib/ai/analytics')).trackEvent('compatibility.view', { intro }); } catch {}
    })();
  }, [intro]);

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.hero}>
          <Text style={styles.eyebrow}>COMPATIBILITY</Text>
          <Text style={styles.title}>Your connection energy</Text>
          <Text style={styles.subtitle}>
            Built around your cosmic identity: {intro}
          </Text>
        </View>

        <View style={styles.list}>
          {mockMatches.map((match) => (
            <Pressable
              key={match.id}
              onPress={() => setSelectedMatch(match)}
              style={styles.pressable}
            >
              <GlassCard>
                <View style={styles.cardHeader}>
                  <View>
                    <Text style={styles.name}>{match.name}</Text>
                    <Text style={styles.signs}>
                      {match.western} × {match.chinese}
                    </Text>
                  </View>

                  <View style={styles.scoreBadge}>
                    <Text style={styles.scoreText}>{match.score}%</Text>
                  </View>
                </View>

                <Text style={styles.archetype}>{match.archetype}</Text>
                <Text style={styles.insight}>{match.insight}</Text>

                <View style={styles.strengthRow}>
                  {match.strengths.map((strength) => (
                    <View key={strength} style={styles.strengthPill}>
                      <Text style={styles.strengthText}>{strength}</Text>
                    </View>
                  ))}
                </View>
              </GlassCard>
            </Pressable>
          ))}
        </View>

        <View style={{ height: 28 }} />
      </ScrollView>

      <Modal
        visible={!!selectedMatch}
        transparent
        animationType="slide"
        onRequestClose={() => setSelectedMatch(null)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalSheet}>
            <ScrollView
              contentContainerStyle={styles.modalContent}
              showsVerticalScrollIndicator={false}
            >
              <View style={styles.handle} />

              {selectedMatch && (
                <>
                  <Text style={styles.modalEyebrow}>COSMIC BREAKDOWN</Text>
                  <Text style={styles.modalTitle}>
                    You + {selectedMatch.name}
                  </Text>
                  <Text style={styles.modalMeta}>
                    {myWestern} / {myChinese} × {selectedMatch.western} /{' '}
                    {selectedMatch.chinese}
                  </Text>

                  <View style={styles.bigScoreWrap}>
                    <Text style={styles.bigScore}>{selectedMatch.score}%</Text>
                    <Text style={styles.bigScoreLabel}>
                      {selectedMatch.archetype}
                    </Text>
                  </View>

                  <GlassCard style={styles.modalCard}>
                    <Text style={styles.sectionLabel}>WHY YOU CLICK</Text>
                    <Text style={styles.modalBody}>{selectedMatch.insight}</Text>
                  </GlassCard>

                  <GlassCard style={styles.modalCard}>
                    <Text style={styles.sectionLabel}>STRENGTHS</Text>
                    <View style={styles.modalStrengthList}>
                      {selectedMatch.strengths.map((strength) => (
                        <Text key={strength} style={styles.modalBullet}>
                          • {strength}
                        </Text>
                      ))}
                    </View>
                  </GlassCard>

                  <GlassCard style={styles.modalCard}>
                    <Text style={styles.sectionLabel}>WATCH FOR</Text>
                    <Text style={styles.modalBody}>
                      {selectedMatch.friction}
                    </Text>
                  </GlassCard>

                  <Pressable
                    style={styles.closeButton}
                    onPress={() => setSelectedMatch(null)}
                  >
                    <Text style={styles.closeButtonText}>Close</Text>
                  </Pressable>
                </>
              )}
            </ScrollView>
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
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    paddingHorizontal: spacing.lg,
    paddingTop: 8,
    paddingBottom: 24,
  },

  hero: {
    paddingTop: 10,
    paddingBottom: 20,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2.2,
    marginBottom: 10,
  },
  title: {
    color: colors.accentBright,
    fontSize: 30,
    lineHeight: 36,
    fontWeight: '700',
    marginBottom: 10,
    letterSpacing: -0.6,
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 16,
    lineHeight: 24,
  },

  list: {
    gap: 14,
  },
  pressable: {
    borderRadius: radius.lg,
  },
  cardHeader: {
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
  scoreBadge: {
    minWidth: 68,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: radius.pill,
    backgroundColor: colors.secondaryAccentGlow,
    borderWidth: 1,
    borderColor: 'rgba(163, 174, 149, 0.24)',
    alignItems: 'center',
  },
  scoreText: {
    color: colors.text,
    fontWeight: '700',
    fontSize: 16,
  },
  archetype: {
    color: colors.accentSoft,
    fontSize: 18,
    fontWeight: '700',
    marginTop: 16,
    marginBottom: 8,
  },
  insight: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 23,
  },
  strengthRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 16,
  },
  strengthPill: {
    paddingHorizontal: 10,
    paddingVertical: 8,
    borderRadius: radius.pill,
    backgroundColor: colors.backgroundAlt,
    borderWidth: 1,
    borderColor: colors.cardBorder,
  },
  strengthText: {
    color: colors.textSoft,
    fontSize: 12,
  },

  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.48)',
    justifyContent: 'flex-end',
  },
  modalSheet: {
    maxHeight: '86%',
    backgroundColor: colors.backgroundAlt,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    borderWidth: 1,
    borderColor: colors.cardBorder,
  },
  modalContent: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 28,
  },
  handle: {
    alignSelf: 'center',
    width: 44,
    height: 5,
    borderRadius: 999,
    backgroundColor: colors.textFaint,
    marginBottom: 16,
  },
  modalEyebrow: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2,
    marginBottom: 10,
  },
  modalTitle: {
    color: colors.accentBright,
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '700',
    marginBottom: 6,
  },
  modalMeta: {
    color: colors.textMuted,
    fontSize: 14,
    marginBottom: 18,
  },
  bigScoreWrap: {
    marginBottom: 18,
  },
  bigScore: {
    color: colors.text,
    fontSize: 42,
    fontWeight: '700',
    letterSpacing: -1,
  },
  bigScoreLabel: {
    color: colors.secondaryAccentSoft,
    fontSize: 16,
    marginTop: 4,
  },
  modalCard: {
    marginBottom: 12,
  },
  sectionLabel: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2,
    marginBottom: 10,
  },
  modalBody: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 23,
  },
  modalStrengthList: {
    gap: 8,
  },
  modalBullet: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 22,
  },
  closeButton: {
    marginTop: 10,
    borderRadius: radius.md,
    backgroundColor: colors.accentSoft,
    paddingVertical: 15,
    alignItems: 'center',
  },
  closeButtonText: {
    color: colors.background,
    fontSize: 15,
    fontWeight: '700',
  },
});