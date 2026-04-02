import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Animated, {
  interpolate,
  SharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import { premiumTheme } from '../../styles/premiumTheme';
import { radius, spacing, type } from '../../styles/tokens';

type Props = {
  translateX: SharedValue<number>;
  threshold: number;
};

export default function CardOverlay({ translateX, threshold }: Props) {
  const likeStyle = useAnimatedStyle(() => {
    const opacity = interpolate(translateX.value, [0, threshold], [0, 1], 'clamp');
    const scale = interpolate(translateX.value, [0, threshold], [0.92, 1], 'clamp');

    return {
      opacity,
      transform: [{ scale }, { rotate: '4deg' }],
    };
  });

  const passStyle = useAnimatedStyle(() => {
    const opacity = interpolate(translateX.value, [0, -threshold], [0, 1], 'clamp');
    const scale = interpolate(translateX.value, [0, -threshold], [0.92, 1], 'clamp');

    return {
      opacity,
      transform: [{ scale }, { rotate: '-4deg' }],
    };
  });

  return (
    <>
      <Animated.View style={[styles.leftWrap, passStyle]}>
        <View style={[styles.badge, styles.passBadge]}>
          <Text style={styles.badgeText}>NOPE</Text>
        </View>
      </Animated.View>

      <Animated.View style={[styles.rightWrap, likeStyle]}>
        <View style={[styles.badge, styles.likeBadge]}>
          <Text style={styles.badgeText}>LIKE</Text>
        </View>
      </Animated.View>
    </>
  );
}

const styles = StyleSheet.create({
  leftWrap: {
    position: 'absolute',
    top: spacing.lg,
    left: spacing.lg,
    zIndex: 20,
  },
  rightWrap: {
    position: 'absolute',
    top: spacing.lg,
    right: spacing.lg,
    zIndex: 20,
  },
  badge: {
    borderRadius: radius.pill,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderWidth: 1,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 8 },
    elevation: 6,
  },
  likeBadge: {
    backgroundColor: premiumTheme.colors.likeFill,
    borderColor: premiumTheme.colors.borderStrong,
  },
  passBadge: {
    backgroundColor: premiumTheme.colors.passFill,
    borderColor: 'rgba(255,255,255,0.15)',
  },
  badgeText: {
    ...type.label,
    color: premiumTheme.colors.text,
  },
});