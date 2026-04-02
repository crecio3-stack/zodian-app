import * as Haptics from 'expo-haptics';
import { useRouter } from 'expo-router';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
    Animated,
    Platform,
    Pressable,
    ScrollView,
    Share,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import Reanimated, { useAnimatedStyle, useSharedValue, withTiming } from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useDailyState } from '../../hooks/useDailyState';
import { on as onEvent } from '../../lib/events/ee';
import { consumeNavIntent } from '../../lib/navigation/intent';

import { PremiumModal } from '../../components/PremiumModal';
import { getDailyRitual } from '../../data/dailyRitual';
import { usePremium } from '../../hooks/usePremium';
import { useStoredBirthdate } from '../../hooks/useStoredBirthdate';
import { useStoredName } from '../../hooks/useStoredName';
import { trackEvent } from '../../lib/ai/analytics';
import { mapDailyRitualToLegacy } from '../../lib/ai/mappers';
import { isValidDailyRitualResponse } from '../../lib/ai/validateDailyRitual';
import { colors, radius, spacing } from '../../styles/theme';
import {
    formatLongDate,
    getChineseSign,
    getWesternSign,
} from '../../utils/astrology';

export default function DailyScreen() {
  const router = useRouter();
  const { selectedDate } = useStoredBirthdate(new Date());
  const { name } = useStoredName();
  const { isPremium, enablePremium } = usePremium();

  const today = useMemo(() => new Date(), []);
  const westernSign = getWesternSign(selectedDate);
  const chineseSign = getChineseSign(selectedDate);

  const [ritual, setRitual] = useState(() => getDailyRitual(westernSign, chineseSign));
  const [reading, setReading] = useState(ritual); // mapped reading model

  // local daily state hook (creates today's record if missing)
  const { completeToday, todayRitual, summary, refresh } = useDailyState({ western: westernSign, chinese: chineseSign });
  const [isCompleting, setIsCompleting] = useState(false);

  const ritualHeadline = useMemo(
    () => reading?.headline ?? (ritual as any).headline ?? (ritual as any).title,
    [reading, ritual]
  );

  const ritualCoreMessage = useMemo(
    () => reading?.coreMessage ?? (ritual as any).coreMessage ?? (ritual as any).subtitle ?? '',
    [reading, ritual]
  );

  const focusInsight = useMemo(() => {
    const advice = (reading?.advice ?? (ritual as any).advice ?? '').trim();
    if (advice) {
      return {
        label: 'Best move',
        body: advice,
      };
    }

    const love = (reading?.love ?? (ritual as any).love ?? '').trim();
    if (love) {
      return {
        label: 'Connection cue',
        body: love,
      };
    }

    const energy = (reading?.energy ?? (ritual as any).energy ?? '').trim();
    if (energy) {
      return {
        label: 'Energy anchor',
        body: energy,
      };
    }

    return {
      label: 'Today\'s focus',
      body: 'Choose one meaningful action, complete it fully, and protect your energy after.',
    };
  }, [reading, ritual]);

  const completedToday = Boolean(todayRitual?.completed || summary?.completed);


  const [showPremiumModal, setShowPremiumModal] = useState(false);
  const intentVal = consumeNavIntent('fromReveal');
  const intentObj = intentVal && typeof intentVal === 'object' ? (intentVal as any) : null;
  const intentPresent = Boolean(intentVal);


  // If Home passed a generated ritual via intent, use it
  useEffect(() => {
    if (intentObj && intentObj.ritual) {
      try {
        if (isValidDailyRitualResponse(intentObj.ritual)) {
          setRitual(intentObj.ritual);
          try { setReading(mapDailyRitualToLegacy(intentObj.ritual)); } catch {}
          return;
        }
      } catch {}
    }

    // Also listen for a late-arriving generated ritual
    const handler = (r: any) => {
      try {
        if (isValidDailyRitualResponse(r)) {
          setRitual(r);
          try { setReading(mapDailyRitualToLegacy(r as any)); } catch {}
        }
      } catch {}
    };

    const off = onEvent('nav.ritual.ready', handler as any);
    return () => {
      off();
    };
  }, [intentObj]);

  // Only flip the hero when the intent explicitly signals AI personalization was prepared and ready.
  const shouldFlip = Boolean(
    (intentObj && intentObj.ai === true && intentObj.ready === true) ||
    intentVal === '1' || intentVal === 'true' || intentVal === true
  );

  const [showRevealBanner, setShowRevealBanner] = useState(intentPresent);

  const flipAnim = useRef(new Animated.Value(0)).current;
  const [isFlipped, setIsFlipped] = useState(false);
  const [showFlipHint, setShowFlipHint] = useState(false);
  const animatingRef = useRef(false);
  const flipHintTimerRef = useRef<any>(null);

  // toast for completion confirmation
  const toastOpacity = useSharedValue(0);
  const toastY = useSharedValue(12);
  const toastAnimatedStyle = useAnimatedStyle(() => ({
    opacity: toastOpacity.value,
    transform: [{ translateY: toastY.value }],
  }));

  function showCompleteToast() {
    try {
      toastOpacity.value = withTiming(1, { duration: 200 });
      toastY.value = withTiming(0, { duration: 220 });
      setTimeout(() => {
        try {
          toastOpacity.value = withTiming(0, { duration: 220 });
          toastY.value = withTiming(12, { duration: 220 });
        } catch {}
      }, 2000);
    } catch {}
  }

  const handleDismissReveal = () => {
    try {
      setShowRevealBanner(false);
      flipAnim.setValue(0);
      setIsFlipped(false);
      setShowFlipHint(false);
      if (flipHintTimerRef.current) {
        clearTimeout(flipHintTimerRef.current);
        flipHintTimerRef.current = null;
      }
      trackEvent('ui.daily.dismiss_reveal', { westernSign, chineseSign });
    } catch {}
  };

  const handleHeroToggle = () => {
    if (animatingRef.current) return;
    // light haptic feedback for tactile affordance
    try { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {}); } catch {}

    animatingRef.current = true;
    const toValue = isFlipped ? 0 : 1;
    Animated.timing(flipAnim, {
      toValue,
      duration: 600,
      useNativeDriver: true,
    }).start(() => {
      const nextFlipped = !isFlipped;
      setIsFlipped(nextFlipped);
      animatingRef.current = false;
      try { trackEvent('ui.daily.toggle_flip', { isFlipped: nextFlipped, westernSign, chineseSign }); } catch {}

      // show hint when flipped to the revealed/back side
      if (nextFlipped) {
        setShowFlipHint(true);
        if (flipHintTimerRef.current) {
          clearTimeout(flipHintTimerRef.current);
        }
        flipHintTimerRef.current = setTimeout(() => {
          setShowFlipHint(false);
          flipHintTimerRef.current = null;
        }, 2400);
      } else {
        // if flipping back to front, hide hint
        setShowFlipHint(false);
        if (flipHintTimerRef.current) {
          clearTimeout(flipHintTimerRef.current);
          flipHintTimerRef.current = null;
        }
      }
    });
  };

  // cleanup timers on unmount
  useEffect(() => {
    return () => {
      if (flipHintTimerRef.current) {
        clearTimeout(flipHintTimerRef.current);
        flipHintTimerRef.current = null;
      }
    };
  }, []);



  // If opened immediately after a reveal, show a brief contextual banner and track
  useEffect(() => {
    if (intentPresent) {
      trackEvent('ui.daily.opened_from_reveal', { westernSign, chineseSign });
      setShowRevealBanner(true);

      if (shouldFlip) {
        // run flip animation for the hero card
        setTimeout(() => {
          animatingRef.current = true;
          Animated.timing(flipAnim, {
            toValue: 1,
            duration: 700,
            useNativeDriver: true,
          }).start(() => {
            setIsFlipped(true);
            animatingRef.current = false;

            try {
              setShowFlipHint(true);
              if (flipHintTimerRef.current) clearTimeout(flipHintTimerRef.current);
              flipHintTimerRef.current = setTimeout(() => {
                setShowFlipHint(false);
                flipHintTimerRef.current = null;
              }, 2400);
            } catch {}
          });
        }, 120);      }

      const t = setTimeout(() => setShowRevealBanner(false), 2400);
      return () => {
        clearTimeout(t);
        flipAnim.setValue(0);
      };
    }
    return;
  }, [intentPresent, shouldFlip, westernSign, chineseSign, flipAnim]);

  const handleShare = async () => {
    try {
      if (Platform.OS !== 'web') {
        await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      }

      const message = [
        `Today's Zodian Reading`,
        `${westernSign} × ${chineseSign}`,
        ``,
        `${reading?.headline ?? (ritual as any).headline ?? (ritual as any).title}`,
        ``,
        `Love: ${reading?.love ?? (ritual as any).love ?? ''}`,
        `Energy: ${reading?.energy ?? (ritual as any).energy ?? ''}`,
        `Advice: ${reading?.advice ?? (ritual as any).advice ?? ''}`,
      ].join('\n');

      await Share.share({
        message,
      });
      trackEvent('ui.daily.share', { westernSign, chineseSign });
    } catch (error) {
      console.warn('Share failed', error);
    }
  };



  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.hero}>
          <View style={styles.topMetaRow}>
            <Text style={styles.date}>{formatLongDate(today)}</Text>
            <View style={styles.statusPill}>
              <Text style={styles.statusPillText}>{isPremium ? 'Premium' : 'Standard'}</Text>
            </View>
          </View>

          <Text style={styles.eyebrow}>DAILY RITUAL</Text>
          <Text style={styles.heroLead}>{name ? `${name}, your ${westernSign} x ${chineseSign} ritual is ready.` : `Your ${westernSign} x ${chineseSign} ritual is ready.`}</Text>

          <View style={styles.signRowWithoutStreak}>
            <View style={styles.signBadge}>
              <Text style={styles.signBadgeText}>{westernSign}</Text>
            </View>

            <View style={styles.dot} />

            <View style={styles.signBadge}>
              <Text style={styles.signBadgeText}>{chineseSign}</Text>
            </View>
          </View>

          {showRevealBanner ? (
              <View style={styles.revealBanner}>
                <View style={{ flex: 1 }}>
                  <Text style={{ color: colors.accentBright, fontWeight: '700' }}>Revealed</Text>
                    <Text style={{ color: colors.textMuted }}>Your personalized ritual has been revealed. Take a breath and continue.</Text>
                  </View>

                  <Pressable onPress={handleDismissReveal} style={{ padding: 8, marginLeft: 12 }}>
                    <Text style={{ color: colors.accent, fontWeight: '700' }}>Dismiss</Text>
                  </Pressable>
                </View>
              ) : null}

              {/* Hero card container so the card visual is consistent with Home */}
              {intentPresent ? (
                <Pressable
                  style={styles.heroCard}
                  onPress={() => {
                    try { handleHeroToggle(); } catch {}
                  }}
                  accessibilityLabel="Toggle ritual reveal"
                  accessibilityHint="Tap to flip the ritual card over or back"
                >
                  <View style={styles.heroCardInner}>
                    <View style={styles.flipWrap}>
                      <Animated.View
                        style={[
                          styles.flipCard,
                          {
                            transform: [{ perspective: 1000 }, { rotateY: flipAnim.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '180deg'] }) }],
                          },
                        ]}
                      >
                        <Text style={styles.heroTitle}>Revealing your ritual...</Text>
                        <Text style={styles.heroSubtext}>{ritualCoreMessage || 'Your ritual is being prepared for today.'}</Text>
                      </Animated.View>

                      <Animated.View
                        style={[
                          styles.flipCard,
                          styles.flipBack,
                          {
                            transform: [{ perspective: 1000 }, { rotateY: flipAnim.interpolate({ inputRange: [0, 1], outputRange: ['180deg', '360deg'] }) }],
                          },
                        ]}
                      >
                        <Text style={styles.heroTitle}>{ritualHeadline}</Text>
                        <Text style={styles.heroSubtext}>{ritualCoreMessage}</Text>
                      </Animated.View>
                    </View>

                    {showFlipHint ? (
                      <Text style={styles.flipHint}>Tap to flip again</Text>
                    ) : null}
                  </View>
                </Pressable>
              ) : (
                <View style={[styles.heroCard, styles.heroCardInner]}>
                  <Text style={styles.heroTitle}>{ritualHeadline}</Text>
                  <Text style={styles.heroSubtext}>{ritualCoreMessage}</Text>
                </View>
                )}

        </View>

        <View style={styles.focusSection}>
          <Text style={styles.focusSectionLabel}>TODAY'S FOCUS</Text>
          <View style={styles.focusCard}>
            <Text style={styles.focusCardPill}>{focusInsight.label.toUpperCase()}</Text>
            <Text style={styles.focusCardBody}>{focusInsight.body}</Text>
          </View>
        </View>

        <View style={styles.actionSection}>
          <Pressable
            onPress={async () => {
              if (isCompleting || completedToday) return;
              try {
                setIsCompleting(true);
                await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
              } catch {}
              try {
                await completeToday();
                await refresh();
                showCompleteToast();
                trackEvent('ui.daily.complete', { westernSign, chineseSign });
              } catch (e) {
                console.warn('completeToday failed', e);
              } finally {
                setIsCompleting(false);
              }
            }}
            disabled={isCompleting || completedToday}
            style={({ pressed }) => [
              styles.completeButton,
              (isCompleting || completedToday) && styles.completeButtonDisabled,
              pressed && !isCompleting && !completedToday && { opacity: 0.92 },
            ]}
          >
            <Text style={styles.completeButtonText}>
              {completedToday ? 'Ritual Completed' : isCompleting ? 'Completing Ritual...' : 'Complete Ritual'}
            </Text>
          </Pressable>

          <Text style={styles.completeHintText}>
            {completedToday ? 'Your streak has been updated for today.' : 'Complete to lock in today\'s ritual and protect your streak.'}
          </Text>

          <Pressable onPress={handleShare} style={styles.shareLink}>
            <Text style={styles.shareLinkText}>Share today's ritual</Text>
          </Pressable>
        </View>

        <Pressable
          onPress={() => {
            trackEvent('ui.daily.open_chat', { westernSign, chineseSign });
            router.push('/astro-chat');
          }}
          style={({ pressed }) => [
            styles.chatEntry,
            pressed && { opacity: 0.92 },
          ]}
        >
          <View style={{ flex: 1 }}>
            <Text style={styles.chatEntryEyebrow}>Zodian guide</Text>
            <Text style={styles.chatEntryTitle}>Open Astrology Chat</Text>
            <Text style={styles.chatEntrySubtext}>{name ? `Ask about identity, love patterns, and timing, ${name}.` : 'Ask about identity, love patterns, compatibility, and current energy.'}</Text>
          </View>
          <Text style={styles.chatEntryArrow}>&gt;</Text>
        </Pressable>

        <Pressable
          onPress={() => {
            trackEvent('ui.daily.go_deeper', { westernSign, chineseSign });
            router.push({
              pathname: '/details',
              params: {
                westernSign,
                chineseSign,
                ritualHeadline,
                ritualCoreMessage,
                focusLabel: focusInsight.label,
                focusBody: focusInsight.body,
              },
            });
          }}
          style={({ pressed }) => [styles.goDeeperEntry, pressed && { opacity: 0.9 }]}
        >
          <Text style={styles.goDeeperLabel}>GO DEEPER</Text>
          <Text style={styles.goDeeperText}>Explore your extended reading and deeper astrology guidance.</Text>
        </Pressable>

        <Reanimated.View style={[styles.completeToast, toastAnimatedStyle]} pointerEvents="none">
          <Text style={styles.completeToastText}>Ritual completed — streak updated 🔥</Text>
        </Reanimated.View>

        <View style={styles.footerSpace} />
      </ScrollView>

      <PremiumModal visible={showPremiumModal} onClose={() => setShowPremiumModal(false)} onUpgrade={async () => {
        trackEvent('ui.premium.upgrade_click');
        await enablePremium();
        setShowPremiumModal(false);
      }} />
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
    paddingTop: 10,
    paddingBottom: 32,
  },
  hero: {
    paddingTop: 8,
    paddingBottom: 18,
  },
  topMetaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2.2,
    marginBottom: 6,
  },
  heroLead: {
    color: colors.text,
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '700',
    marginBottom: 14,
  },
  date: {
    color: colors.textMuted,
    fontSize: 14,
  },
  statusPill: {
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  statusPillText: {
    color: colors.accent,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.4,
  },
  signRowWithoutStreak: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 14,
    justifyContent: 'center',
    gap: 8,
  },
  signBadge: {
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: radius.pill,
  },
  signBadgeText: {
    color: colors.accentSoft,
    fontSize: 13,
    letterSpacing: 0.4,
  },
  dot: {
    width: 5,
    height: 5,
    borderRadius: radius.pill,
    backgroundColor: colors.secondaryAccent,
    marginHorizontal: 10,
  },
  heroCard: {
    borderRadius: 28,
    paddingHorizontal: 20,
    paddingVertical: 26,
    backgroundColor: colors.cardStrong,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    marginBottom: 16,
    minHeight: 260,
    justifyContent: 'center',
  },
  heroCardInner: {
    borderRadius: 28,
  },
  heroTitle: {
    color: colors.accentBright,
    fontSize: 34,
    lineHeight: 40,
    fontWeight: '800',
    marginBottom: 12,
    letterSpacing: -0.6,
    maxWidth: '98%',
    textAlign: 'center',
  },
  heroSubtext: {
    color: colors.textSoft,
    fontSize: 16,
    lineHeight: 24,
    maxWidth: '96%',
    textAlign: 'center',
  },
  revealBanner: {
    backgroundColor: colors.secondaryAccentGlow,
    padding: 10,
    borderRadius: 12,
    marginBottom: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  flipWrap: {
    position: 'relative',
    minHeight: 120,
    alignItems: 'center',
    justifyContent: 'center',
  },
  flipCard: {
    width: '100%',
    backfaceVisibility: 'hidden',
    alignItems: 'center',
  },
  flipBack: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
  },
  flipHint: {
    color: colors.textMuted,
    fontSize: 13,
    textAlign: 'center',
    marginTop: 8,
  },
  focusSection: {
    marginBottom: 24,
  },
  focusSectionLabel: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 2.2,
    marginBottom: 10,
  },
  focusCard: {
    backgroundColor: colors.cardStrong,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    paddingHorizontal: 18,
    paddingVertical: 18,
    minHeight: 142,
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOpacity: 0.24,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 8 },
  },
  focusCardPill: {
    alignSelf: 'flex-start',
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 1.6,
    fontWeight: '700',
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.24)',
    backgroundColor: 'rgba(216,184,107,0.1)',
    borderRadius: radius.pill,
    paddingHorizontal: 10,
    paddingVertical: 5,
    marginBottom: 12,
  },
  focusCardBody: {
    color: colors.text,
    fontSize: 20,
    lineHeight: 30,
    fontWeight: '600',
  },
  actionSection: {
    marginBottom: 18,
  },
  completeButton: {
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    paddingVertical: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  completeButtonDisabled: {
    backgroundColor: 'rgba(216,184,107,0.42)',
  },
  completeButtonText: {
    color: colors.background,
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: 0.3,
  },
  completeHintText: {
    color: colors.textMuted,
    fontSize: 13,
    lineHeight: 19,
    marginTop: 10,
    textAlign: 'center',
  },
  shareLink: {
    marginTop: 10,
    paddingVertical: 6,
    alignItems: 'center',
  },
  shareLinkText: {
    color: colors.accent,
    fontWeight: '700',
    fontSize: 14,
  },
  chatEntry: {
    backgroundColor: colors.card,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    paddingHorizontal: 16,
    paddingVertical: 14,
    marginBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
  },
  chatEntryEyebrow: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 1.2,
    textTransform: 'uppercase',
    marginBottom: 5,
  },
  chatEntryTitle: {
    color: colors.text,
    fontSize: 17,
    fontWeight: '700',
    marginBottom: 5,
  },
  chatEntrySubtext: {
    color: colors.textMuted,
    fontSize: 13,
    lineHeight: 19,
  },
  chatEntryArrow: {
    color: colors.accent,
    fontSize: 24,
    fontWeight: '700',
    marginLeft: 10,
  },
  goDeeperEntry: {
    marginBottom: 12,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.18)',
    borderRadius: radius.lg,
    backgroundColor: 'rgba(216,184,107,0.06)',
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  goDeeperLabel: {
    color: colors.accent,
    fontSize: 11,
    letterSpacing: 1.8,
    marginBottom: 6,
  },
  goDeeperText: {
    color: colors.textSoft,
    fontSize: 14,
    lineHeight: 20,
  },
  completeToast: {
    position: 'absolute',
    left: spacing.lg,
    right: spacing.lg,
    bottom: 18,
    backgroundColor: colors.accent,
    borderRadius: radius.md,
    paddingVertical: 10,
    paddingHorizontal: 12,
    alignItems: 'center',
  },
  completeToastText: {
    color: colors.background,
    fontWeight: '700',
  },
  footerSpace: {
    height: 38,
  },
});
