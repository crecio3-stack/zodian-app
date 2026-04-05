import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
    Pressable,
    Share,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import Reanimated, {
    interpolate,
    useAnimatedStyle,
    useSharedValue,
    withDelay,
    withRepeat,
    withSequence,
    withTiming,
} from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';
import Svg, { Circle, G, Path } from 'react-native-svg';
import ViewShot, { captureRef } from 'react-native-view-shot';
import { useStoredBirthdate } from '../../hooks/useStoredBirthdate';
import { useStoredName } from '../../hooks/useStoredName';
import { EVENTS, trackAppEvent, trackScreenView } from '../../lib/analytics/analytics';
import { clearOnboardingProgress, saveOnboardingStep } from '../../lib/storage/onboardingProgress';
import { colors, radius, spacing } from '../../styles/theme';
import { getChineseSign, getWesternSign } from '../../utils/astrology';

const MAX_SUMMARY_CHARS = 320;
const ACTIONS_AREA_HEIGHT = 120;
const SHARE_MESSAGE = 'Shared from Zodian. Discover your cosmic identity and daily relationship guidance in the Zodian app.';

function trimToSentenceBoundary(input: string, maxChars: number): string {
  if (input.length <= maxChars) return input;
  const sliced = input.slice(0, maxChars);
  const lastPeriod = sliced.lastIndexOf('.');
  if (lastPeriod > Math.floor(maxChars * 0.65)) {
    return sliced.slice(0, lastPeriod + 1).trim();
  }
  const lastSpace = sliced.lastIndexOf(' ');
  const clean = (lastSpace > 0 ? sliced.slice(0, lastSpace) : sliced).trim();
  return clean.endsWith('.') ? clean : `${clean}.`;
}

function compactFirstName(name?: string | null): string {
  const first = (name ?? '').trim().split(/\s+/)[0] ?? '';
  if (!first) return '';
  return first.length > 14 ? `${first.slice(0, 14)}...` : first;
}

const SIGN_DETAILS: Record<string, { archetype: string; snippet: string; traits: string[] }> = {
  Aries: { archetype: 'The Initiator', snippet: 'Fire, instinct, and fearless momentum.', traits: ['Bold', 'Magnetic', 'Direct'] },
  Taurus: { archetype: 'The Devoted', snippet: 'Grounded presence with sensual gravity.', traits: ['Steady', 'Loyal', 'Magnetic'] },
  Gemini: { archetype: 'The Spark', snippet: 'Fast charm and restless brilliance.', traits: ['Curious', 'Social', 'Electric'] },
  Cancer: { archetype: 'The Nurturer', snippet: 'Soft power with emotional depth.', traits: ['Intuitive', 'Protective', 'Deep'] },
  Leo: { archetype: 'The Radiant', snippet: 'Warmth, charisma, and star power.', traits: ['Confident', 'Warm', 'Expressive'] },
  Virgo: { archetype: 'The Refiner', snippet: 'Precision, intention, and quiet intensity.', traits: ['Thoughtful', 'Sharp', 'Intentional'] },
  Libra: { archetype: 'The Harmonizer', snippet: 'Elegant magnetism and social gravity.', traits: ['Charming', 'Balanced', 'Romantic'] },
  Scorpio: { archetype: 'The Alchemist', snippet: 'Mystery, depth, and undeniable force.', traits: ['Intense', 'Private', 'Transformative'] },
  Sagittarius: { archetype: 'The Seeker', snippet: 'Freedom-driven energy with radiant optimism.', traits: ['Bold', 'Adventurous', 'Honest'] },
  Capricorn: { archetype: 'The Builder', snippet: 'Composure, ambition, and enduring power.', traits: ['Driven', 'Reliable', 'Composed'] },
  Aquarius: { archetype: 'The Visionary', snippet: 'Independent energy with future-facing pull.', traits: ['Original', 'Open-minded', 'Detached'] },
  Pisces: { archetype: 'The Dreamer', snippet: 'Soulful intuition and fluid emotional depth.', traits: ['Tender', 'Imaginative', 'Compassionate'] },
};

