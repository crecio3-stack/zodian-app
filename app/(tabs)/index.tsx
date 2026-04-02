import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View
} from 'react-native';
import Reanimated, { interpolate, useAnimatedStyle, useSharedValue, withDelay, withRepeat, withSequence, withTiming } from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';
import Svg, { Circle, G, Path } from 'react-native-svg';

import ZodiacPairEmblem from '../../components/Artwork/ZodiacPairEmblem';
import Celebration from '../../components/Celebration';
import { getDailyReading } from '../../data/readings';
import { useDailyState } from '../../hooks/useDailyState';
import { useStoredBirthdate } from '../../hooks/useStoredBirthdate';
import { useStoredName } from '../../hooks/useStoredName';
import { trackEvent } from '../../lib/ai/analytics';
import { MILESTONE_THRESHOLDS } from '../../lib/config/milestones';
import { addMilestoneRecord } from '../../lib/storage/rewardsService';
import { colors } from '../../styles/theme';
import {
  formatLongDate,
  getChineseSign,
  getWesternSign,
} from '../../utils/astrology';

function TarotCorner({ rotation, style }: { rotation: number; style: any }) {
  return (
    <View pointerEvents="none" style={style}>
      <Svg width={32} height={32} viewBox="0 0 40 40" fill="none" style={{ transform: [{ rotate: `${rotation}deg` }] }}>
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
    <View pointerEvents="none" style={[styles.tarotTextureWrap, style]}>
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
    <View pointerEvents="none" style={styles.heroGlyphWrap}>
      <Svg width={26} height={26} viewBox="0 0 28 28" fill="none">
        <Circle cx={14} cy={14} r={7.4} stroke="rgba(241,208,126,0.78)" strokeWidth={1.2} />
        <Path d="M14 4.8V23.2M4.8 14H23.2" stroke="rgba(241,208,126,0.48)" strokeWidth={1} />
        <Path d="M13 8.6L14 6L15 8.6L17.6 9.6L15 10.6L14 13.2L13 10.6L10.4 9.6L13 8.6Z" fill="rgba(251,230,170,0.9)" />
      </Svg>
    </View>
  );
}

