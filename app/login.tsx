import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { ActivityIndicator, Alert, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuth } from '../hooks/useAuth';
import { colors } from '../styles/theme';

export default function LoginScreen() {
  const { isConfigured, isLoading, requestEmailOtp, verifyEmailOtp } = useAuth();
  const [email, setEmail] = useState('');
  const [otpCode, setOtpCode] = useState('');
  const [otpRequestedFor, setOtpRequestedFor] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const trimmedEmail = email.trim().toLowerCase();
  const canRequestOtp = trimmedEmail.includes('@') && isConfigured;
  const canVerifyOtp = Boolean(otpRequestedFor && otpCode.trim().length >= 6 && isConfigured);

  const handleRequestOtp = async () => {
    if (!canRequestOtp) {
      return;
    }

    try {
      setSubmitting(true);
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      await requestEmailOtp(trimmedEmail);
      setOtpRequestedFor(trimmedEmail);
      Alert.alert('Check your email', 'We sent a one-time code. Enter it below to finish signing in.');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Could not send one-time code.';
      Alert.alert('OTP send failed', message);
    } finally {
      setSubmitting(false);
    }
  };

  const handleVerifyOtp = async () => {
    if (!canVerifyOtp || !otpRequestedFor) {
      return;
    }

    try {
      setSubmitting(true);
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      await verifyEmailOtp(otpRequestedFor, otpCode.trim());
      Alert.alert('Signed in', 'Your account is active on this device now.', [
        { text: 'OK', onPress: () => router.back() },
      ]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Code verification failed.';
      Alert.alert('Invalid code', message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <LinearGradient colors={[colors.background, '#09090F', colors.background]} style={StyleSheet.absoluteFill} />
      <View style={styles.container}>
        <Pressable style={styles.backButton} onPress={() => router.back()}>
          <Text style={styles.backButtonText}>Back</Text>
        </Pressable>

        <View style={styles.card}>
          <Text style={styles.eyebrow}>Cloud Save</Text>
          <Text style={styles.title}>Sign in with a one-time code</Text>
          <Text style={styles.copy}>Use an account to back up your Zodian profile, ritual history, rewards, and saved connections.</Text>

          {!isConfigured ? (
            <View style={styles.noticeBox}>
              <Text style={styles.noticeText}>Supabase is not configured yet. Set EXPO_PUBLIC_SUPABASE_URL and EXPO_PUBLIC_SUPABASE_ANON_KEY first.</Text>
            </View>
          ) : null}

          <Text style={styles.label}>Email</Text>
          <TextInput
            autoCapitalize="none"
            autoComplete="email"
            keyboardType="email-address"
            placeholder="you@example.com"
            placeholderTextColor={colors.textMuted}
            style={styles.input}
            value={email}
            onChangeText={setEmail}
          />

          <Text style={styles.label}>One-time code</Text>
          <TextInput
            autoCapitalize="none"
            autoComplete="one-time-code"
            keyboardType="number-pad"
            placeholder="6-digit code"
            placeholderTextColor={colors.textMuted}
            style={styles.input}
            value={otpCode}
            onChangeText={setOtpCode}
          />

          <Pressable
            disabled={!canRequestOtp || submitting || isLoading}
            onPress={handleRequestOtp}
            style={({ pressed }) => [
              styles.primaryButton,
              (!canRequestOtp || submitting || isLoading) && styles.buttonDisabled,
              pressed && { opacity: 0.92 },
            ]}
          >
            {submitting || isLoading ? (
              <ActivityIndicator color="#111111" size="small" />
            ) : (
              <Text style={styles.primaryButtonText}>Send One-Time Code</Text>
            )}
          </Pressable>

          <Pressable
            onPress={handleVerifyOtp}
            style={styles.secondaryButton}
            disabled={!canVerifyOtp || submitting || isLoading}
          >
            <Text style={[styles.secondaryButtonText, (!canVerifyOtp || submitting || isLoading) && styles.secondaryButtonTextDisabled]}>
              Verify Code and Sign In
            </Text>
          </Pressable>

          {otpRequestedFor ? (
            <Text style={styles.otpHintText}>Code sent to {otpRequestedFor}.</Text>
          ) : null}
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 12,
  },
  backButton: {
    alignSelf: 'flex-start',
    paddingVertical: 8,
    paddingHorizontal: 4,
    marginBottom: 12,
  },
  backButtonText: {
    color: colors.textSoft,
    fontSize: 15,
    fontWeight: '600',
  },
  card: {
    borderRadius: 24,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 20,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '800',
    letterSpacing: 1.1,
    textTransform: 'uppercase',
    marginBottom: 10,
  },
  title: {
    color: colors.text,
    fontSize: 28,
    lineHeight: 32,
    fontWeight: '800',
    marginBottom: 10,
  },
  copy: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 22,
    marginBottom: 18,
  },
  label: {
    color: colors.textMuted,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 0.8,
    textTransform: 'uppercase',
    marginBottom: 6,
  },
  input: {
    borderRadius: 14,
    borderWidth: 1,
    borderColor: 'rgba(214,181,107,0.16)',
    backgroundColor: 'rgba(255,255,255,0.02)',
    color: colors.text,
    fontSize: 15,
    paddingHorizontal: 12,
    paddingVertical: 12,
    marginBottom: 14,
  },
  primaryButton: {
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    backgroundColor: colors.accent,
    marginTop: 6,
  },
  primaryButtonText: {
    color: '#111111',
    fontSize: 16,
    fontWeight: '800',
  },
  secondaryButton: {
    marginTop: 10,
    borderRadius: 999,
    paddingVertical: 12,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.03)',
  },
  secondaryButtonText: {
    color: colors.text,
    fontSize: 15,
    fontWeight: '700',
  },
  secondaryButtonTextDisabled: {
    opacity: 0.45,
  },
  otpHintText: {
    color: colors.textMuted,
    fontSize: 12,
    marginTop: 12,
    textAlign: 'center',
  },
  buttonDisabled: {
    opacity: 0.45,
  },
  noticeBox: {
    borderRadius: 14,
    borderWidth: 1,
    borderColor: 'rgba(255,120,120,0.25)',
    backgroundColor: 'rgba(255,120,120,0.08)',
    padding: 12,
    marginBottom: 16,
  },
  noticeText: {
    color: '#FFCCCC',
    fontSize: 13,
    lineHeight: 19,
  },
});