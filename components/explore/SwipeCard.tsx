import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import React, { useEffect, useState } from 'react';
import { Dimensions, Pressable, StyleSheet, View } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, {
  Extrapolation,
  interpolate,
  runOnJS,
  SharedValue,
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withSequence,
  withSpring,
  withTiming,
} from 'react-native-reanimated';
import { colors } from '../../styles/theme';
import { radius, shadows } from '../../styles/tokens';
import { ZodiacProfile } from '../../types/zodiac';
import CardBack from './CardBack';
import CardFront from './CardFront';
import CardOverlay from './CardOverlay';
import DetailModal from './DetailModal';
import PersonBack from './PersonBack';
import PersonFront from './PersonFront';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const SWIPE_THRESHOLD = SCREEN_WIDTH * 0.25;
const OFFSCREEN_X = SCREEN_WIDTH * 1.2;

type SwipeDirection = 'left' | 'right';
type SwipeProfile = ZodiacProfile & { rawPerson?: unknown };

type Props = {
  profile: SwipeProfile;
  index: number;
  totalVisible: number;
  isTop: boolean;
  locked?: boolean;
  onSwiped: (direction: SwipeDirection) => void;
  deckPosition: SharedValue<number>;
};

export default function SwipeCard({
  profile,
  index,
  totalVisible,
  isTop,
  locked = false,
  onSwiped,
  deckPosition,
}: Props) {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const pressedScale = useSharedValue(1);
  const flipProgress = useSharedValue(0);
  const idleFloat = useSharedValue(0);
  const appear = useSharedValue(0);
  const [isFlipped, setIsFlipped] = useState(false);

  useEffect(() => {
    if (isTop) {
      idleFloat.value = withRepeat(
        withSequence(
          withTiming(1, { duration: 2400 }),
          withTiming(0, { duration: 2400 })
        ),
        -1,
        true
      );
    }

    // entrance animation for card
    appear.value = withTiming(1, { duration: 420 });
  }, [idleFloat, isTop, appear]);

  const triggerSwipe = (direction: SwipeDirection) => {
    onSwiped(direction);
  };

  const [showModal, setShowModal] = useState(false);

  const triggerFlip = () => {
    // Open full-screen detail modal instead of flipping the card in-place.
    setShowModal(true);
    Haptics.selectionAsync();

    (async () => {
      try { (await import('../../lib/ai/analytics')).trackEvent('explore.openDetail', { id: profile.id }); } catch {}
    })();
  };

  const pan = Gesture.Pan()
    .enabled(isTop && !locked)
    .onBegin(() => {
      pressedScale.value = withTiming(0.985, { duration: 100 });
    })
    .onUpdate((event) => {
      // Only treat as a horizontal swipe when horizontal movement clearly dominates
      const absX = Math.abs(event.translationX);
      const absY = Math.abs(event.translationY);
      const horizontalDominant = absX > absY * 1.2;
      if (horizontalDominant) {
        translateX.value = event.translationX;
        translateY.value = event.translationY * 0.08;
      }
      // if vertical dominant, let the ScrollView handle it (do not update translateX)
    })
    .onEnd((event) => {
      pressedScale.value = withTiming(1, { duration: 120 });

      const shouldSwipeRight =
        translateX.value > SWIPE_THRESHOLD || event.velocityX > 900;
      const shouldSwipeLeft =
        translateX.value < -SWIPE_THRESHOLD || event.velocityX < -900;

      if (shouldSwipeRight) {
        runOnJS(Haptics.impactAsync)(Haptics.ImpactFeedbackStyle.Medium);
        translateX.value = withTiming(OFFSCREEN_X, { duration: 220 }, (finished) => {
          if (finished) runOnJS(triggerSwipe)('right');
        });
        translateY.value = withTiming(0, { duration: 220 });
        return;
      }

      if (shouldSwipeLeft) {
        runOnJS(Haptics.impactAsync)(Haptics.ImpactFeedbackStyle.Light);
        translateX.value = withTiming(-OFFSCREEN_X, { duration: 220 }, (finished) => {
          if (finished) runOnJS(triggerSwipe)('left');
        });
        translateY.value = withTiming(0, { duration: 220 });
        return;
      }

      runOnJS(Haptics.selectionAsync)();
      translateX.value = withSpring(0, { damping: 18, stiffness: 180 });
      translateY.value = withSpring(0, { damping: 18, stiffness: 180 });
    });

  const animatedCardStyle = useAnimatedStyle(() => {
    const rotation = interpolate(
      translateX.value,
      [-SCREEN_WIDTH, 0, SCREEN_WIDTH],
      [-6, 0, 6],
      Extrapolation.CLAMP
    );

    const relativeIndex = index - deckPosition.value;
    const stackDepth = Math.max(0, relativeIndex);

    const stackScale = interpolate(stackDepth, [0, 1, 2], [1, 0.99, 0.98], Extrapolation.CLAMP);
    const stackTranslateY = interpolate(stackDepth, [0, 1, 2], [0, 7, 14], Extrapolation.CLAMP);

    const idleLift = isTop
      ? interpolate(idleFloat.value, [0, 1], [0, -4], Extrapolation.CLAMP)
      : 0;

    const entranceY = interpolate(appear.value, [0, 1], [12, 0], Extrapolation.CLAMP);
    const entranceOpacity = interpolate(appear.value, [0, 1], [0, 1], Extrapolation.CLAMP);

    return {
      zIndex: 100 - index,
      opacity: entranceOpacity,
      transform: [
        { translateX: translateX.value },
        { translateY: stackTranslateY + translateY.value + idleLift + entranceY },
        { rotateZ: `${rotation}deg` },
        { scale: stackScale },
        { scale: pressedScale.value },
      ],
    };
  });

  // subtle parallax for inner content to increase perceived depth
  const innerParallax = useAnimatedStyle(() => {
    const px = interpolate(translateX.value, [-SCREEN_WIDTH, 0, SCREEN_WIDTH], [-12, 0, 12], Extrapolation.CLAMP);
    const rotateY = interpolate(translateX.value, [-SCREEN_WIDTH, 0, SCREEN_WIDTH], [6, 0, -6], Extrapolation.CLAMP);
    return {
      transform: [{ translateX: px }, { rotateY: `${rotateY}deg` }],
    };
  });

  // Use a subtle tilt + crossfade instead of a full 180° rotation to avoid text rasterization blur
  const frontStyle = useAnimatedStyle(() => {
    const tilt = interpolate(flipProgress.value, [0, 1], [0, 6]); // small tilt
    const opacity = interpolate(flipProgress.value, [0, 0.45, 0.5, 1], [1, 0.95, 0, 0]);
    const scale = interpolate(flipProgress.value, [0, 1], [1, 0.995]);

    return {
      opacity,
      transform: [{ perspective: 1000 }, { rotateY: `${tilt}deg` }, { scale }],
    };
  });

  const backStyle = useAnimatedStyle(() => {
    const tilt = interpolate(flipProgress.value, [0, 1], [-6, 0]);
    const opacity = interpolate(flipProgress.value, [0, 0.5, 0.55, 1], [0, 0, 0.95, 1]);
    const scale = interpolate(flipProgress.value, [0, 1], [0.995, 1]);

    return {
      opacity,
      transform: [{ perspective: 1000 }, { rotateY: `${tilt}deg` }, { scale }],
    };
  });

  return (
    <>
      <Animated.View style={[styles.absoluteFill, animatedCardStyle]} pointerEvents={isTop ? 'auto' : 'none'}>
        <GestureDetector gesture={pan}>
          <Pressable
            style={styles.pressable}
            disabled={locked}
            onPress={triggerFlip}
            onLongPress={() => {
              // long-press = quick save
              onSwiped('right');
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
            }}
            accessibilityRole="button"
            accessibilityLabel={`Profile card ${profile.sign} ${profile.archetype}`}>
                <View style={styles.cardShell}>
              <Animated.View style={styles.rimGradient} pointerEvents="none">
                <LinearGradient
                  colors={["rgba(255,215,100,0.06)", "transparent"]}
                  start={[0.5, 0]}
                  end={[0.5, 1]}
                  style={StyleSheet.absoluteFill}
                />
              </Animated.View>

              <View style={styles.innerFrame}>
                {isTop && <CardOverlay translateX={translateX} threshold={SWIPE_THRESHOLD} />}

                <Animated.View
                  renderToHardwareTextureAndroid={true}
                  shouldRasterizeIOS={false}
                  style={[styles.face, frontStyle]}>
                  <Animated.View style={[styles.faceFill, innerParallax]}>
                  {profile?.rawPerson ? (
                    <PersonFront profile={profile} />
                  ) : (
                    <CardFront profile={profile} />
                  )}
                </Animated.View>
                </Animated.View>

                <Animated.View
                  renderToHardwareTextureAndroid={true}
                  shouldRasterizeIOS={false}
                  style={[styles.face, backStyle]}>
                  <Animated.View style={[styles.faceFill, innerParallax]}>
                    {profile?.rawPerson ? (
                      <PersonBack profile={profile} />
                    ) : (
                      <CardBack profile={profile} />
                    )}
                  </Animated.View>
                </Animated.View>
              </View>
            </View>
          </Pressable>
        </GestureDetector>
      </Animated.View>

      {showModal && (
        <DetailModal visible={showModal} profile={profile} onClose={() => setShowModal(false)} />
      )}
    </>
  );
}

const styles = StyleSheet.create({
  absoluteFill: {
    position: 'absolute',
    width: '100%',
    height: '100%',
  },
  pressable: {
    flex: 1,
  },
  cardShell: {
    flex: 1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.card,
    overflow: 'hidden',
    ...shadows.soft,
  },
  rimGradient: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.9,
  },
  innerFrame: {
    flex: 1,
    borderRadius: radius.xl - 1,
    overflow: 'hidden',
    backgroundColor: colors.card,
  },
  face: {
    ...StyleSheet.absoluteFillObject,
    backfaceVisibility: 'hidden',
  },
  faceFill: {
    flex: 1,
    backgroundColor: colors.card,
    padding: 18,
  },
});