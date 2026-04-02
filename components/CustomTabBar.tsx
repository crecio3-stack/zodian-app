import { Ionicons } from '@expo/vector-icons';
import { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import { BlurView } from 'expo-blur';
import * as Haptics from 'expo-haptics';
import React, { useEffect, useRef } from 'react';
import {
    Animated,
    Platform,
    Pressable,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../styles/theme';

const { colors, shadows, spacing } = theme;

type TabConfig = {
  label: string;
  icon: keyof typeof Ionicons.glyphMap;
};

const TAB_CONFIG: Record<string, TabConfig> = {
  index: { label: 'Home', icon: 'sparkles' },
  match: { label: 'Match', icon: 'planet' },
  connections: { label: 'Connections', icon: 'people' },
  profile: { label: 'Profile', icon: 'person' },
};

export function CustomTabBar({ state, descriptors, navigation }: BottomTabBarProps) {
  const insets = useSafeAreaInsets();

  return (
    <View
      pointerEvents="box-none"
      style={[styles.outerWrap, { paddingBottom: Math.max(insets.bottom, spacing.md) }]}
    >
      <View style={styles.shadowLayer} />

      <BlurView intensity={36} tint="dark" style={styles.bar}>
        {state.routes
          .filter((r) => ['index', 'match', 'connections', 'profile'].includes(r.name))
          .map((route) => {
            // Use route key match against the navigator's active route.
            // Index comparison breaks when some tabs are hidden from the bar.
            const isFocused = state.routes[state.index]?.key === route.key;

            const config =
              TAB_CONFIG[route.name] ??
              (typeof descriptors[route.key]?.options?.title === 'string'
                ? { label: descriptors[route.key].options.title!, icon: 'ellipse' }
                : { label: route.name, icon: 'ellipse' });

            const onPress = async () => {
              const event = navigation.emit({ type: 'tabPress', target: route.key, canPreventDefault: true });
              if (!isFocused) await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              if (!isFocused && !event.defaultPrevented) {
                navigation.navigate(route.name as any, route.params as any);
              }
            };

            const onLongPress = () => navigation.emit({ type: 'tabLongPress', target: route.key });

            return (
              <TabBarButton
                key={route.key}
                label={config.label}
                icon={config.icon}
                active={isFocused}
                onPress={onPress}
                onLongPress={onLongPress}
              />
            );
          })}
      </BlurView>
    </View>
  );
}

function TabBarButton({ label, icon, active, onPress, onLongPress, badge }:{ label: string; icon: keyof typeof Ionicons.glyphMap; active: boolean; onPress: () => void; onLongPress: () => void; badge?: string; }) {
  const glow = useRef(new Animated.Value(active ? 1 : 0)).current;
  const lift = useRef(new Animated.Value(active ? 1 : 0)).current;
  const badgeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(glow, { toValue: active ? 1 : 0, duration: 180, useNativeDriver: true }),
      Animated.timing(lift, { toValue: active ? 1 : 0, duration: 220, useNativeDriver: true }),
    ]).start();
  }, [active, glow, lift]);

  useEffect(() => {
    // pulse badge when present
    if (badge) {
      const pulse = Animated.loop(
        Animated.sequence([
          Animated.timing(badgeAnim, { toValue: 1, duration: 600, useNativeDriver: true }),
          Animated.timing(badgeAnim, { toValue: 0, duration: 600, useNativeDriver: true }),
        ])
      );
      pulse.start();
      return () => pulse.stop();
    }
    // reset when no badge
    badgeAnim.setValue(0);
  }, [badge, badgeAnim]);

  const activeBgOpacity = glow.interpolate({ inputRange: [0, 1], outputRange: [0, 1] });
  const activeBgScale = glow.interpolate({ inputRange: [0, 1], outputRange: [0.96, 1.02] });
  const translateY = lift.interpolate({ inputRange: [0, 1], outputRange: [0, -4] });

  const badgeScale = badgeAnim.interpolate({ inputRange: [0, 1], outputRange: [1, 1.12] });
  const badgeOpacity = badgeAnim.interpolate({ inputRange: [0, 1], outputRange: [1, 0.85] });

  return (
    <Pressable onPress={onPress} onLongPress={onLongPress} style={styles.tabButton} android_ripple={{ color: 'rgba(214,181,107,0.08)', borderless: false }}>
      <Animated.View style={[styles.tabInner, { transform: [{ translateY }] }]}
      >
        <Animated.View pointerEvents="none" style={[styles.activeBg, { opacity: activeBgOpacity, transform: [{ scale: activeBgScale }] }]} />

        <View style={styles.iconWrap}>
          <Ionicons name={icon} size={22} color={active ? colors.accent : colors.textMuted} style={styles.icon} />
          {badge ? (
            <Animated.View style={[styles.badge, { transform: [{ scale: badgeScale }], opacity: badgeOpacity }]}>
              <Text style={styles.badgeText}>{badge}</Text>
            </Animated.View>
          ) : null}
        </View>

        <Text numberOfLines={1} adjustsFontSizeToFit minimumFontScale={0.8} style={[styles.label, active ? styles.labelActive : styles.labelInactive]}>
          {label}
        </Text>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  outerWrap: {
    position: 'absolute',
    left: 16,
    right: 16,
    bottom: 0,
    zIndex: 999,
  },
  shadowLayer: {
    position: 'absolute',
    top: 8,
    left: 8,
    right: 8,
    bottom: 8,
    borderRadius: 34,
    backgroundColor: 'rgba(0,0,0,0.46)',
    ...shadows.medium,
  },
  bar: {
    overflow: 'hidden',
    borderRadius: 34,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(8, 10, 14, 0.94)',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 8,
    paddingTop: 10,
    paddingBottom: Platform.OS === 'ios' ? 14 : 16,
  },
  tabButton: { flex: 1, marginHorizontal: 6 },
  tabInner: {
    minHeight: 64,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 6,
    paddingVertical: 6,
    overflow: 'hidden',
  },
  activeBg: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 22,
    backgroundColor: 'rgba(214,181,107,0.10)',
    borderWidth: 1,
    borderColor: 'rgba(214,181,107,0.18)',
  },
  icon: { marginBottom: 6 },
  iconWrap: { alignItems: 'center', justifyContent: 'center' },
  badge: { position: 'absolute', top: -6, right: -10, backgroundColor: colors.accent, paddingHorizontal: 6, paddingVertical: 2, borderRadius: 999, borderWidth: 1, borderColor: 'rgba(0,0,0,0.25)' },
  badgeText: { color: '#071019', fontSize: 11, fontWeight: '700' },
  label: { fontSize: 11, fontWeight: '600', textAlign: 'center' },
  labelActive: { color: colors.text },
  labelInactive: { color: colors.textMuted },
});