import React from 'react';
import Animated, { FadeInDown } from 'react-native-reanimated';

type Props = {
  children: React.ReactNode;
  delay?: number;
};

export function AnimatedScreen({ children, delay = 0 }: Props) {
  return (
    <Animated.View entering={FadeInDown.delay(delay).duration(550)} style={{ flex: 1 }}>
      {children}
    </Animated.View>
  );
}