export default function HomeScreen() {
  const { selectedDate } = useStoredBirthdate(new Date());
  const { name } = useStoredName();

  const westernSign = getWesternSign(selectedDate);
  const chineseSign = getChineseSign(selectedDate);

  const today = useMemo(() => new Date(), []);
  const formattedDate = formatLongDate(today);

  const reading = getDailyReading(westernSign, chineseSign, today);

  const bestMove = useMemo(() => {
    const careerLine = (reading.career || '').trim();
    if (!careerLine) return 'Take one intentional step before noon and protect your energy after.';
    return careerLine;
  }, [reading.career]);

  const horoscopeParagraph = useMemo(() => {
    const parts = [reading.overall, reading.love, reading.career].filter(Boolean);
    return parts.join(' ');
  }, [reading.overall, reading.love, reading.career]);

  const todayFocus = useMemo(() => {
    const move = (bestMove || '').trim();
    if (move) return { label: 'Best move', body: move };

    const love = (reading.love || '').trim();
    if (love) return { label: 'Connection cue', body: love };

    const energy = (reading.overall || '').trim();
    if (energy) return { label: 'Energy anchor', body: energy };

    return {
      label: 'Today\'s focus',
      body: 'Choose one meaningful action and carry it through with intention.',
    };
  }, [bestMove, reading.love, reading.overall]);

  const { summary, revealToday, completeToday, refresh } = useDailyState({
    western: westernSign,
    chinese: chineseSign,
  });

  const revealed = !!summary?.revealed;
  const streakCount = summary?.streak?.current ?? 0;

  // celebratory animation trigger when hitting configured milestones
  const [showCelebration, setShowCelebration] = useState(false);
  const prevStreakRef = useRef<number>(streakCount);

  useEffect(() => {
    const prev = prevStreakRef.current;
    if (streakCount > prev) {
      const isMilestone = MILESTONE_THRESHOLDS.includes(streakCount);
      if (isMilestone) {
        setShowCelebration(true);
        // persist milestone record (best-effort, don't block UI)
        (async () => {
          try {
            await addMilestoneRecord({ streak: streakCount, label: `${streakCount}-day` });
            try { trackEvent('rewards.milestone_persisted', { streak: streakCount }); } catch {}
          } catch (err) {
            console.warn('persist milestone failed', err);
          }
        })();
        // auto-hide after 3s
        setTimeout(() => setShowCelebration(false), 3000);
      }
    }
    prevStreakRef.current = streakCount;
  }, [streakCount]);

  // Reanimated shared values for smooth native animations
  const shimmer = useSharedValue(0);
  const ambient = useSharedValue(0);
  const buttonScale = useSharedValue(1);

  const [isAnimating] = useState(false);

  const router = useRouter();

  // hero flip + open prompt (Reanimated)
  const heroFlip = useSharedValue(0);
  const HERO_FLIP_DURATION_MS = 420;
  const [isHeroFlipped, setIsHeroFlipped] = useState(false);
  const hasTriggeredRevealRef = useRef(false);
  const heroHeartbeat = useSharedValue(0);
  const heroGlow = useSharedValue(0);
  const frontAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ perspective: 1400 }, { rotateY: `${interpolate(heroFlip.value, [0, 1], [0, 180])}deg` }],
    backfaceVisibility: 'hidden',
  }));
  const backAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ perspective: 1400 }, { rotateY: `${interpolate(heroFlip.value, [0, 1], [180, 360])}deg` }],
    backfaceVisibility: 'hidden',
  }));

  // entrance and section fade anims (Reanimated)
  const heroAppear = useSharedValue(0);
  const sectionFade = useSharedValue(0);
  const revealContent = useSharedValue(0);

  // Keep hero visuals in sync when returning to Home with an already-revealed day.
  useEffect(() => {
    if (isAnimating) return;

    if (revealed) {
      revealContent.value = 1;
      heroFlip.value = 1;
      setIsHeroFlipped(true);
      hasTriggeredRevealRef.current = true;
      return;
    }

    revealContent.value = 0;
    heroFlip.value = 0;
    setIsHeroFlipped(false);
    hasTriggeredRevealRef.current = false;
  }, [revealed, isAnimating]);

  // Hero shadow configuration (tweakable via env for quick experiments)
  const HERO_SHADOW_OPACITY =
    typeof globalThis !== 'undefined' &&
    typeof (globalThis as any).process !== 'undefined' &&
    (globalThis as any).process.env.ZODIAN_HERO_SHADOW_OPACITY
      ? Number((globalThis as any).process.env.ZODIAN_HERO_SHADOW_OPACITY)
      : 0.45;

  const heroShadowStyle = {
    textShadowColor: `rgba(0,0,0,${HERO_SHADOW_OPACITY})`,
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 6,
  };

  useEffect(() => {
    // shimmer loop
    shimmer.value = withRepeat(
      withSequence(
        withTiming(1, { duration: 1800 }),
        withTiming(0, { duration: 1800 })
      ),
      -1,
      true
    );

    // ambient glow loop
    ambient.value = withRepeat(
      withSequence(
        withTiming(1, { duration: 2600 }),
        withTiming(0, { duration: 2600 })
      ),
      -1,
      true
    );

    // entrance: hero then sections
    heroAppear.value = withDelay(120, withTiming(1, { duration: 520 }));
    sectionFade.value = withDelay(120 + 520, withTiming(1, { duration: 420 }));

    // ensure today's ritual exists (hook creates it when default signs provided)
  }, []);

  // reanimated-driven interpolations exposed via animated styles
  const logoStyle = useAnimatedStyle(() => ({
    opacity: interpolate(shimmer.value, [0, 1], [0.88, 1]),
  }));

  const logoGlowStyle = useAnimatedStyle(() => ({
    opacity: interpolate(shimmer.value, [0, 1], [0.18, 0.34]),
  }));

  const stageGlowStyle = useAnimatedStyle(() => ({
    opacity: interpolate(ambient.value, [0, 1], [0.08, 0.18]),
  }));

  const heroHeartbeatStyle = useAnimatedStyle(() => ({
    transform: [{ scale: interpolate(heroHeartbeat.value, [0, 1], [1, 1.02]) }],
  }));

  const heroGlowStyle = useAnimatedStyle(() => ({
    opacity: heroGlow.value,
  }));

  // Animated styles used in JSX must be declared unconditionally to preserve hooks order
  const revealContentStyle = useAnimatedStyle(() => ({
    opacity: revealContent.value,
    transform: [{ translateY: interpolate(revealContent.value, [0, 1], [6, 0]) }],
  }));

  const ritualSectionStyle = useAnimatedStyle(() => ({
    opacity: sectionFade.value,
    transform: [{ translateY: interpolate(sectionFade.value, [0, 1], [6, 0]) }],
  }));

  const heroShellAnimatedStyle = useAnimatedStyle(() => {
    return {
      opacity: heroAppear.value,
      transform: [
        { perspective: 1000 },
        { scale: buttonScale.value },
      ],
    };
  });

  const completeRevealIfNeeded = async () => {
    if (hasTriggeredRevealRef.current) return;
    hasTriggeredRevealRef.current = true;
    setIsHeroFlipped(true);
    heroFlip.value = withTiming(1, { duration: HERO_FLIP_DURATION_MS });
    revealContent.value = withTiming(1, { duration: 260 });

    try {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } catch {}

    try {
      await revealToday();
      await completeToday();
      await refresh();
      trackEvent('ui.home.reveal', { westernSign, chineseSign, date: new Date().toISOString() });
      trackEvent('ui.home.complete_ritual', { westernSign, chineseSign });
    } catch {}
  };

  useEffect(() => {
    if (isHeroFlipped) {
      heroHeartbeat.value = withTiming(0, { duration: 160 });
      return;
    }

    heroHeartbeat.value = withRepeat(
      withSequence(withTiming(1, { duration: 560 }), withTiming(0, { duration: 560 })),
      -1,
      true
    );
  }, [heroHeartbeat, isHeroFlipped]);

  useEffect(() => {
    heroGlow.value = withTiming(isHeroFlipped ? 1 : 0, { duration: 220 });
  }, [heroGlow, isHeroFlipped]);

  const handleHeroCardPress = async () => {
    const nextFlipped = !isHeroFlipped;

    if (nextFlipped && !revealed) {
      await completeRevealIfNeeded();
    } else {
      setIsHeroFlipped(nextFlipped);
      heroFlip.value = withTiming(nextFlipped ? 1 : 0, { duration: HERO_FLIP_DURATION_MS });
    }

    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } catch {}
  };

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <LinearGradient
        colors={[colors.background, colors.backgroundAlt, colors.background]}
        style={StyleSheet.absoluteFill}
      />

      <Reanimated.View
        pointerEvents="none"
        style={[styles.ambientOrb, stageGlowStyle]}
      />

      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
        scrollEnabled={true}
      >
        <View style={styles.logoWrap}>
          <Reanimated.Text style={[styles.logoText, logoStyle]}>
            ZODIAN
          </Reanimated.Text>
        </View>

        <View style={styles.topMetaRow}>
          <Text style={styles.topMetaDate}>{formattedDate}</Text>
          <View style={styles.topMetaStreakPill}>
            <Text style={styles.topMetaStreakText}>Streak {streakCount}</Text>
          </View>
        </View>

        {/* Celebration overlay when milestone achieved */}
        {showCelebration ? <Celebration /> : null}

        <View style={styles.stage}>
          <Reanimated.View
            style={[
              styles.heroShell,
              heroHeartbeatStyle,
              heroShellAnimatedStyle,
            ]}
          >
            <Pressable
              accessible={true}
              accessibilityRole={'button'}
              accessibilityLabel={revealed ? "Tap to flip today's ritual card" : "Tap to reveal today's ritual"}
              onPress={handleHeroCardPress}
            >
              <LinearGradient
                colors={[
                  colors.cardBorder,
                  'rgba(243, 239, 230, 0.02)',
                  colors.secondaryAccentGlow,
                ]}
                style={StyleSheet.absoluteFill}
              />

              <View style={styles.heroInner}>
                <View style={styles.flipWrap}>
                  <Reanimated.View
                    renderToHardwareTextureAndroid={true}
                    shouldRasterizeIOS={false}
                    style={[
                      styles.flipCard,
                      frontAnimatedStyle,
                    ]}
                  >
                    <LinearGradient
                      colors={['rgba(255,255,255,0.05)', 'rgba(255,255,255,0.02)', 'rgba(216,184,107,0.04)']}
                      style={StyleSheet.absoluteFill}
                    />
                    <ZodiacTexture style={styles.tarotTextureFront} />
                    <View pointerEvents="none" style={styles.tarotBorderGlow} />
                    <View pointerEvents="none" style={styles.tarotBorderLine} />
                    <TarotCorner rotation={0} style={styles.cornerTopLeft} />
                    <TarotCorner rotation={90} style={styles.cornerTopRight} />
                    <TarotCorner rotation={180} style={styles.cornerBottomRight} />
                    <TarotCorner rotation={270} style={styles.cornerBottomLeft} />
                    <Text style={styles.heroKicker}>TODAY'S RITUAL</Text>

                    <Text style={styles.heroSigns}>{westernSign} / {chineseSign}</Text>
                    <CosmicGlyph />

                    <View style={styles.heroFaceContent}>
                      <ZodiacPairEmblem westernSign={westernSign} chineseSign={chineseSign} />
                      <Text style={[styles.heroTitle, heroShadowStyle]}>
                        {revealed ? 'Your ritual is waiting.' : 'Your ritual is waiting.'}
                      </Text>
                      {!revealed ? <Text style={styles.heroBody}>Tap once to pull your card.</Text> : null}
                    </View>

                    <View style={styles.heroMetaRow}>
                      <View style={styles.metaPill}>
                        <Text style={styles.metaLabel}>Streak</Text>
                        <Text style={styles.metaValue}>{streakCount} days</Text>
                      </View>

                      <View style={styles.metaPill}>
                        <Text style={styles.metaLabel}>Status</Text>
                        <Text style={styles.metaValue}>{revealed ? 'Complete' : 'Waiting'}</Text>
                      </View>
                    </View>
                  </Reanimated.View>

                  <Reanimated.View
                    renderToHardwareTextureAndroid={true}
                    shouldRasterizeIOS={false}
                    style={[
                      styles.flipCard,
                      styles.flipBack,
                      backAnimatedStyle,
                    ]}
                  >
                    {/* Back face shows revealed content explicitly */}
                    <LinearGradient
                      colors={['rgba(255,255,255,0.05)', 'rgba(255,255,255,0.02)', 'rgba(216,184,107,0.04)']}
                      style={StyleSheet.absoluteFill}
                    />
                    <ZodiacTexture />
                    <View pointerEvents="none" style={styles.tarotBorderGlow} />
                    <View pointerEvents="none" style={styles.tarotBorderLine} />
                    <TarotCorner rotation={0} style={styles.cornerTopLeft} />
                    <TarotCorner rotation={90} style={styles.cornerTopRight} />
                    <TarotCorner rotation={180} style={styles.cornerBottomRight} />
                    <TarotCorner rotation={270} style={styles.cornerBottomLeft} />
                    <Text style={styles.heroEyebrow}>PULLED TODAY</Text>
                    <Text style={styles.heroSigns}>{westernSign} / {chineseSign}</Text>
                    <CosmicGlyph />

                    <Reanimated.View style={styles.heroFaceContent}>
                      <Text style={[styles.heroHeadline, heroShadowStyle]}>{reading.headline}</Text>
                      <Text style={styles.heroBody}>{horoscopeParagraph}</Text>
                    </Reanimated.View>

                    <View style={styles.heroMetaRow}>
                      <View style={styles.metaPill}>
                        <Text style={styles.metaLabel}>Streak</Text>
                        <Text style={styles.metaValue}>{streakCount} days</Text>
                      </View>

                      <View style={styles.metaPill}>
                        <Text style={styles.metaLabel}>Status</Text>
                        <Text style={styles.metaValue}>Complete</Text>
                      </View>
                    </View>
                  </Reanimated.View>

                  <Reanimated.View pointerEvents="none" style={[styles.heroCardGlow, heroGlowStyle]} />
                </View>
              </View>
            </Pressable>
          </Reanimated.View>
        </View>

        {revealed ? (
          <Reanimated.View style={[styles.ritualFlowWrap, ritualSectionStyle]}>
            <Text style={styles.ritualSectionLabel}>TODAY'S FOCUS</Text>
            <View style={styles.focusCard}>
              <Text style={styles.focusPill}>{todayFocus.label.toUpperCase()}</Text>
              <Text style={styles.focusBody}>{todayFocus.body}</Text>
            </View>

            <Pressable
              style={({ pressed }) => [styles.goDeeperEntry, pressed && { opacity: 0.9 }]}
              onPress={async () => {
                await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                trackEvent('ui.home.go_deeper', { westernSign, chineseSign });
                router.push({
                  pathname: '/details',
                  params: {
                    westernSign,
                    chineseSign,
                    ritualHeadline: reading.headline,
                    ritualCoreMessage: reading.overall,
                    focusLabel: todayFocus.label,
                    focusBody: todayFocus.body,
                  },
                });
              }}
            >
              <Text style={styles.goDeeperLabel}>GO DEEPER</Text>
              <Text style={styles.goDeeperText}>Explore your extended reading and deeper astrology guidance.</Text>
            </Pressable>

            <Pressable
              style={styles.chatEntry}
              onPress={async () => {
                await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                router.push('/astro-chat');
              }}
            >
              <Text style={styles.chatEyebrow}>Zodian guide</Text>
              <Text style={styles.chatTitle}>Open Astrology Chat</Text>
              <Text style={styles.chatBody}>{name ? `Go deeper on today's message, ${name}.` : "Go deeper on today's message with your astrologer."}</Text>
            </Pressable>

            <Pressable
              style={styles.matchTeaser}
              onPress={async () => {
                await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                router.push('/match');
              }}
            >
              <Text style={styles.matchTeaserLabel}>Subtle nudge</Text>
              <Text style={styles.matchTeaserText}>Your connection energy is active. Explore a few aligned matches.</Text>
            </Pressable>
          </Reanimated.View>
        ) : null}
      </ScrollView>
    </SafeAreaView>
  );
}

