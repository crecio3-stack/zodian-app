import * as Haptics from 'expo-haptics';
import React, { useEffect, useRef } from 'react';
import { Animated, Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, radius, spacing } from '../styles/theme';
import { shadows } from '../styles/tokens';
import { ZodiacProfile } from '../types/zodiac';

type Props = {
  profile: ZodiacProfile;
  index: number;
  onPress: (id: string) => void;
  expanded?: boolean;
};

export default function ProfileCard({ profile, index, onPress, expanded = false }: Props) {
  const entrance = useRef(new Animated.Value(0)).current;
  const pressScale = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    Animated.timing(entrance, {
      toValue: 1,
      duration: 420,
      delay: index * 60,
      useNativeDriver: true,
    }).start();
  }, [entrance, index]);

  useEffect(() => {
    // subtle pop when expanded toggles
    Animated.timing(pressScale, {
      toValue: expanded ? 1.02 : 1,
      duration: 260,
      useNativeDriver: true,
    }).start();
  }, [expanded, pressScale]);

  const containerStyle = {
    transform: [
      { translateY: entrance.interpolate({ inputRange: [0, 1], outputRange: [8, 0] }) },
      { scale: pressScale },
    ],
    opacity: entrance,
  } as const;

  return (
    <Animated.View style={[styles.wrapper, containerStyle]}>
      <Pressable
        onPress={async () => {
          try { await Haptics.selectionAsync(); } catch {}
          onPress(profile.id);
        }}
        onPressIn={() => Animated.spring(pressScale, { toValue: 0.985, stiffness: 300, damping: 18, useNativeDriver: true }).start()}
        onPressOut={() => Animated.spring(pressScale, { toValue: expanded ? 1.02 : 1, stiffness: 300, damping: 18, useNativeDriver: true }).start()}
        style={({ pressed }) => [styles.inner, pressed && { opacity: 0.96 }]}
      >
        <View style={styles.headerRow}>
          <Text style={styles.sign}>{profile.sign}</Text>
          <View style={styles.metaRight}>
            <Text style={styles.archetype}>{profile.archetype}</Text>
            <Text style={styles.sub}>{profile.subtitle}</Text>
          </View>
        </View>

        {expanded ? (
          <View style={styles.expanded}>
            <Text style={styles.expandedText}>{profile.description}</Text>
            <View style={styles.expandedMetaRow}>
              <Text style={styles.metaLabel}>Attraction</Text>
              <Text style={styles.metaValue}>{profile.attraction ?? '—'}</Text>
            </View>
          </View>
        ) : null}
      </Pressable>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    marginBottom: spacing.md,
  },
  inner: {
    borderRadius: radius.lg,
    padding: spacing.md,
    backgroundColor: colors.card,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    ...shadows.soft,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  sign: {
    color: colors.accentBright,
    fontSize: 20,
    fontWeight: '800',
    marginRight: spacing.md,
    minWidth: 56,
  },
  metaRight: {
    flex: 1,
  },
  archetype: {
    color: colors.text,
    fontSize: 16,
    fontWeight: '700',
  },
  sub: {
    color: colors.textMuted,
    fontSize: 13,
    marginTop: 6,
  },
  expanded: {
    marginTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255,255,255,0.02)',
    paddingTop: spacing.sm,
  },
  expandedText: {
    color: colors.textSoft,
    fontSize: 14,
    lineHeight: 20,
  },
  expandedMetaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: spacing.sm,
  },
  metaLabel: {
    color: colors.textMuted,
    fontSize: 12,
  },
  metaValue: {
    color: colors.text,
    fontWeight: '700',
  },
});
