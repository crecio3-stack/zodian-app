import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React, { useEffect, useRef } from 'react';
import {
    Animated,
    Easing,
    Platform,
    Pressable,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { EVENTS, trackAppEvent, trackScreenView } from '../../lib/analytics/analytics';
import { saveOnboardingStep } from '../../lib/storage/onboardingProgress';
import { colors } from '../../styles/theme';

export default function WelcomeScreen() {
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const translateAnim = useRef(new Animated.Value(22)).current;
  const shimmer = useRef(new Animated.Value(0)).current;
  const ambientGlow = useRef(new Animated.Value(0)).current;
  const buttonScale = useRef(new Animated.Value(1)).current;
  const detailsOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 760,
        easing: Easing.out(Easing.ease),
        useNativeDriver: false,
      }),
      Animated.timing(translateAnim, {
        toValue: 0,
        duration: 680,
        easing: Easing.out(Easing.ease),
        useNativeDriver: false,
      }),
      Animated.timing(detailsOpacity, {
        toValue: 1,
        duration: 700,
        delay: 180,
        easing: Easing.out(Easing.ease),
        useNativeDriver: false,
      }),
    ]).start();

    Animated.loop(
      Animated.sequence([
        Animated.timing(shimmer, {
          toValue: 1,
          duration: 1900,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
        Animated.timing(shimmer, {
          toValue: 0,
          duration: 1900,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
      ])
    ).start();

    Animated.loop(
      Animated.sequence([
        Animated.timing(ambientGlow, {
          toValue: 1,
          duration: 2800,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
        Animated.timing(ambientGlow, {
          toValue: 0,
          duration: 2800,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
      ])
    ).start();
  }, [ambientGlow, detailsOpacity, fadeAnim, shimmer, translateAnim]);

  useEffect(() => {
    trackScreenView('onboarding_welcome').catch(() => {});
    trackAppEvent(EVENTS.ONBOARDING_START, { entry: 'welcome' }).catch(() => {});
    trackAppEvent(EVENTS.ONBOARDING_STEP_VIEWED, { step: 'welcome', stepIndex: 1 }).catch(() => {});
    saveOnboardingStep('welcome').catch(() => {});
  }, []);

  const handleContinue = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    await trackAppEvent(EVENTS.ONBOARDING_STEP_COMPLETED, { step: 'welcome', stepIndex: 1 }).catch(() => {});
    router.push('./name');
  };

  const handlePressIn = () => {
    Animated.spring(buttonScale, {
      toValue: 0.985,
      speed: 24,
      bounciness: 4,
      useNativeDriver: false,
    }).start();
  };

  const handlePressOut = () => {
    Animated.spring(buttonScale, {
      toValue: 1,
      speed: 24,
      bounciness: 6,
      useNativeDriver: false,
    }).start();
  };

  const glowOpacity = shimmer.interpolate({
    inputRange: [0, 1],
    outputRange: [0.14, 0.28],
  });

  const logoOpacity = shimmer.interpolate({
    inputRange: [0, 1],
    outputRange: [0.9, 1],
  });

  const orbOpacity = ambientGlow.interpolate({
    inputRange: [0, 1],
    outputRange: [0.08, 0.18],
  });

  return (
    <SafeAreaView style={styles.safeArea}>
      <LinearGradient
        colors={['#040404', colors.background, '#020202']}
        style={StyleSheet.absoluteFill}
      />

      <Animated.View pointerEvents="none" style={[styles.ambientOrb, { opacity: orbOpacity }]} />

      <Animated.View
        style={[
          styles.container,
          {
            opacity: fadeAnim,
            transform: [{ translateY: translateAnim }],
          },
        ]}
      >
        <View style={styles.logoWrap}>
          <Animated.View style={[styles.logoGlow, { opacity: glowOpacity }]} />
          <Animated.Text style={[styles.logoText, { opacity: logoOpacity }]}>
            ZODIAN
          </Animated.Text>
        </View>

        <Animated.Text style={[styles.stepPill, { opacity: detailsOpacity }]}> 
          STEP 1 OF 4
        </Animated.Text>

        <View style={styles.content}>
          <Text style={styles.title}>
            Build your cosmic identity.
          </Text>

          <Text style={styles.subtitle}>
            We combine your Western and Eastern signs to reveal who you really are—not just one side of the picture.
          </Text>

          <Animated.View style={[styles.featureList, { opacity: detailsOpacity }]}> 
            <View style={styles.featureRow}>
              <View style={styles.featureDot} />
              <Text style={styles.featureText}>Personal sign profile</Text>
            </View>
            <View style={styles.featureRow}>
              <View style={styles.featureDot} />
              <Text style={styles.featureText}>Daily love and energy ritual</Text>
            </View>
            <View style={styles.featureRow}>
              <View style={styles.featureDot} />
              <Text style={styles.featureText}>Compatibility and matches</Text>
            </View>
          </Animated.View>
        </View>

        <View style={styles.footer}>
          <Text style={styles.microCopy}>Takes less than a minute</Text>

          <Animated.View style={{ transform: [{ scale: buttonScale }] }}>
            <Pressable
              style={styles.button}
              onPress={handleContinue}
              onPressIn={handlePressIn}
              onPressOut={handlePressOut}
            >
              <LinearGradient
                colors={['#D8B86B', colors.accent]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.buttonGradient}
              >
                <Text style={styles.buttonText}>Begin Setup</Text>
              </LinearGradient>
            </Pressable>
          </Animated.View>
        </View>
      </Animated.View>
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
  ambientOrb: {
    position: 'absolute',
    top: '12%',
    left: 20,
    right: 20,
    height: 320,
    borderRadius: 999,
    backgroundColor: 'rgba(216,184,107,0.14)',
  },
  container: {
    flex: 1,
    paddingHorizontal: 24,
    paddingTop: 26,
    paddingBottom: 30,
  },
  logoWrap: {
    alignItems: 'center',
    marginBottom: 24,
    minHeight: 52,
    justifyContent: 'center',
  },
  logoGlow: {
    position: 'absolute',
    width: 240,
    height: 60,
    borderRadius: 999,
    backgroundColor: 'rgba(216,184,107,0.2)',
  },
  logoText: {
    color: colors.accent,
    fontSize: 28,
    letterSpacing: 5,
    fontWeight: '700',
    fontFamily: luxurySerif,
  },
  stepPill: {
    color: colors.accent,
    alignSelf: 'center',
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.2)',
    backgroundColor: 'rgba(216,184,107,0.08)',
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 6,
    textAlign: 'center',
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700',
    marginBottom: 22,
  },
  content: {
    marginTop: 18,
    marginBottom: 22,
  },
  title: {
    color: colors.text,
    fontSize: 40,
    lineHeight: 46,
    textAlign: 'center',
    marginBottom: 12,
    fontWeight: '700',
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 16,
    lineHeight: 24,
    textAlign: 'left',
    maxWidth: 360,
  },
  featureList: {
    marginTop: 24,
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.14)',
    borderRadius: 20,
    paddingHorizontal: 14,
    paddingVertical: 14,
    gap: 10,
  },
  featureRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  featureDot: {
    width: 6,
    height: 6,
    borderRadius: 99,
    backgroundColor: colors.accent,
    marginRight: 10,
  },
  featureText: {
    color: colors.text,
    fontSize: 14,
    lineHeight: 20,
  },
  footer: {
    marginTop: 'auto',
    gap: 14,
  },
  microCopy: {
    color: 'rgba(255,255,255,0.5)',
    textAlign: 'center',
    fontSize: 13,
    letterSpacing: 0.2,
  },
  button: {
    borderRadius: 999,
    overflow: 'hidden',
  },
  buttonGradient: {
    paddingVertical: 16,
    alignItems: 'center',
    borderRadius: 999,
  },
  buttonText: {
    color: colors.text,
    fontSize: 17,
    fontWeight: '700',
  },
});