const luxurySerif = Platform.select({
  ios: 'Georgia',
  android: 'serif',
  default: 'serif',
});

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  fullscreenRippleWrap: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
  },
  fullscreenRippleRing: {
    position: 'absolute',
    width: 280,
    height: 280,
    borderRadius: 999,
    borderWidth: 2,
    borderColor: 'rgba(216,184,107,0.55)',
    backgroundColor: 'rgba(216,184,107,0.08)',
  },
  fullscreenRippleRingSecondary: {
    position: 'absolute',
    width: 240,
    height: 240,
    borderRadius: 999,
    borderWidth: 2,
    borderColor: 'rgba(247,233,194,0.45)',
    backgroundColor: 'rgba(247,233,194,0.06)',
  },
  fullscreenShimmer: {
    position: 'absolute',
    width: 220,
    height: '180%',
    backgroundColor: 'rgba(247,233,194,0.22)',
  },
  ambientOrb: {
    position: 'absolute',
    top: '16%',
    left: 24,
    right: 24,
    height: 280,
    borderRadius: 999,
    backgroundColor: colors.secondaryAccentGlow,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 14,
    paddingBottom: 140,
  },
  logoWrap: {
    minHeight: 52,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  logoText: {
    color: colors.accent,
    fontSize: 28,
    letterSpacing: 5,
    fontWeight: '700',
    fontFamily: luxurySerif,
  },
  topMetaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
  },
  topMetaDate: {
    color: colors.textMuted,
    fontSize: 14,
  },
  topMetaStreakPill: {
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  topMetaStreakText: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '700',
  },
  kicker: {
    color: colors.accent,
    textAlign: 'center',
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700',
    opacity: 0.92,
    marginBottom: 10,
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
  },
  title: {
    color: colors.text,
    fontSize: 38,
    lineHeight: 44,
    textAlign: 'center',
    fontWeight: '800',
    marginBottom: 8,
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 16,
    textAlign: 'center',
  },
  stage: {
    marginBottom: 30,
  },
  heroShell: {
    borderRadius: 34,
    borderWidth: 1,
    overflow: 'hidden',
    backgroundColor: colors.cardStrong,
    shadowColor: '#000',
    shadowOpacity: 0.28,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 14 },
    elevation: 10,
  },
  heroInner: {
    borderRadius: 34,
    paddingHorizontal: 0,
    paddingVertical: 0,
  },

  // flip helpers
  flipWrap: {
    position: 'relative',
    minHeight: 488,
    alignItems: 'center',
    justifyContent: 'center',
  },
  tarotTextureWrap: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.34,
  },
  tarotTextureFront: {
    opacity: 0.24,
  },
  tarotBorderGlow: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 34,
    borderWidth: 1,
    borderColor: 'rgba(231,191,104,0.3)',
    shadowColor: '#E7BF68',
    shadowOpacity: 0.18,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 0 },
    elevation: 6,
  },
  tarotBorderLine: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 34,
    borderWidth: 1,
    borderColor: 'rgba(231,191,104,0.24)',
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
  heroGlyphWrap: {
    marginBottom: 10,
    opacity: 0.84,
  },
  revealFxLayer: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 2,
  },
  heroRevealRipple: {
    position: 'absolute',
    width: 420,
    height: 420,
    borderRadius: 999,
    borderWidth: 2,
    borderColor: 'rgba(255,240,200,0.7)',
    backgroundColor: 'rgba(255,240,200,0.08)',
  },
  heroRevealFlash: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(255,248,228,0.65)',
  },
  heroRevealShimmer: {
    position: 'absolute',
    width: 180,
    height: '155%',
    backgroundColor: 'rgba(255,255,255,0.4)',
  },
  flipCard: {
    ...StyleSheet.absoluteFillObject,
    backfaceVisibility: 'hidden',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 40,
    paddingBottom: 34,
  },
  flipBack: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
  },
  heroCardGlow: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 34,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.44)',
    shadowColor: '#D8B86B',
    shadowOpacity: 0.42,
    shadowRadius: 22,
    shadowOffset: { width: 0, height: 0 },
    elevation: 9,
  },
  heroEyebrow: {
    color: colors.accent,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.8,
    textAlign: 'center',
    marginBottom: 8,
  },
  heroKicker: {
    color: colors.accent,
    textAlign: 'center',
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700',
    opacity: 0.92,
    marginBottom: 10,
  },
  heroSigns: {
    color: colors.textSoft,
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 10,
  },
  heroTitle: {
    color: colors.text,
    fontSize: 34,
    lineHeight: 40,
    textAlign: 'center',
    fontWeight: '800',
    marginBottom: 16,
  },
  heroFaceContent: {
    width: '100%',
    flex: 1,
    justifyContent: 'center',
  },
  heroHeadline: {
    color: colors.accent,
    fontSize: 20,
    lineHeight: 28,
    textAlign: 'center',
    fontWeight: '700',
    letterSpacing: 0.2,
    marginBottom: 14,
  },
  heroBody: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 24,
    textAlign: 'center',
    marginBottom: 26,
  },
  heroMetaRow: {
    flexDirection: 'row',
    gap: 12,
  },
  metaPill: {
    flex: 1,
    borderRadius: 18,
    paddingVertical: 14,
    paddingHorizontal: 14,
    backgroundColor: colors.card,
    borderWidth: 1,
    borderColor: colors.cardBorder,
  },
  metaLabel: {
    color: colors.textMuted,
    fontSize: 12,
    marginBottom: 6,
    textAlign: 'center',
  },
  metaValue: {
    color: colors.text,
    fontSize: 15,
    fontWeight: '700',
    textAlign: 'center',
  },
  primaryButtonWrap: {
    marginBottom: 18,
  },
  revealBurst: {
    position: 'absolute',
    left: -12,
    right: -12,
    top: -12,
    bottom: -12,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.08)',
  },

  primaryButton: {
    borderRadius: 999,
    overflow: 'hidden',
  },
  primaryButtonGradient: {
    paddingVertical: 17,
    alignItems: 'center',
    borderRadius: 999,
  },
  primaryButtonText: {
    color: colors.text,
    fontSize: 17,
    fontWeight: '700',
    letterSpacing: 0.2,
  },
  ritualFlowWrap: {
    marginTop: 4,
    marginBottom: 26,
  },
  ritualSectionLabel: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700',
    marginBottom: 10,
  },
  focusCard: {
    borderRadius: 22,
    paddingHorizontal: 18,
    paddingVertical: 18,
    backgroundColor: colors.card,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    marginBottom: 16,
  },
  focusPill: {
    alignSelf: 'flex-start',
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 1.4,
    fontWeight: '700',
    borderWidth: 1,
    borderColor: 'rgba(230, 183, 92, 0.18)',
    backgroundColor: 'rgba(230, 183, 92, 0.08)',
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 5,
    marginBottom: 10,
  },
  focusBody: {
    color: colors.text,
    fontSize: 18,
    lineHeight: 28,
    fontWeight: '600',
  },
  goDeeperEntry: {
    marginBottom: 12,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.18)',
    borderRadius: 18,
    backgroundColor: 'rgba(216,184,107,0.06)',
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  goDeeperLabel: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 1.8,
    marginBottom: 6,
    fontWeight: '700',
  },
  goDeeperText: {
    color: colors.textSoft,
    fontSize: 14,
    lineHeight: 20,
  },
  chatEntry: {
    borderRadius: 18,
    padding: 14,
    backgroundColor: colors.card,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    marginBottom: 10,
  },
  chatEyebrow: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 1.3,
    marginBottom: 6,
    textTransform: 'uppercase',
    fontWeight: '700',
  },
  chatTitle: {
    color: colors.text,
    fontSize: 17,
    fontWeight: '700',
    marginBottom: 5,
  },
  chatBody: {
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 20,
  },
  matchTeaser: {
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: 'rgba(230, 183, 92, 0.12)',
    backgroundColor: 'rgba(255,255,255,0.02)',
  },
  matchTeaserLabel: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 1.2,
    marginBottom: 5,
    textTransform: 'uppercase',
    fontWeight: '700',
  },
  matchTeaserText: {
    color: colors.textMuted,
    fontSize: 13,
    lineHeight: 20,
  },
});