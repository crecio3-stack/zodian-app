import { router } from 'expo-router';
import React, { useEffect, useRef } from 'react';
import { Animated, FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GlassCard } from '../components/GlassCard';
import { zodiacProfiles } from '../data/zodiacProfiles';
import { useSavedProfiles } from '../hooks/useSavedProfiles';
import { colors, spacing } from '../styles/theme';
import { type } from '../styles/tokens';
import { ZodiacProfile } from '../types/zodiac';

// Saved screen with subtle entrance animations and refined typography
export default function SavedScreen() {
  const { saved, reset } = useSavedProfiles();

  // Map saved ids back to canonical zodiacProfiles dataset
  const items = saved
    .map((id) => zodiacProfiles.find((d) => d.id === id))
    .filter(Boolean) as ZodiacProfile[];

  const headerAnim = useRef(new Animated.Value(0)).current;
  const itemAnimsRef = useRef<Animated.Value[]>([]);

  // ensure we have an Animated.Value for each item (limit to first 12)
  useEffect(() => {
    itemAnimsRef.current = items.slice(0, 12).map((_, i) => itemAnimsRef.current[i] ?? new Animated.Value(0));

    // sequence: header then staggered items
    Animated.timing(headerAnim, { toValue: 1, duration: 520, useNativeDriver: true }).start();

    const itemAnims = itemAnimsRef.current.map((v) => Animated.timing(v, { toValue: 1, duration: 420, useNativeDriver: true }));
    Animated.stagger(80, itemAnims).start();
  }, [items, headerAnim]);

  const renderItem = ({ item, index }: { item: ZodiacProfile; index: number }) => {
    const anim = itemAnimsRef.current[index] ?? new Animated.Value(1);
    const animatedStyle = {
      opacity: anim,
      transform: [
        {
          translateY: anim.interpolate({ inputRange: [0, 1], outputRange: [10, 0] }),
        },
      ],
    } as any;

    return (
      <Animated.View style={[styles.cardWrapper, animatedStyle]}>
        <Pressable onPress={() => router.push(`/details?sign=${encodeURIComponent(item.sign)}&headline=${encodeURIComponent(item.archetype)}&body=${encodeURIComponent(item.tagline)}`)} accessibilityLabel={`Open details for ${item.sign}`}>
          <GlassCard style={styles.card}>
            <Text style={styles.sign}>{item.sign}</Text>
            <Text style={styles.archetype}>{item.archetype}</Text>
            <Text style={styles.tagline} numberOfLines={2} ellipsizeMode="tail">{item.tagline}</Text>
          </GlassCard>
        </Pressable>
      </Animated.View>
    );
  };

  return (
    <SafeAreaView style={styles.safe}>
      <Animated.View style={[styles.header, { opacity: headerAnim, transform: [{ translateY: headerAnim.interpolate({ inputRange: [0, 1], outputRange: [8, 0] }) }] }]}
      >
        <Text style={styles.title}>Saved Energies</Text>
        <Pressable onPress={() => reset()} style={styles.clearBtn} accessibilityLabel="Clear saved list">
          <Text style={styles.clearText}>Clear</Text>
        </Pressable>
      </Animated.View>

      <FlatList
        data={items}
        keyExtractor={(i) => i.id}
        contentContainerStyle={styles.list}
        renderItem={renderItem}
        ListEmptyComponent={(
          <View style={styles.empty}>
            <Text style={styles.emptyTitle}>No saved energies yet</Text>
            <Text style={styles.emptyBody}>Swipe cards in Match to build your collection.</Text>
          </View>
        )}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.background },
  header: { paddingHorizontal: spacing.lg, paddingTop: spacing.md, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  title: { color: colors.accentBright, ...type.title, fontWeight: '800' },
  clearBtn: { padding: 8 },
  clearText: { color: colors.accentSoft, ...type.label },
  list: { padding: spacing.lg, gap: 12 },
  cardWrapper: { marginBottom: 12 },
  card: { padding: 16 },
  sign: { color: colors.text, ...type.title2, fontWeight: '800' },
  archetype: { color: colors.textMuted, marginTop: 6, ...type.label },
  tagline: { color: colors.textSoft, marginTop: 8, ...type.body },
  empty: { padding: 28, alignItems: 'center' },
  emptyTitle: { color: colors.text, ...type.title2, fontWeight: '700' },
  emptyBody: { color: colors.textMuted, marginTop: 8, ...type.body },
});
