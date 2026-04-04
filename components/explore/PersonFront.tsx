import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import { ImageBackground, StyleSheet, View } from 'react-native';
import type { PersonProfile } from '../../data/people';
import { colors } from '../../styles/theme';
import { radius, spacing, type } from '../../styles/tokens';
import FitText from '../common/FitText';

type Props = {
  profile: any; // ZodiacProfile with rawPerson
};


export default function PersonFront({ profile }: Props) {
  const p: PersonProfile | undefined = profile.rawPerson;
  const name = p?.name || profile.sign;
  const age = p?.age;
  const photo = p?.photo;
  const displayName = age ? `${name}, ${age}` : name;

  const content = (
    <View style={styles.inner}>
      <View style={[styles.topRow, photo ? styles.topRowOnPhoto : null]}>
        {!photo ? (
          <View style={styles.avatarOrb}>
            <FitText style={styles.avatarEmoji} maxLines={1} minFontSize={18}>{profile.symbol}</FitText>
          </View>
        ) : null}
        <View style={styles.topText}>
          <FitText style={[styles.name, photo ? styles.nameOnPhoto : null]} maxLines={1} minFontSize={16}>{displayName}</FitText>
          <FitText style={[styles.subtitle, photo ? styles.subtitleOnPhoto : null]} maxLines={1} minFontSize={12}>{profile.compatibilityHint}</FitText>
        </View>
      </View>

      <View style={[styles.infoPanel, photo ? styles.infoPanelOnPhoto : null]}>
        <View style={styles.taglineWrap}>
          <FitText style={[styles.tagline, photo ? styles.taglineOnPhoto : null]} minFontSize={12}>{profile.tagline}</FitText>
        </View>

        <View style={styles.traitWrap}>
          {(profile.traits || []).map((t: string) => (
            <View key={t} style={[styles.traitChip, photo ? styles.traitChipOnPhoto : null]}>
              <FitText style={[styles.traitText, photo ? styles.traitTextOnPhoto : null]} maxLines={1} minFontSize={10}>{t}</FitText>
            </View>
          ))}
        </View>
      </View>
    </View>
  );

  if (photo) {
    return (
      <ImageBackground source={photo} style={styles.container} imageStyle={styles.bgImage}>
        <LinearGradient
          colors={['rgba(0,0,0,0.12)', 'rgba(0,0,0,0.55)', 'rgba(0,0,0,0.9)']}
          locations={[0, 0.42, 1]}
          style={StyleSheet.absoluteFill}
        />
        {content}
      </ImageBackground>
    );
  }

  return <View style={styles.container}>{content}</View>;
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  bgImage: {
    borderRadius: radius.lg,
    resizeMode: 'cover',
  },
  inner: {
    flex: 1,
    padding: spacing.md,
    justifyContent: 'flex-end',
  },
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  topRowOnPhoto: {
    marginBottom: spacing.sm,
  },
  avatarOrb: {
    width: 72,
    height: 72,
    borderRadius: radius.pill,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  avatarEmoji: {
    fontSize: 32,
    textAlign: 'center',
  },
  topText: {
    flex: 1,
  },
  name: {
    ...type.title1,
    fontWeight: '800',
    color: colors.text,
  },
  nameOnPhoto: {
    color: '#fff',
    textShadowColor: 'rgba(0,0,0,0.6)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 4,
  },
  subtitle: {
    ...type.body,
    color: colors.textMuted,
  },
  subtitleOnPhoto: {
    color: 'rgba(255,255,255,0.75)',
  },
  taglineWrap: {
    marginTop: 0,
  },
  tagline: {
    ...type.body,
    color: colors.text,
    fontWeight: '400',
    lineHeight: 24,
  },
  taglineOnPhoto: {
    color: 'rgba(255,255,255,0.92)',
  },
  traitWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
    marginTop: spacing.md,
  },
  infoPanel: {
    marginTop: spacing.md,
  },
  infoPanelOnPhoto: {
    backgroundColor: 'rgba(0,0,0,0.56)',
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.22)',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.sm,
  },
  traitChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: radius.pill,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  traitChipOnPhoto: {
    backgroundColor: 'rgba(0,0,0,0.58)',
    borderColor: 'rgba(255,255,255,0.32)',
  },
  traitText: {
    color: colors.text,
    fontSize: 12,
    fontWeight: '700',
  },
  traitTextOnPhoto: {
    color: 'rgba(255,255,255,0.96)',
  },
});