const WESTERN_CORE_INSIGHT: Record<string, string> = {
  Aries: 'direct, fast-moving, and motivated by challenge',
  Taurus: 'steady, loyal, and oriented toward lasting security',
  Gemini: 'curious, verbal, and energized by variety',
  Cancer: 'protective, intuitive, and deeply feeling',
  Leo: 'expressive, warm, and driven to create impact',
  Virgo: 'precise, discerning, and quietly improvement-focused',
  Libra: 'relational, diplomatic, and harmony-seeking',
  Scorpio: 'intense, private, and emotionally strategic',
  Sagittarius: 'adventurous, candid, and growth-oriented',
  Capricorn: 'disciplined, pragmatic, and legacy-minded',
  Aquarius: 'independent, original, and systems-focused',
  Pisces: 'empathetic, imaginative, and spiritually attuned',
};

const CHINESE_INSTINCT_LAYER: Record<string, string> = {
  Rat: 'social intelligence and tactical timing under pressure',
  Ox: 'patience, endurance, and calm conviction',
  Tiger: 'courageous momentum and bold risk appetite',
  Rabbit: 'sensitivity, diplomacy, and emotional radar',
  Dragon: 'confidence, ambition, and magnetic force',
  Snake: 'discernment, selectivity, and subtle strategy',
  Horse: 'independence, speed, and freedom-seeking drive',
  Goat: 'creative sensitivity and values-led tenderness',
  Monkey: 'quick wit, adaptability, and inventive thinking',
  Rooster: 'precision, standards, and expressive clarity',
  Dog: 'loyalty, integrity, and protective instincts',
  Pig: 'warmth, generosity, and relational openness',
};

const WESTERN_PANEL_DETAILS: Record<string, { qualities: string[]; quirks: string[] }> = {
  Aries: { qualities: ['Bold', 'Direct', 'Driven', 'Brave'], quirks: ['Impulsive', 'Blunt', 'Restless', 'Combative'] },
  Taurus: { qualities: ['Steady', 'Loyal', 'Sensual', 'Reliable'], quirks: ['Stubborn', 'Rigid', 'Possessive', 'Inflexible'] },
  Gemini: { qualities: ['Curious', 'Witty', 'Adaptable', 'Expressive'], quirks: ['Scattered', 'Restless', 'Uneven', 'Worried'] },
  Cancer: { qualities: ['Intuitive', 'Protective', 'Nurturing', 'Loyal'], quirks: ['Moody', 'Guarded', 'Clingy', 'Defensive'] },
  Leo: { qualities: ['Warm', 'Radiant', 'Confident', 'Generous'], quirks: ['Proud', 'Dramatic', 'Stubborn', 'Needy'] },
  Virgo: { qualities: ['Precise', 'Thoughtful', 'Practical', 'Devoted'], quirks: ['Critical', 'Anxious', 'Exacting', 'Nitpicky'] },
  Libra: { qualities: ['Charming', 'Balanced', 'Diplomatic', 'Romantic'], quirks: ['Indecisive', 'Avoidant', 'Pleasing', 'Passive'] },
  Scorpio: { qualities: ['Magnetic', 'Deep', 'Focused', 'Loyal'], quirks: ['Jealous', 'Secretive', 'Intense', 'Controlling'] },
  Sagittarius: { qualities: ['Honest', 'Adventurous', 'Optimistic', 'Independent'], quirks: ['Tactless', 'Restless', 'Guarded', 'Impulsive'] },
  Capricorn: { qualities: ['Driven', 'Reliable', 'Disciplined', 'Strategic'], quirks: ['Reserved', 'Rigid', 'Work-first', 'Guarded'] },
  Aquarius: { qualities: ['Original', 'Visionary', 'Independent', 'Open'], quirks: ['Detached', 'Stubborn', 'Unstable', 'Contrarian'] },
  Pisces: { qualities: ['Tender', 'Imaginative', 'Empathic', 'Creative'], quirks: ['Escapist', 'Porous', 'Idealistic', 'Absorbing'] },
};

