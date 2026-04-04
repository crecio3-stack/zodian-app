import { BlurView } from 'expo-blur';
import * as Haptics from 'expo-haptics';
import React, { useMemo, useState } from 'react';
import { Dimensions, Pressable, StyleSheet, Text, View } from 'react-native';
import { useSharedValue, withSpring } from 'react-native-reanimated';
import { useSavedProfiles } from '../../hooks/useSavedProfiles';
import { addMatch } from '../../lib/storage/matchService';
import { colors } from '../../styles/theme';
import { radius, spacing, type } from '../../styles/tokens';
import { ZodiacProfile } from '../../types/zodiac';
import EmptyExploreState from './EmptyExploreState';
import MatchModal from './MatchModal';
import SwipeCard from './SwipeCard';

const { height: SCREEN_HEIGHT } = Dimensions.get('window');

type SwipeDirection = 'left' | 'right';

type Props = {
  data: ZodiacProfile[];
  isPremium?: boolean;
  freeSwipeLimit?: number;
  swipesLeft?: number;
  onConsumeSwipe?: () => Promise<unknown>;
  onUnlockMore?: () => void;
  showBackdropBlur?: boolean;
};

const VISIBLE_CARDS = 3;
// Allow larger cards on taller devices while keeping a cap
const CARD_HEIGHT = Math.min(640, SCREEN_HEIGHT * 0.65);

export default function SwipeDeck({
  data,
  isPremium = false,
  freeSwipeLimit = 3,
  swipesLeft,
  onConsumeSwipe,
  onUnlockMore,
  showBackdropBlur = false,
}: Props) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [localFreeSwipesUsed, setLocalFreeSwipesUsed] = useState(0);
  const deckPosition = useSharedValue(0);

  const { addSaved, addSkipped, reset } = useSavedProfiles();

  const remaining = useMemo(() => data.slice(currentIndex), [data, currentIndex]);
  const visibleCards = remaining.slice(0, VISIBLE_CARDS);
  const isControlled = typeof swipesLeft === 'number';
  const availableSwipes = isControlled ? Math.max(0, swipesLeft ?? 0) : Math.max(0, freeSwipeLimit - localFreeSwipesUsed);
  const isLocked = !isPremium && availableSwipes <= 0;

  const [matchProfile, setMatchProfile] = useState<ZodiacProfile | null>(null);

  const computeMutual = (profile: any) => {
    // deterministic-ish: use id charcodes + compatibility to decide mock mutual
    const seed = (profile.id || profile.name || '').split('').reduce((s: number, c: string) => s + c.charCodeAt(0), 0);
    const pseudo = seed % 100;
    const compat = profile.compatibility?.score ?? 50;
    // if high compatibility, more likely; otherwise 1-in-4 chance
    return compat >= 80 || pseudo % 4 === 0;
  };

  const handleSwipe = async (direction: SwipeDirection) => {
    if (isLocked) return;

    // Analytics hook
    try {
      (await import('../../lib/ai/analytics')).trackEvent('explore.swipe', { direction });
    } catch {}

    const current = data[currentIndex];
    if (!current) return;

    if (direction === 'right') {
      await addSaved(current.id);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

      const isMutual = computeMutual(current);
      if (isMutual) {
        // persist match locally and show match UI
        try {
          await addMatch(current);
        } catch {}
        setMatchProfile(current);
        try {
          (await import('../../lib/ai/analytics')).trackEvent('explore.match', { id: current.id });
        } catch {}
      }
    } else {
      await addSkipped(current.id);
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }

    const nextIndex = currentIndex + 1;
    setCurrentIndex(nextIndex);
    if (!isPremium) {
      if (onConsumeSwipe) {
        await onConsumeSwipe();
      } else {
        setLocalFreeSwipesUsed((prev) => prev + 1);
      }
    }
    deckPosition.value = withSpring(nextIndex, { damping: 16, stiffness: 140 });
  };

  const resetDeck = () => {
    setCurrentIndex(0);
    if (!isControlled) {
      setLocalFreeSwipesUsed(0);
    }
    reset();
    deckPosition.value = 0;
  };

  if (!remaining.length) {
    return <EmptyExploreState onReset={resetDeck} />;
  }


  return (
    <View style={styles.container}>
      {!isPremium ? (
        <View style={styles.freePill}>
          <Text style={styles.freePillText}>{availableSwipes} swipes left today</Text>
        </View>
      ) : null}

      <View style={styles.deck}>
        {showBackdropBlur ? (
          <>
            <View style={styles.deckGlow} />
            <BlurView intensity={40} tint="dark" style={styles.deckBlurLayer} />
          </>
        ) : null}

        {[...visibleCards].reverse().map((profile, reverseIdx) => {
          const actualIndex = currentIndex + (visibleCards.length - 1 - reverseIdx);
          const visibleIndex = actualIndex - currentIndex;

          return (
            <SwipeCard
              key={profile.id}
              profile={profile}
              index={actualIndex}
              totalVisible={VISIBLE_CARDS}
              isTop={visibleIndex === 0}
              locked={isLocked}
              onSwiped={handleSwipe}
              deckPosition={deckPosition}
            />
          );
        })}

        {isLocked ? (
          <View style={styles.lockWrap}>
            <BlurView intensity={68} tint="dark" style={StyleSheet.absoluteFill} />
            <View style={styles.lockCard}>
              <Text style={styles.lockTitle}>No swipes left today</Text>
              <Text style={styles.lockBody}>Unlock more connections</Text>
              <Pressable style={styles.lockCta} onPress={onUnlockMore}>
                <Text style={styles.lockCtaText}>Unlock more connections</Text>
              </Pressable>
            </View>
          </View>
        ) : null}
      </View>

      <View style={styles.footer}>
        <View style={styles.footerRule} />
        <Text style={styles.footerText}>
          Swipe right to keep an energy. Swipe left to move on. Tap a card to reveal more.
        </Text>
      </View>

      {matchProfile ? (
        <MatchModal visible={Boolean(matchProfile)} profile={matchProfile} onClose={() => setMatchProfile(null)} />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  freePill: {
    alignSelf: 'center',
    marginBottom: spacing.sm,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.pill,
    backgroundColor: colors.card,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
  },
  freePillText: {
    ...type.label,
    color: colors.accent,
  },

  deck: {
    height: CARD_HEIGHT,
    position: 'relative',
    overflow: 'hidden',
    borderRadius: radius.xl,
  },
  deckGlow: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(214,181,107,0.08)',
  },
  deckBlurLayer: {
    ...StyleSheet.absoluteFillObject,
  },
  lockWrap: {
    ...StyleSheet.absoluteFillObject,
    zIndex: 30,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.md,
  },
  lockCard: {
    width: '100%',
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(8,8,10,0.78)',
    padding: spacing.lg,
    alignItems: 'center',
  },
  lockTitle: {
    ...type.label,
    color: colors.accent,
    marginBottom: spacing.xs,
  },
  lockBody: {
    ...type.title2,
    color: colors.text,
    textAlign: 'center',
    marginBottom: spacing.md,
  },
  lockCta: {
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
  },
  lockCtaText: {
    color: '#111111',
    fontWeight: '800',
    fontSize: 14,
  },

  footer: {
    paddingTop: spacing.md,
    paddingHorizontal: spacing.sm,
    alignItems: 'center',
  },

  footerRule: {
    width: 44,
    height: 3,
    borderRadius: 999,
    backgroundColor: colors.border,
    marginBottom: 12,
  },

  footerText: {
    ...type.body,
    color: colors.textMuted,
    textAlign: 'center',
    lineHeight: 22,
  },
});