import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import SwipeDeck from '../../components/explore/SwipeDeck';
import { mapPersonToProfile, people } from '../../data/people';
import { usePremium } from '../../hooks/usePremium';
import { useRewards } from '../../hooks/useRewards';
import { showSwipeLimitPrompt } from '../../lib/premium/accessPrompt';
import { openPremiumScreen } from '../../lib/premium/navigation';
import { premiumTheme } from '../../styles/premiumTheme';
import { spacing, typography } from '../../styles/tokens';

export default function MatchScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { isPremium } = usePremium();
  const { swipeAllowance, consumeSwipe } = useRewards();

  const socialProfiles = React.useMemo(() => people.map(mapPersonToProfile), []);

  return (
    <SafeAreaView style={styles.safeArea}>
      <LinearGradient colors={['#050505', '#090909', '#040404']} style={StyleSheet.absoluteFill} />

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={[
          styles.scrollContent,
          {
            paddingBottom: Math.max(insets.bottom + 132, 148),
          },
        ]}
      >
        <View style={styles.header}>
          <Text style={styles.eyebrow}>MATCH</Text>
          <Text style={styles.title}>Cosmic connections</Text>
          <Text style={styles.subtitle}>
            Swipe to discover people aligned with your astrological identity.
          </Text>
        </View>

        <View style={styles.deckWrap}>
          <SwipeDeck
            data={socialProfiles}
            isPremium={isPremium}
            freeSwipeLimit={3}
            swipesLeft={swipeAllowance.totalLeft}
            onConsumeSwipe={consumeSwipe}
            showBackdropBlur
            onUnlockMore={async () => {
              await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
              showSwipeLimitPrompt({
                source: 'match_unlock_more',
                onUseStarDust: () => router.push('/(tabs)/rewards'),
                onPremium: () => openPremiumScreen(router, 'match_unlock_more'),
              });
            }}
          />
        </View>

        <View style={styles.topTiles}>
          <Pressable
            style={styles.tile}
            onPress={() => router.push('/saved')}
            accessibilityRole="button"
            accessibilityLabel="Open saved energies"
          >
            <LinearGradient colors={['rgba(255,255,255,0.02)', 'rgba(214,181,107,0.03)']} style={styles.tileBg}>
              <Text style={styles.tileTitle}>Saved</Text>
              <Text style={styles.tileSubtitle}>Your liked profiles</Text>
            </LinearGradient>
          </Pressable>

          <Pressable
            style={styles.tile}
            onPress={() => router.push('/(tabs)/connections')}
            accessibilityRole="button"
            accessibilityLabel="Open connections"
          >
            <LinearGradient colors={['rgba(255,255,255,0.02)', 'rgba(125,141,107,0.03)']} style={styles.tileBg}>
              <Text style={styles.tileTitle}>Connections</Text>
              <Text style={styles.tileSubtitle}>Your active matches</Text>
            </LinearGradient>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: premiumTheme.colors.background,
  },
  header: {
    paddingHorizontal: spacing.screenPadding,
    paddingTop: spacing.sm,
    paddingBottom: spacing.md,
    gap: spacing.xs,
  },
  eyebrow: {
    ...typography.micro,
    color: premiumTheme.colors.accentMuted,
    letterSpacing: 1.4,
  },
  title: {
    ...typography.title1,
    color: premiumTheme.colors.text,
    letterSpacing: -0.2,
  },
  subtitle: {
    ...typography.body,
    color: premiumTheme.colors.textMuted,
    maxWidth: '92%',
  },
  topTiles: {
    flexDirection: 'row',
    marginTop: spacing.lg,
    marginHorizontal: spacing.screenPadding,
    gap: 12,
  },
  tile: {
    flex: 1,
    borderRadius: 16,
    overflow: 'hidden',
  },
  tileBg: {
    padding: 12,
    borderRadius: 12,
  },
  tileTitle: {
    color: premiumTheme.colors.text,
    fontWeight: '700',
    marginBottom: 4,
  },
  tileSubtitle: {
    color: premiumTheme.colors.textMuted,
    fontSize: 12,
  },
  deckWrap: {
    paddingHorizontal: spacing.screenPadding,
    marginTop: spacing.md,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingTop: 0,
  },
});