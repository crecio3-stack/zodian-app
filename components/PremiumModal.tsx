import { LinearGradient } from 'expo-linear-gradient';
import React, { useEffect } from 'react';
import { Modal, StyleSheet, Text, View } from 'react-native';
import Animated, { FadeIn, FadeInDown } from 'react-native-reanimated';
import { EVENTS, trackAppEvent } from '../lib/analytics/analytics';
import { colors, radius, spacing } from '../styles/theme';
import { GlassCard } from './GlassCard';
import { PremiumButton } from './PremiumButton';

type Props = {
  visible: boolean;
  onClose: () => void;
  onUpgrade: () => void;
  source?: string;
};

const benefits = [
  'Deeper compatibility insights',
  'Premium daily tarot-style guidance',
  'Advanced love and energy readings',
];

export function PremiumModal({ visible, onClose, onUpgrade, source = 'premium_modal' }: Props) {
  useEffect(() => {
    if (!visible) return;
    trackAppEvent(EVENTS.PREMIUM_PROMPT_VIEWED, { source, title: 'premium_modal' }).catch(() => {});
  }, [source, visible]);

  return (
    <Modal visible={visible} transparent animationType="fade">
      <Animated.View entering={FadeIn.duration(220)} style={styles.overlay}>
        <Animated.View entering={FadeInDown.duration(320)} style={styles.sheetWrap}>
          <GlassCard style={styles.sheet}>
            <LinearGradient
              colors={['rgba(201,168,97,0.16)', 'rgba(255,255,255,0.02)']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.hero}
            >
              <View style={styles.badge}>
                <Text style={styles.badgeText}>✦ Zodian Premium</Text>
              </View>

              <Text style={styles.title}>Unlock your full reading</Text>
              <Text style={styles.subtitle}>
                Access deeper compatibility, richer daily guidance, and premium-only
                insights with a more refined Zodian experience.
              </Text>
            </LinearGradient>

            <View style={styles.benefitsWrap}>
              {benefits.map((item) => (
                <View key={item} style={styles.benefitRow}>
                  <Text style={styles.bullet}>✦</Text>
                  <Text style={styles.benefitText}>{item}</Text>
                </View>
              ))}
            </View>

            <View style={styles.priceBox}>
              <Text style={styles.priceLabel}>Premium access</Text>
              <Text style={styles.priceTitle}>Unlock instantly</Text>
              <Text style={styles.priceSub}>
                Keep this local/demo for now until you wire in real billing.
              </Text>
            </View>

            <PremiumButton
              title="Unlock Premium"
              onPress={() => {
                trackAppEvent(EVENTS.PREMIUM_PROMPT_ACTION, { source, title: 'premium_modal', action: 'upgrade' }).catch(() => {});
                onUpgrade();
              }}
              style={styles.primaryBtn}
            />
            <PremiumButton
              title="Maybe later"
              onPress={() => {
                trackAppEvent(EVENTS.PREMIUM_PROMPT_ACTION, { source, title: 'premium_modal', action: 'close' }).catch(() => {});
                onClose();
              }}
              variant="secondary"
            />
          </GlassCard>
        </Animated.View>
      </Animated.View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: colors.overlay,
    justifyContent: 'flex-end',
    padding: spacing.md,
  },
  sheetWrap: {
    width: '100%',
  },
  sheet: {
    borderRadius: radius.xl,
  },
  hero: {
    margin: -18,
    marginBottom: 18,
    padding: 20,
    borderTopLeftRadius: radius.xl,
    borderTopRightRadius: radius.xl,
  },
  badge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 999,
    backgroundColor: 'rgba(201,168,97,0.10)',
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: 14,
  },
  badgeText: {
    color: colors.accentSoft,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 0.4,
  },
  title: {
    color: colors.text,
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '800',
  },
  subtitle: {
    marginTop: 10,
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 22,
  },
  benefitsWrap: {
    gap: 12,
    marginBottom: 18,
  },
  benefitRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  bullet: {
    color: colors.accent,
    fontSize: 16,
  },
  benefitText: {
    flex: 1,
    color: colors.text,
    fontSize: 15,
    lineHeight: 20,
  },
  priceBox: {
    padding: 16,
    borderRadius: radius.md,
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: 18,
  },
  priceLabel: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '700',
    marginBottom: 6,
    letterSpacing: 0.4,
  },
  priceTitle: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '800',
    marginBottom: 4,
  },
  priceSub: {
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 20,
  },
  primaryBtn: {
    marginBottom: 12,
  },
});