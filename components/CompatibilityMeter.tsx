import React, { useEffect, useRef } from 'react';
import { Animated, StyleSheet, Text, View } from 'react-native';
import { theme } from '../styles/theme';

const { colors } = theme;

type Props = {
  score: number; // 0 - 100
  size?: number;
};

export default function CompatibilityMeter({ score, size = 120 }: Props) {
  const fill = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(fill, {
      toValue: Math.max(0, Math.min(100, score)),
      duration: 700,
      useNativeDriver: false,
    }).start();
  }, [score, fill]);

  const widthInterpolate = fill.interpolate({
    inputRange: [0, 100],
    outputRange: ['0%', '100%'],
  });

  const ringColor = score > 85 ? colors.success : score > 70 ? colors.accent : colors.warning;

  return (
    <View style={[styles.wrap, { width: size, height: size }]}>
      <View style={[styles.circle, { borderColor: 'rgba(255,255,255,0.04)' }]}>
        <View style={styles.inner}>
          <Animated.View style={[styles.fillBar, { width: widthInterpolate, backgroundColor: ringColor }]} />
          <Text style={styles.scoreText}>{Math.round(score)}%</Text>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  circle: {
    borderRadius: 999,
    width: '100%',
    height: '100%',
    borderWidth: 10,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  inner: {
    width: '84%',
    height: '84%',
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.02)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  fillBar: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    borderTopLeftRadius: 999,
    borderBottomLeftRadius: 999,
    opacity: 0.16,
  },
  scoreText: {
    color: colors.text,
    fontSize: 28,
    fontWeight: '700',
  },
});
