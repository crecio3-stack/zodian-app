import React from 'react';
import { Dimensions, ScrollView, StyleSheet, View } from 'react-native';
import { colors } from '../../styles/theme';
import { radius, spacing, type } from '../../styles/tokens';
import { ZodiacProfile } from '../../types/zodiac';
import FitText from '../common/FitText';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const BASE_WIDTH = 375;
const SCALE = Math.min(Math.max(SCREEN_WIDTH / BASE_WIDTH, 0.75), 1.15);
function rf(size: number, min = 10, max = 40) {
  const v = Math.round(size * SCALE);
  return Math.max(min, Math.min(v, max));
}

type Props = {
  profile: ZodiacProfile;
};

export default function CardBack({ profile }: Props) {
  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        nestedScrollEnabled
      >
        <View>
          <View style={styles.kickerRow}>
            <FitText style={styles.kicker} maxLines={1} minFontSize={10}>
              DEEPER INSIGHT
            </FitText>
            <View style={styles.kickerLine} />
          </View>

          <FitText style={styles.title} minFontSize={14}>
            {`${profile.sign} in connection`}
          </FitText>

          <View style={styles.section}>
            <FitText style={styles.label} maxLines={1} minFontSize={11}>
              Dating style
            </FitText>
            <FitText style={styles.body} minFontSize={11}>
              {profile.datingStyle}
            </FitText>
          </View>

          <View style={styles.section}>
            <FitText style={styles.label} maxLines={1} minFontSize={11}>
              Emotional needs
            </FitText>
            <FitText style={styles.body} minFontSize={11}>
              {profile.emotionalNeeds.join(' • ')}
            </FitText>
          </View>

          <View style={styles.section}>
            <FitText style={styles.label} maxLines={1} minFontSize={11}>
              Best matches
            </FitText>
            <FitText style={styles.body} minFontSize={11}>
              {profile.bestMatches.join(' • ')}
            </FitText>
          </View>

          <View style={styles.section}>
            <FitText style={styles.label} maxLines={1} minFontSize={11}>
              Compatibility
            </FitText>
            <View style={styles.hintCard}>
              <FitText style={styles.hintText} minFontSize={11}>
                {profile.compatibilityHint}
              </FitText>
            </View>
          </View>
        </View>
      </ScrollView>

      <View style={styles.footer}>
        <View style={styles.footerRule} />
        <FitText style={styles.footerText} maxLines={1} minFontSize={10}>
          Tap again to return
        </FitText>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: spacing.lg,
    justifyContent: 'space-between',
  },
  scroll: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: spacing.lg,
  },

  kickerRow: {
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

  title: {
    color: colors.text,
    fontSize: rf(type.title.fontSize, 16, 40),
    lineHeight: rf(type.title.lineHeight || Math.round(type.title.fontSize * 1.2), 18, 48),
    fontWeight: '800',
  },

  section: {
    marginTop: spacing.md,
  },

  label: {
    ...type.label,
    color: colors.accent,
    marginBottom: 8,
  },

  body: {
    color: colors.text,
    fontSize: rf(type.body.fontSize, 12, 20),
    lineHeight: rf(type.body.lineHeight || Math.round(type.body.fontSize * 1.3), 18, 30),
  },

  hintCard: {
    marginTop: 6,
    padding: 12,
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },

  hintText: {
    color: colors.text,
    fontSize: rf(type.body.fontSize, 12, 20),
    lineHeight: rf(type.body.lineHeight || Math.round(type.body.fontSize * 1.3), 18, 30),
  },

  footer: {
    alignItems: 'center',
    marginTop: spacing.md,
    paddingTop: 8,
  },

  footerRule: {
    width: 42,
    height: 3,
    borderRadius: 999,
    backgroundColor: colors.border,
    marginBottom: 10,
  },

  footerText: {
    ...type.label,
    color: colors.textMuted,
    textAlign: 'center',
  },
});