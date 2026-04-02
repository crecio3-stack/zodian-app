import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import { Pressable, StyleSheet, Text, ViewStyle } from 'react-native';
import Animated, {
    useAnimatedStyle,
    useSharedValue,
    withSpring,
} from 'react-native-reanimated';
import { colors, radius } from '../styles/theme';
import { shadows } from '../styles/tokens';

type Props = {
  title: string;
  onPress: () => void;
  style?: ViewStyle | ViewStyle[];
  variant?: 'primary' | 'secondary';
};

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export function PremiumButton({
  title,
  onPress,
  style,
  variant = 'primary',
}: Props) {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const onPressIn = () => {
    scale.value = withSpring(0.97, { damping: 14, stiffness: 220 });
  };

  const onPressOut = () => {
    scale.value = withSpring(1, { damping: 14, stiffness: 220 });
  };

  if (variant === 'secondary') {
    return (
      <AnimatedPressable
        onPress={onPress}
        onPressIn={onPressIn}
        onPressOut={onPressOut}
        style={[animatedStyle, style]}
      >
        <Pressable style={styles.secondaryButton}>
          <Text style={styles.secondaryText}>{title}</Text>
        </Pressable>
      </AnimatedPressable>
    );
  }

  return (
    <AnimatedPressable
      onPress={onPress}
      onPressIn={onPressIn}
      onPressOut={onPressOut}
      style={[animatedStyle, style]}
    >
      <LinearGradient
        colors={[colors.accent, colors.accentSoft]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.primaryButton}
      >
        <Text style={styles.primaryText}>{title}</Text>
      </LinearGradient>
    </AnimatedPressable>
  );
}

const styles = StyleSheet.create({
  primaryButton: {
    minHeight: 56,
    borderRadius: radius.pill,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 22,
    ...shadows.medium,
  },
  primaryText: {
    color: colors.text,
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: 0.3,
  },
  secondaryButton: {
    minHeight: 54,
    borderRadius: radius.pill,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 22,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.cardBorder,
  },
  secondaryText: {
    color: colors.textSoft,
    fontSize: 15,
    fontWeight: '600',
  },
});