const CHINESE_PANEL_DETAILS: Record<string, { qualities: string[]; quirks: string[] }> = {
  Rat: { qualities: ['Sharp', 'Resourceful', 'Charismatic', 'Adaptive'], quirks: ['Nervous', 'Meddling', 'Cunning', 'Scheming'] },
  Ox: { qualities: ['Patient', 'Dependable', 'Grounded', 'Steadfast'], quirks: ['Rigid', 'Stubborn', 'Guarded', 'Unyielding'] },
  Tiger: { qualities: ['Brave', 'Assertive', 'Dynamic', 'Protective'], quirks: ['Reckless', 'Dramatic', 'Impulsive', 'Dominating'] },
  Rabbit: { qualities: ['Gentle', 'Diplomatic', 'Refined', 'Empathic'], quirks: ['Avoidant', 'Anxious', 'Passive', 'Timid'] },
  Dragon: { qualities: ['Magnetic', 'Ambitious', 'Confident', 'Influential'], quirks: ['Dominant', 'Intense', 'Proud', 'Demanding'] },
  Snake: { qualities: ['Strategic', 'Refined', 'Perceptive', 'Selective'], quirks: ['Suspicious', 'Aloof', 'Secretive', 'Calculating'] },
  Horse: { qualities: ['Energetic', 'Free', 'Independent', 'Bold'], quirks: ['Impatient', 'Fickle', 'Restless', 'Rebellious'] },
  Goat: { qualities: ['Creative', 'Kind', 'Artistic', 'Supportive'], quirks: ['Insecure', 'Hesitant', 'Sensitive', 'Indecisive'] },
  Monkey: { qualities: ['Witty', 'Adaptive', 'Inventive', 'Playful'], quirks: ['Erratic', 'Trickster', 'Fidgety', 'Manipulative'] },
  Rooster: { qualities: ['Exact', 'Expressive', 'Organized', 'Disciplined'], quirks: ['Critical', 'Sharp', 'Exacting', 'Showy'] },
  Dog: { qualities: ['Loyal', 'Principled', 'Protective', 'Sincere'], quirks: ['Worried', 'Judgmental', 'Defensive', 'Pessimistic'] },
  Pig: { qualities: ['Warm', 'Generous', 'Honest', 'Sociable'], quirks: ['Indulgent', 'Naive', 'Gullible', 'Avoidant'] },
};

function TarotCorner({ rotation, style }: { rotation: number; style: any }) {
  return (
    <View pointerEvents="none" style={style}>
      <Svg width={34} height={34} viewBox="0 0 40 40" fill="none" style={{ transform: [{ rotate: `${rotation}deg` }] }}>
        <G opacity={0.72}>
          <Path d="M6 30C18 30 30 18 30 6" stroke="rgba(236,198,112,0.75)" strokeWidth={1.6} />
          <Path d="M12 30C21 30 30 21 30 12" stroke="rgba(236,198,112,0.44)" strokeWidth={1.2} />
          <Path d="M18.2 11.5L20 6.8L21.8 11.5L26.5 13.3L21.8 15.1L20 19.8L18.2 15.1L13.5 13.3L18.2 11.5Z" fill="rgba(251,230,170,0.78)" />
          <Circle cx={30} cy={6} r={1.5} fill="rgba(251,230,170,0.86)" />
        </G>
      </Svg>
    </View>
  );
}

function ZodiacTexture({ style }: { style?: any }) {
  return (
    <View pointerEvents="none" style={[styles.backTextureWrap, style]}>
      <Svg width="100%" height="100%" viewBox="0 0 360 520" fill="none">
        <G opacity={0.12}>
          <Path d="M34 144C120 80 246 84 326 160" stroke="rgba(236,198,112,0.6)" strokeWidth={1.2} />
          <Path d="M30 312C116 246 246 246 330 318" stroke="rgba(236,198,112,0.45)" strokeWidth={1.1} />
          <Circle cx={86} cy={122} r={2.2} fill="rgba(250,224,156,0.82)" />
          <Circle cx={152} cy={102} r={1.8} fill="rgba(250,224,156,0.74)" />
          <Circle cx={224} cy={114} r={2.1} fill="rgba(250,224,156,0.8)" />
          <Circle cx={286} cy={148} r={1.7} fill="rgba(250,224,156,0.72)" />
          <Path d="M86 122L152 102L224 114L286 148" stroke="rgba(250,224,156,0.5)" strokeWidth={1} />
        </G>
      </Svg>
    </View>
  );
}

function CosmicGlyph() {
  return (
    <View pointerEvents="none" style={styles.cosmicGlyphWrap}>
      <Svg width={28} height={28} viewBox="0 0 28 28" fill="none">
        <Circle cx={14} cy={14} r={7.4} stroke="rgba(241,208,126,0.78)" strokeWidth={1.2} />
        <Path d="M14 4.8V23.2M4.8 14H23.2" stroke="rgba(241,208,126,0.48)" strokeWidth={1} />
        <Path d="M13 8.6L14 6L15 8.6L17.6 9.6L15 10.6L14 13.2L13 10.6L10.4 9.6L13 8.6Z" fill="rgba(251,230,170,0.9)" />
      </Svg>
    </View>
  );
}

