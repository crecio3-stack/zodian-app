import React, { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import Reanimated, { useAnimatedStyle, useSharedValue, withTiming } from 'react-native-reanimated';

// Try to load Lottie dynamically; if unavailable, fallback to a simple animated confetti set
let LottieView: any = null;
try {
   
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  LottieView = require('lottie-react-native');
} catch (_e) {
  LottieView = null;
}

export default function Celebration() {
  const [show, setShow] = useState(true);
  const opacity = useSharedValue(0);

  useEffect(() => {
    opacity.value = withTiming(1, { duration: 300 });
    const t = setTimeout(() => {
      opacity.value = withTiming(0, { duration: 300 });
      setTimeout(() => setShow(false), 300);
    }, 2600);
    return () => clearTimeout(t);
  }, [opacity]);

  const style = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: (1 - opacity.value) * -8 }],
  }));

  if (!show) return null;

  // If Lottie is available, play a remote lightweight celebration animation
  if (LottieView) {
    return (
      <Reanimated.View pointerEvents="none" style={[styles.container, style]}>
        {/* remote Lottie asset used to avoid bundling heavy JSON in repo */}
        <LottieView
          source={{ uri: 'https://assets7.lottiefiles.com/packages/lf20_jbrw3hcz.json' }}
          autoPlay
          loop={false}
          style={styles.lottie}
        />
      </Reanimated.View>
    );
  }

  // Fallback: simple gold burst using animated circles
  return (
    <Reanimated.View pointerEvents="none" style={[styles.container, style]}>
      <View style={styles.simpleBurst} />
    </Reanimated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 18,
    left: 0,
    right: 0,
    alignItems: 'center',
    zIndex: 999,
  },
  lottie: {
    width: 180,
    height: 180,
  },
  simpleBurst: {
    width: 140,
    height: 140,
    borderRadius: 999,
    backgroundColor: 'rgba(216,184,107,0.12)',
    borderWidth: 2,
    borderColor: 'rgba(216,184,107,0.22)',
  },
});