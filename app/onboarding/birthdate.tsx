import DateTimePicker from '@react-native-community/datetimepicker';
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
import { useStoredBirthdate } from '../../hooks/useStoredBirthdate';
import { EVENTS, trackAppEvent, trackScreenView } from '../../lib/analytics/analytics';
import { saveOnboardingStep } from '../../lib/storage/onboardingProgress';
import { colors } from '../../styles/theme';

export default function BirthdateScreen() {
  const { selectedDate, setSelectedDate, saveBirthdate } =
    useStoredBirthdate(new Date());

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const translateAnim = useRef(new Animated.Value(18)).current;
  const shimmerAnim = useRef(new Animated.Value(0)).current;
  const ambientGlow = useRef(new Animated.Value(0)).current;
  const buttonScale = useRef(new Animated.Value(1)).current;
  const noteOpacity = useRef(new Animated.Value(0)).current;

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
      Animated.timing(noteOpacity, {
        toValue: 1,
        duration: 900,
        delay: 150,
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
  }, [ambientGlow, fadeAnim, noteOpacity, shimmerAnim, translateAnim]);

  useEffect(() => {
    trackScreenView('onboarding_birthdate').catch(() => {});
    trackAppEvent(EVENTS.ONBOARDING_STEP_VIEWED, {
      step: 'birthdate',
      stepIndex: 3,
    }).catch(() => {});
    saveOnboardingStep('birthdate').catch(() => {});
  }, []);

  const handleContinue = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    await saveBirthdate(selectedDate);
    await trackAppEvent(EVENTS.ONBOARDING_STEP_COMPLETED, {
      step: 'birthdate',
      stepIndex: 3,
      birthYear: selectedDate.getFullYear(),
    }).catch(() => {});
    router.push('./reveal');
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

  const logoOpacity = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.88, 1],
  });

  const glowOpacity = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.18, 0.34],
  });

  const cardBorderColor = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['rgba(216,184,107,0.14)', 'rgba(216,184,107,0.24)'],
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
          <Animated.View
            pointerEvents="none"
            style={[
              styles.logoGlow,
              {
                opacity: glowOpacity,
              },
            ]}
          />
          <Animated.Text
            style={[
              styles.logoText,
              {
                opacity: logoOpacity,
              },
            ]}
          >
            ZODIAN
          </Animated.Text>
        </View>

        <Text style={styles.stepPill}>STEP 3 OF 4</Text>
        <Text style={styles.stepHint}>Swipe from the left edge anytime to go back.</Text>

        <Text style={styles.title}>What’s your birthdate?</Text>
        <Text style={styles.subtitle}>
          This unlocks your western sign, eastern sign, and your full cosmic identity.
        </Text>

        <Animated.View
          style={[
            styles.card,
            {
              borderColor: cardBorderColor,
            },
          ]}
        >
          <LinearGradient
            colors={[
              'rgba(255,255,255,0.04)',
              'rgba(255,255,255,0.02)',
              'rgba(212,176,106,0.03)',
            ]}
            style={StyleSheet.absoluteFill}
          />

          <Text style={styles.cardEyebrow}>BIRTH CHART ENTRY</Text>

          <View style={styles.pickerWrap}>
            <DateTimePicker
              value={selectedDate}
              mode="date"
              display="spinner"
              onChange={(_, date) => {
                if (date) setSelectedDate(date);
              }}
              maximumDate={new Date()}
              textColor={colors.text}
              themeVariant="dark"
            />
          </View>

          <Animated.View style={[styles.noteWrap, { opacity: noteOpacity }]}>
            <View style={styles.noteLine} />
            <Text style={styles.noteText}>Your identity is ready to be revealed.</Text>
          </Animated.View>

        </Animated.View>

        <Animated.View
          style={[
            styles.buttonOuter,
            {
              transform: [{ scale: buttonScale }],
            },
          ]}
        >
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
              <Text style={styles.buttonText}>Reveal My Identity</Text>
            </LinearGradient>
          </Pressable>
        </Animated.View>
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
  title: {
    color: colors.text,
    fontSize: 38,
    lineHeight: 44,
    fontWeight: '700',
    marginBottom: 12,
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
    overflow: 'hidden',
  },
  cardEyebrow: {
    color: colors.accent,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.8,
    marginBottom: 16,
  },
  pickerWrap: {
    borderRadius: 24,
    overflow: 'hidden',
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.14)',
    marginBottom: 20,
    paddingVertical: 6,
  },
  noteWrap: {
    alignItems: 'center',
    paddingTop: 4,
    marginBottom: 16,
  },
  noteLine: {
    width: 44,
    height: 1,
    backgroundColor: 'rgba(216,184,107,0.35)',
    marginBottom: 12,
  },
  noteText: {
    color: 'rgba(255,255,255,0.6)',
    fontSize: 13,
    lineHeight: 18,
    textAlign: 'center',
  },
  buttonOuter: {
    marginTop: 16,
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