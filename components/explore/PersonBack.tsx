import React from 'react';
import { StyleSheet, View } from 'react-native';
import { colors } from '../../styles/theme';
import { radius, spacing, type } from '../../styles/tokens';
import FitText from '../common/FitText';

type Props = {
  profile: any;
};

export default function PersonBack({ profile }: Props) {
  const p = profile.rawPerson;

  return (
    <View style={styles.container}>
      <View>
        <FitText style={styles.title} maxLines={1} minFontSize={14}>{p?.name || profile.sign}</FitText>

        <View style={styles.section}>
          <FitText style={styles.label} maxLines={1} minFontSize={11}>Dating style</FitText>
          <FitText style={styles.body} minFontSize={11}>{profile.datingStyle}</FitText>
        </View>

        <View style={styles.section}>
          <FitText style={styles.label} maxLines={1} minFontSize={11}>Emotional needs</FitText>
          <FitText style={styles.body} minFontSize={11}>{profile.emotionalNeeds.join(' • ')}</FitText>
        </View>

        <View style={styles.section}>
          <FitText style={styles.label} maxLines={1} minFontSize={11}>Interests</FitText>
          <FitText style={styles.body} minFontSize={11}>{(profile.traits || []).join(' • ')}</FitText>
        </View>

        <View style={styles.section}>
          <FitText style={styles.label} maxLines={1} minFontSize={11}>Compatibility</FitText>
          <View style={styles.hintCard}>
            <FitText style={styles.hintText} minFontSize={11}>{profile.compatibilityHint}</FitText>
          </View>
        </View>
      </View>

      <View style={styles.footer}>
        <FitText style={styles.footerText} maxLines={1} minFontSize={10}>Tap again to return</FitText>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: spacing.md,
    justifyContent: 'space-between',
  },
  title: {
    ...type.title,
    fontWeight: '800',
    color: colors.text,
  },
  section: {
    marginTop: spacing.md,
  },
  label: {
    ...type.label,
    color: colors.accent,
    marginBottom: 6,
  },
  body: {
    color: colors.text,
    lineHeight: 20,
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
  },
  footer: {
    alignItems: 'center',
    marginTop: spacing.md,
  },
  footerText: {
    ...type.label,
    color: colors.textMuted,
  },
});