export default function RevealScreen() {
  const { selectedDate } = useStoredBirthdate(new Date());
  const { name } = useStoredName();
  const westernSign = getWesternSign(selectedDate);
  const chineseSign = getChineseSign(selectedDate);

  const details = useMemo(
    () =>
      SIGN_DETAILS[westernSign] ?? {
        archetype: 'Cosmic Original',
        snippet: 'A rare blend of instinct, charm, and depth.',
        traits: ['Layered', 'Magnetic', 'Distinct'],
      },
    [westernSign]
  );

  const cardSummary = useMemo(() => {
    const [traitA, traitB] = details.traits;
    const displayName = compactFirstName(name);
    const westernCore = WESTERN_CORE_INSIGHT[westernSign] ?? 'clear style and emotional nuance';
    const chineseLayer = CHINESE_INSTINCT_LAYER[chineseSign] ?? 'instinctive emotional timing';
    const sentence1 = `${displayName ? `${displayName}, ` : ''}your Western ${westernSign} identity shows up as ${westernCore}.`;
    const sentence2 = `Your Eastern ${chineseSign} pattern adds ${chineseLayer}.`;
    const sentence3 = `When combined, you come across ${traitA.toLowerCase()} first, but your deeper rhythm is ${traitB.toLowerCase()} and more intentional.`;
    const sentence4 = `${details.snippet} This is why your connections often feel immediate, then deepen with time.`;
    const sentence5 = `Overall, this blend creates ${details.archetype} energy: expressive on the outside, instinctive underneath.`;
    return trimToSentenceBoundary(`${sentence1} ${sentence2} ${sentence3} ${sentence4} ${sentence5}`, MAX_SUMMARY_CHARS);
  }, [details.archetype, details.snippet, details.traits, westernSign, chineseSign, name]);

  const westernPanel = WESTERN_PANEL_DETAILS[westernSign] ?? { qualities: ['Distinct', 'Layered', 'Focused', 'Warm'], quirks: ['Complex', 'Private', 'Guarded', 'Rigid'] };
  const chinesePanel = CHINESE_PANEL_DETAILS[chineseSign] ?? { qualities: ['Instinctive', 'Magnetic', 'Adaptive', 'Perceptive'], quirks: ['Unpredictable', 'Intense', 'Guarded', 'Reactive'] };
  const westernTraits = [...westernPanel.qualities, ...westernPanel.quirks].slice(0, 6);
  const chineseTraits = [...chinesePanel.qualities, ...chinesePanel.quirks].slice(0, 6);

  const toTraitRows = (traits: string[]) => {
    const rows: [string, string][] = [];
    for (let i = 0; i < traits.length; i += 2) {
      rows.push([traits[i] ?? '', traits[i + 1] ?? '']);
    }
    return rows;
  };

  const westernTraitRows = toTraitRows(westernTraits);
  const chineseTraitRows = toTraitRows(chineseTraits);

  const [revealed, setRevealed] = useState(false);
  const [isCardFlipped, setIsCardFlipped] = useState(false);
  const cardShareRef = useRef<ViewShot | null>(null);
  const hasTriggeredRevealRef = useSharedValue(0);

  const cardFlip = useSharedValue(0);
  const heartbeat = useSharedValue(0);
  const wowProgress = useSharedValue(1);
  const wowOpacity = useSharedValue(0);
  const FLIP_DURATION_MS = 560;

  useEffect(() => {
    trackScreenView('onboarding_reveal', { westernSign, chineseSign }).catch(() => {});
    trackAppEvent(EVENTS.ONBOARDING_STEP_VIEWED, {
      step: 'reveal',
      stepIndex: 4,
      westernSign,
      chineseSign,
    }).catch(() => {});
    saveOnboardingStep('reveal').catch(() => {});
  }, [westernSign, chineseSign]);

  useEffect(() => {
    if (isCardFlipped) {
      heartbeat.value = withTiming(0, { duration: 160 });
      return;
    }

    heartbeat.value = withRepeat(
      withSequence(withTiming(1, { duration: 540 }), withTiming(0, { duration: 540 })),
      -1,
      true
    );
  }, [heartbeat, isCardFlipped]);

  const frontFaceStyle = useAnimatedStyle(() => ({
    transform: [{ perspective: 1400 }, { rotateY: `${interpolate(cardFlip.value, [0, 1], [0, 180])}deg` }],
    backfaceVisibility: 'hidden',
  }));

  const backFaceStyle = useAnimatedStyle(() => ({
    transform: [{ perspective: 1400 }, { rotateY: `${interpolate(cardFlip.value, [0, 1], [180, 360])}deg` }],
    backfaceVisibility: 'hidden',
  }));

  const cardBeatStyle = useAnimatedStyle(() => ({
    transform: [{ scale: interpolate(heartbeat.value, [0, 1], [1, 1.025]) }],
  }));

  const wowHaloPrimaryStyle = useAnimatedStyle(() => ({
    opacity: wowOpacity.value * interpolate(wowProgress.value, [0, 0.55, 1], [1, 0.5, 0]),
    transform: [{ scale: interpolate(wowProgress.value, [0, 1], [0.28, 3.8]) }],
  }));

  const wowHaloSecondaryStyle = useAnimatedStyle(() => ({
    opacity: wowOpacity.value * interpolate(wowProgress.value, [0, 0.5, 1], [0.85, 0.4, 0]),
    transform: [{ scale: interpolate(wowProgress.value, [0, 1], [0.18, 3.2]) }],
  }));

  const wowGrainStyle = useAnimatedStyle(() => ({
    opacity: wowOpacity.value * interpolate(wowProgress.value, [0, 1], [0.12, 0]),
  }));

  const completeRevealIfNeeded = async () => {
    if (hasTriggeredRevealRef.value === 1) return;
    hasTriggeredRevealRef.value = 1;
    setRevealed(true);
    setIsCardFlipped(true);
    cardFlip.value = withTiming(1, { duration: FLIP_DURATION_MS });
    wowProgress.value = 0;
    wowOpacity.value = 0;
    wowOpacity.value = withSequence(
      withTiming(0.55, { duration: 420 }),
      withDelay(120, withTiming(0, { duration: 1800 }))
    );
    wowProgress.value = withTiming(1, { duration: 2400 });
    try {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } catch {}
    trackAppEvent(EVENTS.ONBOARDING_IDENTITY_REVEALED, {
      westernSign,
      chineseSign,
      archetype: details.archetype,
      hasName: Boolean(name?.trim()),
    }).catch(() => {});
  };

  const handleEnter = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    await trackAppEvent(EVENTS.ONBOARDING_COMPLETE, {
      westernSign,
      chineseSign,
      archetype: details.archetype,
      hasName: Boolean(name?.trim()),
    }).catch(() => {});
    await clearOnboardingProgress();
    router.replace('/(tabs)');
  };

  const handleCardPress = async () => {
    const nextFlipped = !isCardFlipped;

    if (nextFlipped && !revealed) {
      await completeRevealIfNeeded();
    } else {
      setIsCardFlipped(nextFlipped);
      cardFlip.value = withTiming(nextFlipped ? 1 : 0, { duration: FLIP_DURATION_MS });
    }

    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } catch {}
  };

  const handleShare = async () => {
    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      if (cardShareRef.current) {
        const uri = await captureRef(cardShareRef, {
          format: 'png',
          quality: 1,
          result: 'tmpfile',
        });

        await Share.share({
          url: uri,
          message: SHARE_MESSAGE,
        });
        trackAppEvent(EVENTS.ONBOARDING_IDENTITY_SHARED, {
          westernSign,
          chineseSign,
          method: 'image',
        }).catch(() => {});
        return;
      }

      await Share.share({
        message: `${SHARE_MESSAGE}\n\n${westernSign} x ${chineseSign} - ${details.archetype}`,
      });
      trackAppEvent(EVENTS.ONBOARDING_IDENTITY_SHARED, {
        westernSign,
        chineseSign,
        method: 'text',
      }).catch(() => {});
    } catch {
      await Share.share({
        message: `${SHARE_MESSAGE}\n\n${westernSign} x ${chineseSign} - ${details.archetype}`,
      });
      trackAppEvent(EVENTS.ONBOARDING_IDENTITY_SHARED, {
        westernSign,
        chineseSign,
        method: 'fallback_text',
      }).catch(() => {});
    }
  };

  const handleWhyCombo = async () => {
    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } catch {}
    trackAppEvent(EVENTS.BUTTON_TAPPED, {
      button: 'onboarding_why_combo',
      westernSign,
      chineseSign,
    }).catch(() => {});
    await saveOnboardingStep('theory');
    router.push('./theory');
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <LinearGradient colors={['#050505', colors.background, '#020202']} style={StyleSheet.absoluteFill} />

      <View pointerEvents="none" style={styles.wowOverlay}>
        <Reanimated.View style={[styles.wowHaloPrimary, wowHaloPrimaryStyle]} />
        <Reanimated.View style={[styles.wowHaloSecondary, wowHaloSecondaryStyle]} />
        <Reanimated.View style={[styles.wowGrain, wowGrainStyle]} />
      </View>

      <View style={styles.container}>
        <View style={styles.topRow}>
          <Text style={styles.stepPill}>STEP 4 OF 4</Text>
          {revealed ? (
            <Pressable onPress={handleShare} style={({ pressed }) => [styles.miniShareButton, pressed && { opacity: 0.85 }]}>
              <Text style={styles.miniShareText}>Share</Text>
            </Pressable>
          ) : (
            <View style={styles.miniSharePlaceholder} />
          )}
        </View>
        <Text style={styles.stepHint}>Swipe from the left edge anytime to go back.</Text>
        <Text style={styles.title}>{name ? `${name}, tap to reveal your identity` : 'Tap to reveal your identity'}</Text>
        <Text style={styles.subtitle}>
          Tap the card to flip and reveal your identity.
        </Text>

        <Pressable
          style={styles.cardPressable}
          onPress={handleCardPress}
        >
          <ViewShot
            ref={cardShareRef}
            options={{
              format: 'png',
              quality: 1,
              result: 'tmpfile',
            }}
            style={styles.cardTiltWrap}
          >
          <Reanimated.View style={[styles.cardTiltWrap, cardBeatStyle]}>
            <View style={styles.flipWrap}>
              <Reanimated.View
                renderToHardwareTextureAndroid={true}
                shouldRasterizeIOS={false}
                style={[styles.flipCard, frontFaceStyle]}
              >
                <LinearGradient
                  colors={['rgba(255,255,255,0.05)', 'rgba(255,255,255,0.02)', 'rgba(216,184,107,0.04)']}
                  style={StyleSheet.absoluteFill}
                />

                <ZodiacTexture style={styles.frontTextureWrap} />
                <View pointerEvents="none" style={styles.frontBorderGlow} />
                <View pointerEvents="none" style={styles.frontBorderLine} />
                <TarotCorner rotation={0} style={styles.cornerTopLeft} />
                <TarotCorner rotation={90} style={styles.cornerTopRight} />
                <TarotCorner rotation={180} style={styles.cornerBottomRight} />
                <TarotCorner rotation={270} style={styles.cornerBottomLeft} />

                <View style={styles.preRevealCenter}>
                  <CosmicGlyph />
                  <Text style={styles.cardTitle}>Your cosmic profile is ready</Text>
                  <Text style={styles.cardHint}>
                    Tap to flip this card.
                  </Text>
                </View>
              </Reanimated.View>

              <Reanimated.View
                renderToHardwareTextureAndroid={true}
                shouldRasterizeIOS={false}
                style={[styles.flipCard, styles.flipBack, backFaceStyle]}
              >
                <LinearGradient
                  colors={['rgba(255,255,255,0.05)', 'rgba(255,255,255,0.02)', 'rgba(216,184,107,0.04)']}
                  style={StyleSheet.absoluteFill}
                />

                <ZodiacTexture />
                <View pointerEvents="none" style={styles.backBorderGlow} />
                <View pointerEvents="none" style={styles.backBorderLine} />
                <TarotCorner rotation={0} style={styles.cornerTopLeft} />
                <TarotCorner rotation={90} style={styles.cornerTopRight} />
                <TarotCorner rotation={180} style={styles.cornerBottomRight} />
                <TarotCorner rotation={270} style={styles.cornerBottomLeft} />

                <View style={styles.backFaceContent}>
                  <View style={styles.signRow}>
                    <View style={styles.signPill}>
                      <Text style={styles.signLabel}>Western</Text>
                      <Text
                        style={styles.signText}
                        numberOfLines={1}
                        adjustsFontSizeToFit
                        minimumFontScale={0.72}
                      >
                        {westernSign}
                      </Text>
                      <View style={styles.signMetaWrap}>
                        {westernTraitRows.map(([left, right], index) => (
                          <View key={`w-${left}-${right}-${index}`} style={styles.signTraitRow}>
                            <Text style={styles.signTraitCell} numberOfLines={1}>{left}</Text>
                            <Text style={styles.signTraitDot}>•</Text>
                            <Text style={styles.signTraitCell} numberOfLines={1}>{right}</Text>
                          </View>
                        ))}
                      </View>
                    </View>
                    <View style={styles.signPill}>
                      <Text style={styles.signLabel}>Eastern</Text>
                      <Text
                        style={styles.signText}
                        numberOfLines={1}
                        adjustsFontSizeToFit
                        minimumFontScale={0.72}
                      >
                        {chineseSign}
                      </Text>
                      <View style={styles.signMetaWrap}>
                        {chineseTraitRows.map(([left, right], index) => (
                          <View key={`c-${left}-${right}-${index}`} style={styles.signTraitRow}>
                            <Text style={styles.signTraitCell} numberOfLines={1}>{left}</Text>
                            <Text style={styles.signTraitDot}>•</Text>
                            <Text style={styles.signTraitCell} numberOfLines={1}>{right}</Text>
                          </View>
                        ))}
                      </View>
                    </View>
                  </View>

                  <CosmicGlyph />
                  <Text
                    style={styles.archetype}
                    numberOfLines={2}
                    adjustsFontSizeToFit
                    minimumFontScale={0.82}
                  >
                    {details.archetype}
                  </Text>
                  <Text style={styles.identityParagraph} numberOfLines={8}>
                    {cardSummary}
                  </Text>
                </View>
              </Reanimated.View>

            </View>
          </Reanimated.View>
          </ViewShot>
        </Pressable>

        {revealed ? (
          <View style={styles.actions}>
            <Pressable onPress={handleEnter} style={styles.primaryButton}>
              <LinearGradient colors={['#D8B86B', colors.accent]} style={styles.primaryGradient}>
                <Text style={styles.primaryText}>Enter Zodian</Text>
              </LinearGradient>
            </Pressable>
            <Pressable onPress={handleWhyCombo} style={styles.secondaryButton}>
              <Text style={styles.secondaryText}>Why this combo works</Text>
            </Pressable>
          </View>
        ) : (
          <View style={styles.actionsSpacer} />
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  wowOverlay: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  wowHaloPrimary: {
    position: 'absolute',
    width: 430,
    height: 430,
    borderRadius: 999,
    borderWidth: 2,
    borderColor: 'rgba(252,228,154,0.72)',
    backgroundColor: 'transparent',
    shadowColor: '#F4D47C',
    shadowOpacity: 0.32,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 0 },
  },
  wowHaloSecondary: {
    position: 'absolute',
    width: 340,
    height: 340,
    borderRadius: 999,
    borderWidth: 2,
    borderColor: 'rgba(255,241,197,0.62)',
    backgroundColor: 'transparent',
  },
  wowGrain: {
    ...StyleSheet.absoluteFillObject,
    borderWidth: 0,
    borderColor: 'transparent',
    backgroundColor: 'transparent',
    shadowOffset: { width: 0, height: 0 },
  },
  container: {
    flex: 1,
    paddingHorizontal: spacing.lg,
    paddingTop: 24,
    paddingBottom: 28,
  },
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  stepPill: {
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
  },
  stepHint: {
    color: colors.textMuted,
    fontSize: 12,
    lineHeight: 16,
    marginBottom: 10,
  },
  miniShareButton: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.2)',
    backgroundColor: 'rgba(255,255,255,0.04)',
    paddingHorizontal: 12,
    paddingVertical: 7,
    minWidth: 68,
    alignItems: 'center',
  },
  miniShareText: {
    color: colors.accentSoft,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  miniSharePlaceholder: {
    width: 68,
    height: 31,
  },
  title: {
    color: colors.text,
    fontSize: 38,
    lineHeight: 44,
    fontWeight: '700',
    marginBottom: 10,
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 22,
  },
  cardPressable: {
    flex: 1,
  },
  cardTiltWrap: {
    flex: 1,
    justifyContent: 'center',
  },
  flipWrap: {
    flex: 1,
  },
  backTextureWrap: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.34,
  },
  frontTextureWrap: {
    opacity: 0.24,
  },
  frontBorderGlow: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: 'rgba(231,191,104,0.24)',
    shadowColor: '#E7BF68',
    shadowOpacity: 0.12,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 0 },
    elevation: 4,
  },
  frontBorderLine: {
    position: 'absolute',
    top: 10,
    left: 10,
    right: 10,
    bottom: 10,
    borderRadius: radius.xl - 6,
    borderWidth: 1,
    borderColor: 'rgba(231,191,104,0.2)',
  },
  backBorderGlow: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: 'rgba(231,191,104,0.34)',
    shadowColor: '#E7BF68',
    shadowOpacity: 0.22,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 0 },
    elevation: 6,
  },
  backBorderLine: {
    position: 'absolute',
    top: 10,
    left: 10,
    right: 10,
    bottom: 10,
    borderRadius: radius.xl - 6,
    borderWidth: 1,
    borderColor: 'rgba(231,191,104,0.26)',
  },
  cornerTopLeft: {
    position: 'absolute',
    top: 8,
    left: 8,
  },
  cornerTopRight: {
    position: 'absolute',
    top: 8,
    right: 8,
  },
  cornerBottomRight: {
    position: 'absolute',
    bottom: 8,
    right: 8,
  },
  cornerBottomLeft: {
    position: 'absolute',
    bottom: 8,
    left: 8,
  },
  cosmicGlyphWrap: {
    alignSelf: 'center',
    alignItems: 'center',
    marginBottom: 8,
    opacity: 0.85,
  },
  flipCard: {
    ...StyleSheet.absoluteFillObject,
    flex: 1,
    borderRadius: radius.xl,
    backgroundColor: colors.cardStrong,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.16)',
    paddingHorizontal: 20,
    paddingTop: 28,
    paddingBottom: 12,
    alignItems: 'center',
    overflow: 'hidden',
  },
  flipBack: {
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  preRevealCenter: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
  },
  cardEyebrow: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700',
    marginBottom: 14,
  },
  cardTitle: {
    color: colors.text,
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '700',
    textAlign: 'center',
    marginBottom: 8,
  },
  cardHint: {
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 21,
    textAlign: 'center',
    maxWidth: 260,
    marginBottom: 10,
  },
  backFaceContent: {
    flex: 1,
    width: '100%',
    justifyContent: 'flex-start',
    paddingTop: 2,
  },
  signRow: {
    width: '100%',
    flexDirection: 'row',
    gap: 10,
    marginTop: 4,
    marginBottom: 8,
  },
  signPill: {
    flex: 1,
    borderRadius: 0,
    borderWidth: 0,
    borderColor: 'transparent',
    backgroundColor: 'transparent',
    paddingVertical: 6,
    paddingHorizontal: 8,
    alignItems: 'center',
  },
  signLabel: {
    color: colors.textMuted,
    fontSize: 10,
    letterSpacing: 0.8,
    textTransform: 'uppercase',
    marginBottom: 2,
  },
  signText: {
    color: colors.accentSoft,
    fontSize: 17,
    fontWeight: '700',
  },
  signMetaWrap: {
    width: '100%',
    marginTop: 3,
    borderRadius: 0,
    borderWidth: 0,
    borderColor: 'transparent',
    backgroundColor: 'transparent',
    paddingVertical: 4,
    paddingHorizontal: 5,
  },
  signTraitRow: {
    width: '100%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: 1,
  },
  signTraitCell: {
    color: colors.textSoft,
    fontSize: 9,
    lineHeight: 11,
    opacity: 0.92,
    textAlign: 'center',
    flex: 1,
  },
  signTraitDot: {
    color: colors.accent,
    fontSize: 9,
    lineHeight: 11,
    width: 12,
    textAlign: 'center',
    opacity: 0.85,
  },
  archetype: {
    color: colors.text,
    fontSize: 21,
    lineHeight: 26,
    fontWeight: '700',
    textAlign: 'center',
    marginBottom: 6,
  },
  snippet: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 22,
    textAlign: 'center',
    marginBottom: 12,
  },
  identityParagraph: {
    color: colors.text,
    fontSize: 13,
    lineHeight: 19,
    textAlign: 'center',
    maxWidth: 340,
    marginBottom: 0,
    opacity: 0.94,
  },
  actions: {
    marginTop: 16,
    height: ACTIONS_AREA_HEIGHT,
    justifyContent: 'flex-end',
    gap: 10,
  },
  primaryButton: {
    borderRadius: 999,
    overflow: 'hidden',
  },
  primaryGradient: {
    borderRadius: 999,
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
  actionsSpacer: {
    height: ACTIONS_AREA_HEIGHT + 16,
  },
});
