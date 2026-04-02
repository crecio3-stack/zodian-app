import React from 'react';
import { Dimensions, ScrollView, StyleSheet, View } from 'react-native';
import { colors } from '../../styles/theme';
import { radius, spacing, type } from '../../styles/tokens';
import { ZodiacProfile } from '../../types/zodiac';
import FitText from '../common/FitText';

// Responsive font sizing helper
const { width: SCREEN_WIDTH } = Dimensions.get('window');
const BASE_WIDTH = 375; // design reference width
const SCALE = Math.min(Math.max(SCREEN_WIDTH / BASE_WIDTH, 0.75), 1.15); // tightened scale
function rf(size: number, min = 10, max = 40) {
  const v = Math.round(size * SCALE);
  return Math.max(min, Math.min(v, max));
}

type Props = {
  profile: ZodiacProfile;
};

export default function CardFront({ profile }: Props) {
  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        nestedScrollEnabled
      >
        <View>
          <View style={styles.topMeta}>
            <FitText style={styles.kicker} maxLines={1} minFontSize={10}>
              DISCOVERY
            </FitText>
            <View style={styles.kickerLine} />
          </View>

          <View style={styles.top}>
            <View style={styles.symbolOrb}>
              <FitText style={styles.symbol} maxLines={1} minFontSize={18}>
                {profile.symbol}
              </FitText>
            </View>

            <View style={styles.topText}>
              <FitText style={styles.sign} maxLines={1} minFontSize={14}>
                {profile.sign}
              </FitText>
              <FitText style={styles.archetype} maxLines={1} minFontSize={12}>
                {profile.archetype}
              </FitText>
            </View>
          </View>

          <View style={styles.quoteWrap}>
            <FitText style={styles.quote} minFontSize={10}>
              {profile.tagline}
            </FitText>
          </View>

          <View style={styles.row}>
            <View style={styles.metaPill}>
              <FitText style={styles.metaLabel} maxLines={1} minFontSize={11}>
                {profile.element}
              </FitText>
            </View>
            <View style={styles.metaPill}>
              <FitText style={styles.metaLabel} maxLines={1} minFontSize={11}>
                {profile.vibe}
              </FitText>
            </View>
          </View>

          <View style={styles.section}>
            <FitText style={styles.sectionLabel} maxLines={1} minFontSize={11}>
              Traits
            </FitText>

            <View style={styles.traitWrap}>
              {profile.traits.map((trait) => (
                <View key={trait} style={styles.traitChip}>
                  <FitText style={styles.traitText} maxLines={1} minFontSize={10}>
                    {trait}
                  </FitText>
                </View>
              ))}
            </View>
          </View>
        </View>
      </ScrollView>

      <View style={styles.bottomHint}>
        <View style={styles.bottomRule} />
        <FitText style={styles.bottomHintText} maxLines={1} minFontSize={10}>
          Tap to reveal the deeper layer
        </FitText>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-start',
    padding: spacing.md, // tightened to reduce empty space
  },
  scroll: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: spacing.lg,
  },

  topMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },

  kicker: {
    ...type.micro,
    color: colors.accent,
    marginRight: spacing.sm,
    letterSpacing: 1.2,
  },

  kickerLine: {
    flex: 1,
    height: 1,
    backgroundColor: colors.border,
  },

  top: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },

  symbolOrb: {
    width: 56,
    height: 56,
    borderRadius: radius.pill,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },

  symbol: {
    fontSize: rf(28, 16, 40),
    color: colors.accent,
    lineHeight: rf(30, 16, 44),
    textAlign: 'center',
  },

  topText: {
    flex: 1,
  },

  sign: {
    color: colors.text,
    fontSize: rf(type.title1.fontSize, 16, 40),
    lineHeight: rf(type.title1.lineHeight || Math.round(type.title1.fontSize * 1.2), 18, 48),
    fontWeight: (type.title1 as any).fontWeight ?? '700',
    marginBottom: 2,
  },

  archetype: {
    color: colors.textMuted,
    fontSize: rf(type.title2.fontSize, 12, 28),
    lineHeight: rf(type.title2.lineHeight || Math.round(type.title2.fontSize * 1.2), 14, 32),
    marginTop: 2,
  },

  quoteWrap: {
    marginTop: spacing.sm,
    paddingVertical: 0,
  },

  quote: {
    fontSize: rf(type.title.fontSize * 0.9, 12, 28),
    lineHeight: rf((type.title.lineHeight || Math.round(type.title.fontSize * 1.2)) * 0.9, 16, 36),
    fontWeight: '700',
    letterSpacing: 0.2,
    color: colors.text,
  },

  row: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
    marginTop: spacing.md,
  },

  metaPill: {
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.surface,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: radius.pill,
  },

  metaLabel: {
    ...type.label,
    color: colors.textMuted,
    fontSize: 11,
  },

  section: {
    marginTop: spacing.lg,
  },

  sectionLabel: {
    ...type.label,
    color: colors.accent,
    marginBottom: spacing.sm,
  },

  traitWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },

  traitChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: radius.pill,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },

  traitText: {
    color: colors.text,
    fontSize: 12,
    fontWeight: '700',
  },

  bottomHint: {
    alignSelf: 'stretch',
    alignItems: 'center',
    marginTop: spacing.md,
    paddingTop: 8,
  },

  bottomRule: {
    width: 42,
    height: 3,
    borderRadius: 999,
    backgroundColor: colors.border,
    marginBottom: 10,
  },

  bottomHintText: {
    ...type.label,
    color: colors.textMuted,
    textAlign: 'center',
  },
});