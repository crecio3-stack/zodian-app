import React, { useMemo } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors, radius, spacing } from '../styles/theme';

interface AstroChatEmptyProps {
  westernSign: string;
  chineseSign: string;
  name?: string;
}

export const AstroChatEmpty: React.FC<AstroChatEmptyProps> = ({ westernSign, chineseSign, name }) => {
  const styles = useMemo(() => createStyles(), []);

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={styles.badges}>
          <View style={styles.badge}>
            <Text style={styles.badgeText}>{westernSign}</Text>
          </View>
          <View style={styles.badgeDivider}>
            <Text style={styles.dividerText}>×</Text>
          </View>
          <View style={styles.badge}>
            <Text style={styles.badgeText}>{chineseSign}</Text>
          </View>
        </View>
        <Text style={styles.title}>{name ? `Welcome, ${name}` : 'Meet your astrologer'}</Text>
        <Text style={styles.subtitle}>
          A space to explore your signs, patterns, and desires with warmth and insight.
        </Text>
      </View>

      <View style={styles.features}>
        <View style={styles.feature}>
          <Text style={styles.featureEmoji}>✨</Text>
          <Text style={styles.featureText}>Understand your sign combinations</Text>
        </View>
        <View style={styles.feature}>
          <Text style={styles.featureEmoji}>💘</Text>
          <Text style={styles.featureText}>Explore love and compatibility</Text>
        </View>
        <View style={styles.feature}>
          <Text style={styles.featureEmoji}>🌱</Text>
          <Text style={styles.featureText}>Grow through self-reflection</Text>
        </View>
      </View>
    </View>
  );
};

function createStyles() {
  return StyleSheet.create({
    container: {
      flex: 1,
      paddingHorizontal: spacing.lg,
      paddingVertical: spacing.xl,
      justifyContent: 'center',
    },
    header: {
      alignItems: 'center',
      marginBottom: spacing.xl,
    },
    badges: {
      flexDirection: 'row',
      alignItems: 'center',
      marginBottom: spacing.lg,
      gap: spacing.md,
    },
    badge: {
      backgroundColor: 'rgba(216,184,107,0.12)',
      borderWidth: 1,
      borderColor: colors.accent,
      borderRadius: radius.pill,
      paddingHorizontal: spacing.lg,
      paddingVertical: spacing.sm,
    },
    badgeText: {
      color: colors.accent,
      fontWeight: '700',
      fontSize: 13,
      letterSpacing: 0.5,
      textTransform: 'uppercase',
    },
    badgeDivider: {
      width: 24,
      alignItems: 'center',
    },
    dividerText: {
      color: colors.textMuted,
      fontSize: 16,
    },
    title: {
      fontSize: 28,
      fontWeight: '800',
      color: colors.text,
      marginBottom: spacing.md,
      textAlign: 'center',
    },
    subtitle: {
      fontSize: 15,
      lineHeight: 22,
      color: colors.textMuted,
      textAlign: 'center',
      maxWidth: '90%',
    },
    features: {
      gap: spacing.lg,
    },
    feature: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: spacing.md,
      paddingHorizontal: spacing.md,
    },
    featureEmoji: {
      fontSize: 20,
    },
    featureText: {
      flex: 1,
      fontSize: 14,
      color: colors.text,
      fontWeight: '500',
    },
  });
}
