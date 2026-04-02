import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React, { useMemo, useRef } from 'react';
import {
    Platform,
    Pressable,
    ScrollView,
    Share,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import ViewShot, { captureRef } from 'react-native-view-shot';
import { useStoredBirthdate } from '../hooks/useStoredBirthdate';
import { getChineseSign, getWesternSign } from '../utils/astrology';

const PALETTE = {
  bg: '#F3EFE6',
  surface: '#E8E1D2',
  surfaceSoft: '#EFE8DB',
  border: '#CDBB9A',
  text: '#4E4334',
  textSoft: '#6A5C49',
  accent: '#A8895A',
  buttonText: '#FFFDF8',
};

const SIGN_DETAILS: Record<
  string,
  {
    archetype: string;
    snippet: string;
    traits: string[];
    energy: string;
    datingStyle: string;
  }
> = {
  Aries: {
    archetype: 'The Initiator',
    snippet: 'Fire, instinct, and fearless momentum.',
    traits: ['Bold', 'Magnetic', 'Direct'],
    energy: 'Fast-moving, charged, and impossible to ignore.',
    datingStyle: 'Chases spark, honesty, and intensity.',
  },
  Taurus: {
    archetype: 'The Devoted',
    snippet: 'Grounded presence with sensual gravity.',
    traits: ['Steady', 'Loyal', 'Magnetic'],
    energy: 'Calm, rooted, and quietly luxurious.',
    datingStyle: 'Values trust, consistency, and chemistry.',
  },
  Gemini: {
    archetype: 'The Spark',
    snippet: 'Fast charm and restless brilliance.',
    traits: ['Curious', 'Social', 'Electric'],
    energy: 'Airy, witty, and mentally magnetic.',
    datingStyle: 'Needs banter, variety, and stimulation.',
  },
  Cancer: {
    archetype: 'The Nurturer',
    snippet: 'Soft power with emotional depth.',
    traits: ['Intuitive', 'Protective', 'Deep'],
    energy: 'Sensitive, loyal, and emotionally perceptive.',
    datingStyle: 'Moves with feeling, care, and depth.',
  },
  Leo: {
    archetype: 'The Radiant',
    snippet: 'Warmth, charisma, and star power.',
    traits: ['Confident', 'Warm', 'Expressive'],
    energy: 'Big-hearted, visible, and full of glow.',
    datingStyle: 'Craves passion, play, and admiration.',
  },
  Virgo: {
    archetype: 'The Refiner',
    snippet: 'Precision, intention, and quiet intensity.',
    traits: ['Thoughtful', 'Sharp', 'Intentional'],
    energy: 'Measured, observant, and deeply intentional.',
    datingStyle: 'Shows love through effort and detail.',
  },
  Libra: {
    archetype: 'The Harmonizer',
    snippet: 'Elegant magnetism and social gravity.',
    traits: ['Charming', 'Balanced', 'Romantic'],
    energy: 'Pleasant, polished, and relationally tuned-in.',
    datingStyle: 'Seeks beauty, balance, and mutual effort.',
  },
  Scorpio: {
    archetype: 'The Alchemist',
    snippet: 'Mystery, depth, and undeniable force.',
    traits: ['Intense', 'Private', 'Transformative'],
    energy: 'Magnetic, private, and emotionally powerful.',
    datingStyle: 'Seeks depth, loyalty, and truth.',
  },
  Sagittarius: {
    archetype: 'The Seeker',
    snippet: 'Freedom-driven energy with radiant optimism.',
    traits: ['Bold', 'Adventurous', 'Honest'],
    energy: 'Open, lively, and future-facing.',
    datingStyle: 'Needs honesty, adventure, and momentum.',
  },
  Capricorn: {
    archetype: 'The Builder',
    snippet: 'Composure, ambition, and enduring power.',
    traits: ['Driven', 'Reliable', 'Composed'],
    energy: 'Structured, calm, and built for longevity.',
    datingStyle: 'Shows care through consistency and action.',
  },
  Aquarius: {
    archetype: 'The Visionary',
    snippet: 'Independent energy with future-facing pull.',
    traits: ['Original', 'Open-minded', 'Detached'],
    energy: 'Independent, surprising, and mentally expansive.',
    datingStyle: 'Needs freedom, intrigue, and authenticity.',
  },
  Pisces: {
    archetype: 'The Dreamer',
    snippet: 'Soulful intuition and fluid emotional depth.',
    traits: ['Tender', 'Imaginative', 'Compassionate'],
    energy: 'Soft, creative, and emotionally fluid.',
    datingStyle: 'Leads with intuition, romance, and feeling.',
  },
};

const luxurySerif = Platform.select({
  ios: 'Georgia',
  android: 'serif',
  default: 'serif',
});

export default function IdentityScreen() {
  const { selectedDate } = useStoredBirthdate(new Date());
  const cardRef = useRef<ViewShot | null>(null);

  const westernSign = getWesternSign(selectedDate);
  const chineseSign = getChineseSign(selectedDate);

  const details = useMemo(() => {
    return (
      SIGN_DETAILS[westernSign] ?? {
        archetype: 'Cosmic Original',
        snippet: 'A rare blend of instinct, charm, and depth.',
        traits: ['Layered', 'Magnetic', 'Distinct'],
        energy: 'Balanced between instinct and presence.',
        datingStyle: 'Drawn to chemistry with emotional depth.',
      }
    );
  }, [westernSign]);

  const handleBack = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.back();
  };

  const handleShare = async () => {
    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);

      if (!cardRef.current) {
        await Share.share({
          message:
            `My Zodian identity:\n` +
            `${westernSign} × ${chineseSign}\n` +
            `${details.archetype}\n\n` +
            `${details.snippet}`,
        });
        return;
      }

      const uri = await captureRef(cardRef, {
        format: 'png',
        quality: 1,
      });

      await Share.share({
        url: uri,
        message: 'My Zodian identity ✨',
      });
    } catch {
      await Share.share({
        message:
          `My Zodian identity:\n` +
          `${westernSign} × ${chineseSign}\n` +
          `${details.archetype}\n\n` +
          `${details.snippet}`,
      });
    }
  };

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <LinearGradient
        colors={[PALETTE.bg, '#EEE7DA']}
        style={StyleSheet.absoluteFill}
      />

      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.topRow}>
          <Pressable style={styles.topButton} onPress={handleBack}>
            <Text style={styles.topButtonText}>Back</Text>
          </Pressable>

          <Pressable style={styles.topButton} onPress={handleShare}>
            <Text style={styles.topButtonText}>Share</Text>
          </Pressable>
        </View>

        <View style={styles.logoWrap}>
          <View style={styles.logoGlow} />
          <Text style={styles.logoText}>ZODIAN</Text>
        </View>

        <Text style={styles.kicker}>IDENTITY CARD</Text>

        <ViewShot
          ref={cardRef}
          options={{
            format: 'png',
            quality: 1,
            result: 'tmpfile',
          }}
          style={styles.captureWrap}
        >
          <View style={styles.cardShell}>
            <View style={styles.innerCard}>
              <View style={styles.signPairWrap}>
                <View style={styles.signHalf}>
                  <Text style={styles.signLabel}>Western</Text>
                  <Text style={styles.signText}>{westernSign}</Text>
                </View>

                <View style={styles.centerDividerWrap}>
                  <View style={styles.centerDivider} />
                </View>

                <View style={styles.signHalf}>
                  <Text style={styles.signLabel}>Eastern</Text>
                  <Text style={styles.signText}>{chineseSign}</Text>
                </View>
              </View>

              <Text style={styles.archetype}>{details.archetype}</Text>
              <Text style={styles.snippet}>{details.snippet}</Text>

              <View style={styles.traitsWrap}>
                {details.traits.map((trait) => (
                  <View key={trait} style={styles.traitChip}>
                    <Text style={styles.traitText}>{trait}</Text>
                  </View>
                ))}
              </View>

              <View style={styles.divider} />

              <View style={styles.section}>
                <Text style={styles.sectionLabel}>Core energy</Text>
                <Text style={styles.sectionBody}>{details.energy}</Text>
              </View>

              <View style={styles.section}>
                <Text style={styles.sectionLabel}>Dating style</Text>
                <Text style={styles.sectionBody}>{details.datingStyle}</Text>
              </View>
            </View>
          </View>
        </ViewShot>

        <Text style={styles.shareCaption}>Share your cosmic identity ✦</Text>

        <View style={styles.ctaWrap}>
          <Pressable style={styles.primaryButton} onPress={handleShare}>
            <LinearGradient
              colors={['#B89767', PALETTE.accent]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.primaryButtonGradient}
            >
              <Text style={styles.primaryButtonText}>Share Identity</Text>
            </LinearGradient>
          </Pressable>

          <Pressable
            style={styles.secondaryButton}
            onPress={() => router.replace('/(tabs)')}
          >
            <Text style={styles.secondaryButtonText}>Enter Zodian</Text>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: PALETTE.bg,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 32,
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 18,
  },
  topButton: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    backgroundColor: PALETTE.surfaceSoft,
    borderWidth: 1,
    borderColor: PALETTE.border,
  },
  topButtonText: {
    color: PALETTE.text,
    fontSize: 14,
    fontWeight: '600',
  },
  logoWrap: {
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    minHeight: 52,
  },
  logoGlow: {
    position: 'absolute',
    width: 220,
    height: 56,
    borderRadius: 999,
    backgroundColor: '#E7DECD',
  },
  logoText: {
    color: PALETTE.accent,
    fontSize: 28,
    letterSpacing: 5,
    fontWeight: '700',
    fontFamily: luxurySerif,
  },
  kicker: {
    color: PALETTE.accent,
    textAlign: 'center',
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700',
    marginBottom: 20,
  },
  captureWrap: {
    marginBottom: 12,
  },
  cardShell: {
    borderRadius: 32,
    padding: 12,
    borderWidth: 1,
    borderColor: PALETTE.border,
    backgroundColor: PALETTE.surface,
    overflow: 'hidden',
  },
  innerCard: {
    borderRadius: 28,
    paddingHorizontal: 20,
    paddingVertical: 24,
    backgroundColor: PALETTE.surfaceSoft,
    overflow: 'hidden',
  },
  signPairWrap: {
    width: '100%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 18,
  },
  signHalf: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 8,
  },
  signLabel: {
    color: PALETTE.textSoft,
    fontSize: 11,
    letterSpacing: 1.5,
    textTransform: 'uppercase',
    marginBottom: 10,
    fontWeight: '600',
  },
  signText: {
    color: PALETTE.text,
    fontSize: 32,
    lineHeight: 38,
    fontWeight: '700',
    textAlign: 'center',
  },
  centerDividerWrap: {
    width: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  centerDivider: {
    width: 8,
    height: 8,
    borderRadius: 999,
    backgroundColor: PALETTE.accent,
  },
  archetype: {
    color: PALETTE.text,
    fontSize: 30,
    lineHeight: 36,
    fontWeight: '700',
    textAlign: 'center',
    marginBottom: 10,
  },
  snippet: {
    color: PALETTE.textSoft,
    fontSize: 16,
    lineHeight: 24,
    textAlign: 'center',
    marginBottom: 18,
    fontWeight: '500',
  },
  traitsWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    justifyContent: 'center',
    marginBottom: 18,
  },
  traitChip: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    backgroundColor: PALETTE.bg,
    borderWidth: 1,
    borderColor: PALETTE.border,
  },
  traitText: {
    color: PALETTE.text,
    fontSize: 14,
    fontWeight: '600',
  },
  divider: {
    height: 1,
    backgroundColor: PALETTE.border,
    marginBottom: 16,
  },
  section: {
    marginBottom: 14,
  },
  sectionLabel: {
    color: PALETTE.accent,
    fontSize: 11,
    letterSpacing: 1.6,
    textTransform: 'uppercase',
    fontWeight: '700',
    marginBottom: 8,
  },
  sectionBody: {
    color: PALETTE.textSoft,
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '500',
  },
  metaRow: {
    marginTop: 4,
  },
  metaPill: {
    borderRadius: 18,
    padding: 14,
    backgroundColor: PALETTE.bg,
    borderWidth: 1,
    borderColor: PALETTE.border,
  },
  metaLabel: {
    color: PALETTE.textSoft,
    fontSize: 12,
    marginBottom: 6,
    fontWeight: '600',
  },
  metaValue: {
    color: PALETTE.text,
    fontSize: 16,
    fontWeight: '600',
  },
  shareCaption: {
    color: PALETTE.textSoft,
    textAlign: 'center',
    marginBottom: 16,
    fontSize: 13,
    fontWeight: '500',
  },
  ctaWrap: {
    gap: 12,
  },
  primaryButton: {
    borderRadius: 999,
    overflow: 'hidden',
  },
  primaryButtonGradient: {
    paddingVertical: 16,
    alignItems: 'center',
    borderRadius: 999,
  },
  primaryButtonText: {
    color: PALETTE.buttonText,
    fontSize: 17,
    fontWeight: '700',
  },
  secondaryButton: {
    borderRadius: 999,
    paddingVertical: 16,
    alignItems: 'center',
    backgroundColor: PALETTE.surfaceSoft,
    borderWidth: 1,
    borderColor: PALETTE.border,
  },
  secondaryButtonText: {
    color: PALETTE.text,
    fontSize: 16,
    fontWeight: '600',
  },
});