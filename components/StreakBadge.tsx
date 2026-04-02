import React, { useEffect } from 'react';
import { Platform, StyleSheet, Text, View } from 'react-native';
import Reanimated, { useAnimatedStyle, useSharedValue, withDelay, withTiming } from 'react-native-reanimated';
import { colors } from '../styles/theme';

type Props = {
  count?: number;
};

export default function StreakBadge({ count = 0 }: Props) {
  const show = useSharedValue(0);

  useEffect(() => {
    // entrance animation
    show.value = withDelay(120, withTiming(1, { duration: 420 }));
  }, [show]);

  const style = useAnimatedStyle(() => ({
    opacity: show.value,
    transform: [{ translateY: (1 - show.value) * 8 }],
  }));

  return (
    <Reanimated.View style={[styles.wrap, style]} pointerEvents="none">
      <View style={styles.badgeInner}>
        <Text style={styles.fire}>🔥</Text>
        <Text style={styles.count}>{count}</Text>
        <Text style={styles.label}>day streak</Text>
      </View>
    </Reanimated.View>
  );
}

const luxurySerif = Platform.select({ ios: 'Georgia', android: 'serif', default: 'serif' });

const styles = StyleSheet.create({
  wrap: {
    alignItems: 'center',
    marginTop: 12,
  },
  badgeInner: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderColor: 'rgba(216,184,107,0.08)',
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
  },
  fire: {
    marginRight: 8,
    fontSize: 14,
  },
  count: {
    color: colors.text,
    fontWeight: '800',
    fontSize: 14,
    marginRight: 8,
    fontFamily: luxurySerif,
  },
  label: {
    color: colors.textMuted,
    fontSize: 12,
    textTransform: 'lowercase',
  },
});