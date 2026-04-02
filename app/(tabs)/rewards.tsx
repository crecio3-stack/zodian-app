// filepath: /Users/christianrecio/zodian/app/(tabs)/rewards.tsx
import { useRouter } from 'expo-router';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import RewardItem from '../../components/RewardItem';
import { useRewards } from '../../hooks/useRewards';
import { colors } from '../../styles/theme';

export default function RewardsScreen() {
  const router = useRouter();
  const { loading, history, clear } = useRewards();

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>Rewards</Text>
        <Text style={styles.subtitle}>Your milestone history and badges</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={{ marginBottom: 12 }}>
          <Pressable onPress={() => router.back()} style={({ pressed }) => [{ padding: 10, opacity: pressed ? 0.85 : 1 }] }>
            <Text style={{ color: colors.accent, fontWeight: '700' }}>Back</Text>
          </Pressable>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Milestones</Text>

          {loading ? (
            <Text style={styles.hint}>Loading…</Text>
          ) : history.length === 0 ? (
            <View style={styles.empty}>
              <Text style={styles.hint}>No milestones earned yet. Complete daily rituals to start a streak.</Text>
            </View>
          ) : (
            history.map((r) => (
              <RewardItem key={r.id} streak={r.streak} label={r.label} dateKey={r.dateKey} />
            ))
          )}
        </View>

        <View style={styles.controls}>
          <Pressable onPress={async () => { await clear(); }} style={({ pressed }) => [{ padding: 12, borderRadius: 12, backgroundColor: 'rgba(255,255,255,0.03)', opacity: pressed ? 0.9 : 1 }] }>
            <Text style={{ color: colors.accent, fontWeight: '700' }}>Clear history</Text>
          </Pressable>
        </View>

        <View style={{ height: 80 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 8,
  },
  title: {
    fontSize: 28,
    color: colors.text,
    fontWeight: '800',
  },
  subtitle: {
    color: colors.textMuted,
    marginTop: 6,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 6,
  },
  section: {
    marginTop: 12,
  },
  sectionTitle: {
    color: colors.accent,
    marginBottom: 10,
    fontWeight: '700',
  },
  hint: {
    color: colors.textMuted,
  },
  empty: {
    paddingVertical: 18,
  },
  controls: {
    marginTop: 18,
  },
});
