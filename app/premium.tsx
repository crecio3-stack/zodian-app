import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React, { useState } from 'react';
import {
    Pressable,
    ScrollView,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { usePremium } from '../hooks/usePremium';
import { colors } from '../styles/theme';

const perks = [
  {
    title: 'Deeper daily readings',
    body: 'Unlock a richer emotional layer beneath each day’s message.',
  },
  {
    title: 'Advanced compatibility',
    body: 'See attachment rhythm, chemistry style, and long-term potential.',
  },
  {
    title: 'Premium dating guidance',
    body: 'Get more personalized love insight tailored to your signs.',
  },
  {
    title: 'Stronger ritual experience',
    body: 'Turn Zodian into a daily habit with more meaningful guidance.',
  },
];

export default function PremiumScreen() {
  const { isPremium, enablePremium, disablePremium } = usePremium();
  const [plan, setPlan] = useState<'yearly' | 'monthly'>('yearly');

  const handleClose = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.back();
  };

  const handleTogglePremium = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    if (isPremium) {
      await disablePremium();
      return;
    }
    await enablePremium();
  };

  const handlePurchase = async () => {
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    await enablePremium();
    router.back();
  };

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <LinearGradient
        colors={['#020202', '#090909', '#060608']}
        style={StyleSheet.absoluteFill}
      />

      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.topRow}>
          <Pressable onPress={handleClose} style={styles.closeButton}>
            <Ionicons name="close" size={22} color={colors.text} />
          </Pressable>
        </View>

        <View style={styles.heroShell}>
          <LinearGradient
            colors={['rgba(214,181,107,0.16)', 'rgba(255,255,255,0.04)']}
            style={styles.heroGlow}
          />
          <Text style={styles.heroBadge}>PREMIUM</Text>
          <Text style={styles.heroTitle}>Elevate your cosmic edge.</Text>
          <Text style={styles.heroCopy}>
            Unlock deeper ritual guidance, more refined compatibility readings, and a
            premium identity that feels perfectly curated.
          </Text>
        </View>

        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Premium status</Text>
          <View style={[styles.statusPill, isPremium ? styles.statusOn : styles.statusOff]}>
            <Text style={[styles.statusPillText, isPremium ? styles.statusOnText : styles.statusOffText]}>
              {isPremium ? 'Active' : 'Inactive'}
            </Text>
          </View>
        </View>

        <View style={styles.planToggle}>
          <Pressable
            onPress={() => setPlan('yearly')}
            style={[styles.planButton, plan === 'yearly' && styles.planButtonActive]}
          >
            <Text style={[styles.planButtonText, plan === 'yearly' && styles.planButtonTextActive]}>
              Yearly
            </Text>
          </Pressable>
          <Pressable
            onPress={() => setPlan('monthly')}
            style={[styles.planButton, plan === 'monthly' && styles.planButtonActive]}
          >
            <Text style={[styles.planButtonText, plan === 'monthly' && styles.planButtonTextActive]}>
              Monthly
            </Text>
          </Pressable>
        </View>

        <View style={styles.priceCard}>
          <View style={styles.planRow}>
            <Text style={styles.priceLabel}>{plan === 'yearly' ? 'Yearly access' : 'Monthly access'}</Text>
            <Text style={styles.priceTag}>{plan === 'yearly' ? '$29.99 / year' : '$4.99 / month'}</Text>
          </View>
          <Text style={styles.priceCaption}>
            {plan === 'yearly'
              ? 'Best value for a ritual rhythm that sticks.'
              : 'Flexible access, cancel anytime.'}
          </Text>
        </View>

        <View style={styles.featuresWrap}>
          {perks.map((perk) => (
            <View key={perk.title} style={styles.featureCard}>
              <View style={styles.featureMark} />
              <View style={styles.featureText}>
                <Text style={styles.featureTitle}>{perk.title}</Text>
                <Text style={styles.featureBody}>{perk.body}</Text>
              </View>
            </View>
          ))}
        </View>

        <Pressable style={styles.primaryButton} onPress={handlePurchase}>
          <LinearGradient
            colors={['#D6B56F', '#B48F42']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={styles.primaryButtonGradient}
          >
            <Text style={styles.primaryButtonText}>{isPremium ? 'Refresh premium' : 'Unlock premium'}</Text>
          </LinearGradient>
        </Pressable>

        <Pressable style={styles.secondaryButton} onPress={handleTogglePremium}>
          <Text style={styles.secondaryButtonText}>
            {isPremium ? 'Disable premium' : 'Enable premium toggle'}
          </Text>
        </Pressable>

        <Text style={styles.footerText}>
          Premium mode here is for development and early testing only. Live subscriptions
          can be added later.
        </Text>
      </ScrollView>
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
    backgroundColor: 'transparent',
  },
  content: {
    paddingHorizontal: 24,
    paddingTop: 20,
    paddingBottom: 40,
  },
  topRow: {
    alignItems: 'flex-end',
    marginBottom: 8,
  },
  closeButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255,255,255,0.08)',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
  heroShell: {
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderRadius: 32,
    padding: 24,
    marginBottom: 22,
    borderWidth: 1,
    borderColor: colors.border,
    overflow: 'hidden',
  },
  heroGlow: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.2,
  },
  heroBadge: {
    color: colors.accent,
    letterSpacing: 2,
    fontSize: 11,
    textTransform: 'uppercase',
    marginBottom: 14,
    fontWeight: '700',
  },
  heroTitle: {
    color: colors.text,
    fontSize: 32,
    lineHeight: 40,
    fontWeight: '800',
    marginBottom: 12,
  },
  heroCopy: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 24,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 22,
  },
  statusLabel: {
    color: colors.textSoft,
    fontSize: 13,
    letterSpacing: 1.5,
    textTransform: 'uppercase',
  },
  statusPill: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 999,
    borderWidth: 1,
  },
  statusOn: {
    backgroundColor: 'rgba(214,181,107,0.16)',
    borderColor: 'rgba(214,181,107,0.22)',
  },
  statusOff: {
    backgroundColor: colors.cardStrong,
    borderColor: colors.border,
  },
  statusPillText: {
    fontSize: 12,
    fontWeight: '700',
  },
  statusOnText: {
    color: colors.accent,
  },
  statusOffText: {
    color: colors.textSoft,
  },
  planToggle: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 18,
  },
  planButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.card,
    alignItems: 'center',
  },
  planButtonActive: {
    backgroundColor: 'rgba(214,181,107,0.14)',
    borderColor: 'rgba(214,181,107,0.24)',
  },
  planButtonText: {
    color: colors.textSoft,
    fontSize: 14,
    fontWeight: '700',
  },
  planButtonTextActive: {
    color: colors.accent,
  },
  priceCard: {
    padding: 22,
    borderRadius: 28,
    backgroundColor: colors.cardStrong,
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: 20,
  },
  planRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginBottom: 12,
  },
  priceLabel: {
    color: colors.textSoft,
    fontSize: 13,
    letterSpacing: 1.5,
    textTransform: 'uppercase',
  },
  priceTag: {
    color: colors.accent,
    fontSize: 24,
    fontWeight: '800',
  },
  priceCaption: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 24,
  },
  featuresWrap: {
    gap: 14,
    marginBottom: 24,
  },
  featureCard: {
    flexDirection: 'row',
    gap: 14,
    alignItems: 'flex-start',
    padding: 18,
    borderRadius: 24,
    backgroundColor: colors.card,
    borderWidth: 1,
    borderColor: colors.border,
  },
  featureMark: {
    width: 10,
    height: 10,
    borderRadius: 999,
    marginTop: 8,
    backgroundColor: colors.accent,
  },
  featureText: {
    flex: 1,
  },
  featureTitle: {
    color: colors.text,
    fontSize: 15,
    fontWeight: '700',
    marginBottom: 6,
  },
  featureBody: {
    color: colors.textSoft,
    fontSize: 14,
    lineHeight: 22,
  },
  primaryButton: {
    borderRadius: 999,
    overflow: 'hidden',
    marginBottom: 14,
  },
  primaryButtonGradient: {
    paddingVertical: 16,
    alignItems: 'center',
    borderRadius: 999,
  },
  primaryButtonText: {
    color: colors.cardStrong,
    fontSize: 17,
    fontWeight: '800',
  },
  secondaryButton: {
    borderRadius: 999,
    paddingVertical: 16,
    alignItems: 'center',
    backgroundColor: colors.card,
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: 20,
  },
  secondaryButtonText: {
    color: colors.text,
    fontSize: 16,
    fontWeight: '700',
  },
  footerText: {
    color: colors.textSoft,
    fontSize: 13,
    textAlign: 'center',
    lineHeight: 20,
  },
});
