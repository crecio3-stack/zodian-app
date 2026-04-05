import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
    Animated,
    Easing,
    Platform,
    Pressable,
    StyleSheet,
    Text,
    TextInput,
    View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useStoredName } from '../../hooks/useStoredName';
import { EVENTS, trackAppEvent, trackScreenView } from '../../lib/analytics/analytics';
import { saveOnboardingStep } from '../../lib/storage/onboardingProgress';
import { colors } from '../../styles/theme';

export default function NameScreen() {
  const { name, saveName } = useStoredName();
  const [input, setInput] = useState(name ?? '');

  useEffect(() => {
    if (name && !input) {
      setInput(name);
    }
  }, [name, input]);

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const translateAnim = useRef(new Animated.Value(18)).current;
  const shimmerAnim = useRef(new Animated.Value(0)).current;
  const ambientGlow = useRef(new Animated.Value(0)).current;
  const buttonScale = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 700,
        easing: Easing.out(Easing.ease),
        useNativeDriver: false,
      }),
      Animated.timing(translateAnim, {
        toValue: 0,
        duration: 700,
        easing: Easing.out(Easing.ease),
        useNativeDriver: false,
      }),
    ]).start();

    Animated.loop(
      Animated.sequence([
        Animated.timing(shimmerAnim, {
          toValue: 1,
          duration: 1800,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
        Animated.timing(shimmerAnim, {
          toValue: 0,
          duration: 1800,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
      ])
    ).start();

    Animated.loop(
      Animated.sequence([
        Animated.timing(ambientGlow, {
          toValue: 1,
          duration: 2500,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
        Animated.timing(ambientGlow, {
          toValue: 0,
          duration: 2500,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: false,
        }),
      ])
    ).start();
  }, [ambientGlow, fadeAnim, shimmerAnim, translateAnim]);

  useEffect(() => {
    trackScreenView('onboarding_name').catch(() => {});
    trackAppEvent(EVENTS.ONBOARDING_STEP_VIEWED, {
      step: 'name',
      stepIndex: 2,
      hasExistingName: Boolean(name?.trim()),
    }).catch(() => {});
    saveOnboardingStep('name').catch(() => {});
  }, [name]);

  const cleaned = useMemo(() => input.trim().replace(/\s+/g, ' '), [input]);
  const canContinue = cleaned.length >= 2;

  const handleContinue = async () => {
    if (!canContinue) return;
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    await saveName(cleaned);
    await trackAppEvent(EVENTS.ONBOARDING_STEP_COMPLETED, {
      step: 'name',
      stepIndex: 2,
      nameLength: cleaned.length,
    }).catch(() => {});
    router.push('./birthdate');
  };

  const handlePressIn = () => {
    Animated.spring(buttonScale, {
      toValue: 0.985,
      speed: 28,
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

  const handleSkip = async () => {
    await Haptics.selectionAsync();
    await saveName('');
    await trackAppEvent(EVENTS.ONBOARDING_SKIP, { step: 'name', stepIndex: 2 }).catch(() => {});
    router.push('./birthdate');
  };

  const logoOpacity = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.88, 1],
  });

  const glowOpacity = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.18, 0.34],
  });

  const stageGlow = ambientGlow.interpolate({
    inputRange: [0, 1],
    outputRange: [0.08, 0.18],
  });

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <LinearGradient
        colors={['#040404', colors.background, '#020202']}
        style={StyleSheet.absoluteFill}
      />

      <Animated.View pointerEvents="none" style={[styles.ambientOrb, { opacity: stageGlow }]} />

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
          <Animated.View pointerEvents="none" style={[styles.logoGlow, { opacity: glowOpacity }]} />
          <Animated.Text style={[styles.logoText, { opacity: logoOpacity }]}>ZODIAN</Animated.Text>
        </View>

        <Text style={styles.stepPill}>STEP 2 OF 4</Text>
        <Text style={styles.stepHint}>Swipe from the left edge anytime to go back.</Text>
        <Text style={styles.title}>How should we call you?</Text>
        <Text style={styles.subtitle}>
          Your name helps Zodian make every ritual and chat feel personal.
        </Text>

        <View style={styles.card}>
          <Text style={styles.cardEyebrow}>COSMIC IDENTITY NAME</Text>
          <TextInput
            value={input}
            onChangeText={setInput}
            placeholder="Enter your first name"
            placeholderTextColor={colors.textMuted}
            autoCapitalize="words"
            autoCorrect={false}
            maxLength={36}
            style={styles.input}
            returnKeyType="done"
            onSubmitEditing={handleContinue}
          />
          <Text style={styles.noteText}>Used only to personalize your in-app experience.</Text>
        </View>

        <Animated.View style={[styles.buttonOuter, { transform: [{ scale: buttonScale }] }]}> 
          <Pressable
            style={[styles.button, !canContinue && styles.buttonDisabled]}
            onPress={handleContinue}
            onPressIn={handlePressIn}
            onPressOut={handlePressOut}
            disabled={!canContinue}
          >
            <LinearGradient
              colors={canContinue ? ['#D8B86B', colors.accent] : ['#7f7151', '#7f7151']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.buttonGradient}
            >
              <Text style={styles.buttonText}>Continue</Text>
            </LinearGradient>
          </Pressable>
          {!canContinue ? <Text style={styles.inputHint}>Enter at least 2 letters to continue.</Text> : null}
        </Animated.View>

        <Pressable style={styles.skipButton} onPress={handleSkip}>
          <Text style={styles.skipButtonText}>Skip for now</Text>
        </Pressable>
        <Text style={styles.skipHint}>You can update this anytime in Profile.</Text>
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
    top: '16%',
    left: 30,
    right: 30,
    height: 260,
    borderRadius: 999,
    backgroundColor: 'rgba(216,184,107,0.12)',
  },
  container: {
    flex: 1,
    paddingHorizontal: 24,
    paddingTop: 32,
    paddingBottom: 32,
  },
  logoWrap: {
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 24,
    minHeight: 52,
  },
  logoGlow: {
    position: 'absolute',
    width: 220,
    height: 60,
    borderRadius: 999,
    backgroundColor: 'rgba(216,184,107,0.18)',
  },
  logoText: {
    color: colors.accent,
    fontSize: 28,
    letterSpacing: 5,
    fontWeight: '700',
    fontFamily: luxurySerif,
  },
  stepPill: {
    alignSelf: 'flex-start',
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.2)',
    backgroundColor: 'rgba(216,184,107,0.08)',
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 6,
    color: colors.accent,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 2,
    marginBottom: 8,
  },
  stepHint: {
    color: colors.textMuted,
    fontSize: 12,
    lineHeight: 16,
    marginBottom: 12,
  },
  title: {
    color: colors.text,
    fontSize: 38,
    lineHeight: 44,
    fontWeight: '700',
    marginBottom: 12,
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 24,
  },
  card: {
    backgroundColor: colors.cardStrong,
    borderRadius: 24,
    padding: 20,
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.16)',
    marginBottom: 24,
  },
  cardEyebrow: {
    color: colors.accent,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.8,
    marginBottom: 14,
  },
  input: {
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.22)',
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 12,
    color: colors.text,
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 10,
  },
  noteText: {
    color: colors.textMuted,
    fontSize: 13,
    lineHeight: 18,
  },
  buttonOuter: {
    marginTop: 'auto',
  },
  inputHint: {
    color: colors.textMuted,
    fontSize: 12,
    lineHeight: 16,
    textAlign: 'center',
    marginTop: 10,
  },
  skipButton: {
    alignSelf: 'center',
    marginTop: 14,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  skipHint: {
    color: colors.textMuted,
    fontSize: 12,
    lineHeight: 16,
    textAlign: 'center',
    marginTop: 4,
  },
  skipButtonText: {
    color: colors.textMuted,
    fontSize: 13,
    fontWeight: '600',
  },
  button: {
    borderRadius: 999,
    overflow: 'hidden',
  },
  buttonDisabled: {
    opacity: 0.72,
  },
  buttonGradient: {
    height: 56,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 999,
  },
  buttonText: {
    color: '#111111',
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: 0.3,
  },
});
