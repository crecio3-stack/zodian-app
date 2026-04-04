import { useRouter } from 'expo-router';
import React, { useEffect, useRef } from 'react';
import { Alert, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import RewardItem from '../../components/RewardItem';
import { useDailyState } from '../../hooks/useDailyState';
import { usePremium } from '../../hooks/usePremium';
import { useRewards } from '../../hooks/useRewards';
import { EVENTS, trackAppEvent } from '../../lib/analytics/analytics';
import { ADS } from '../../lib/config/constants';
import { openPremiumScreen } from '../../lib/premium/navigation';
import { STAR_DUST } from '../../lib/storage/rewardsService';
import { colors } from '../../styles/theme';

type RewardedHookResult = {
  isLoaded: boolean;
  isClosed: boolean;
  isEarnedReward?: boolean;
  load: () => void;
  show: () => void;
  error?: Error;
};

const googleAdsModule: {
  TestIds?: { REWARDED?: string };
  useRewardedAd?: (adUnitId: string | null) => RewardedHookResult;
} | null = (() => {
  try {
    // Use runtime require so the screen does not crash when native ads module is missing.
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    return require('react-native-google-mobile-ads');
  } catch {
    return null;
  }
})();

const fallbackUseRewardedAd = (_adUnitId: string | null): RewardedHookResult => ({
  isLoaded: false,
  isClosed: false,
  isEarnedReward: false,
  load: () => {},
  show: () => {},
  error: new Error('Rewarded ads unavailable in this binary.'),
});

const useRewardedAdSafe = googleAdsModule?.useRewardedAd ?? fallbackUseRewardedAd;
const testRewardedId =
  googleAdsModule?.TestIds?.REWARDED ?? 'ca-app-pub-3940256099942544/5224354917';

const REWARDED_AD_UNIT_ID = __DEV__
  ? testRewardedId
  : ADS.ADMOB_REWARDED_UNIT_ID;

export default function RewardsScreen() {
  const router = useRouter();
  const { summary } = useDailyState();
  const { isPremium } = usePremium();
  const {
    loading,
    history,
    wallet,
    perks,
    activities,
    swipeAllowance,
    hasGoDeeperPass,
    watchSponsorSpotlight,
    unlockGoDeeperPass,
    unlockExtraSwipes,
  } = useRewards();

  const currentStreak = summary?.streak?.current ?? 0;
  const sponsorWatchesUsed = wallet.adWatchDate === summary?.todayDate ? wallet.adWatchCountToday : 0;
  const sponsorWatchesLeft = Math.max(0, STAR_DUST.sponsorDailyLimit - sponsorWatchesUsed);

  // Rewarded ad — loads automatically, reloads after each close
  const { isLoaded: adLoaded, isClosed: adClosed, isEarnedReward, load: loadAd, show: showAd, error: adError } = useRewardedAdSafe(REWARDED_AD_UNIT_ID);
  const earnHandledRef = useRef(false);

  useEffect(() => { loadAd(); }, [loadAd]);

  useEffect(() => {
    if (adClosed) {
      earnHandledRef.current = false;
      loadAd();
    }
  }, [adClosed, loadAd]);

  useEffect(() => {
    if (!isEarnedReward || earnHandledRef.current) return;
    earnHandledRef.current = true;
    watchSponsorSpotlight().then((result) => {
      if (result.awarded) {
        Alert.alert(
          'Star Dust collected',
          `+${result.amount} ${STAR_DUST.currencyName} earned from sponsor spotlight.${sponsorWatchesLeft - 1 > 0 ? ` ${sponsorWatchesLeft - 1} more available today.` : ''}`,
        );
      }
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isEarnedReward]);

  const goDeeperExpiry = perks.goDeeperPassExpiresAt
    ? new Date(perks.goDeeperPassExpiresAt).toLocaleString(undefined, {
        month: 'short',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
      })
    : null;

  const starDustWays = [
    {
      key: 'daily-ritual',
      title: 'Complete your daily ritual',
      amount: STAR_DUST.dailyRitual,
      description: 'Your first completed ritual each day adds Star Dust automatically.',
      status: summary?.completed ? 'Collected today' : 'Available today',
    },
    {
      key: 'share-ritual',
      title: 'Share your reading',
      amount: STAR_DUST.shareRitual,
      description: 'Use the share action on the Daily tab to collect a once-per-day bonus.',
      status: wallet.lastSharedDate === summary?.todayDate ? 'Collected today' : 'Once per day',
    },
    {
      key: 'streak-bonus',
      title: 'Hit streak milestones',
      amount: STAR_DUST.milestoneBonus[7],
      description: '3, 7, 14, and 30-day streaks drop larger Star Dust bonuses on top of your normal daily earn.',
      status: 'Milestone bonus',
    },
  ];

  const handleSponsorWatch = async () => {
    await trackAppEvent(EVENTS.BUTTON_TAPPED, {
      button: 'rewards_watch_sponsor',
      watchesLeft: sponsorWatchesLeft,
      streak: currentStreak,
    });

    if (sponsorWatchesLeft <= 0) {
      Alert.alert('Daily limit reached', 'You already collected both sponsor bonuses for today.');
      return;
    }

    if (!googleAdsModule) {
      Alert.alert(
        'Rewarded ads unavailable',
        'This build does not include the native ads module yet. Rebuild your dev client to enable sponsor videos.',
      );
      return;
    }

    if (!REWARDED_AD_UNIT_ID) {
      Alert.alert(
        'Ad unit missing',
        'Set EXPO_PUBLIC_ADMOB_REWARDED_UNIT_ID for release builds before using sponsor rewards outside development.',
      );
      return;
    }

    if (!adLoaded) {
      Alert.alert(
        adError ? 'Ad unavailable' : 'Still loading',
        adError
          ? 'No sponsor video is available right now. Check back later.'
          : 'The sponsor video is still loading. Try again in a moment.',
      );
      return;
    }

    showAd();
  };

  const handleUnlockGoDeeper = async () => {
    await trackAppEvent(EVENTS.BUTTON_TAPPED, {
      button: 'rewards_unlock_go_deeper',
      balance: wallet.balance,
    });

    const result = await unlockGoDeeperPass();
    if (result.success) {
      Alert.alert('Go Deeper unlocked', `Your 24-hour pass is active now. ${result.amount} ${STAR_DUST.currencyName} spent.`);
      return;
    }

    if (result.reason === 'already_active') {
      Alert.alert('Pass already active', 'Your Go Deeper pass is already running.');
      return;
    }

    Alert.alert('Not enough Star Dust', `You need ${STAR_DUST.shop.goDeeperPass} ${STAR_DUST.currencyName} for this pass.`);
  };

  const handleUnlockExtraSwipes = async () => {
    await trackAppEvent(EVENTS.BUTTON_TAPPED, {
      button: 'rewards_unlock_extra_swipes',
      balance: wallet.balance,
      bonusLeft: swipeAllowance.bonusLeft,
    });

    const result = await unlockExtraSwipes();
    if (result.success) {
      Alert.alert('Extra swipes added', `${STAR_DUST.extraSwipePackSize} more swipes are live for today. ${result.amount} ${STAR_DUST.currencyName} spent.`);
      return;
    }

    Alert.alert('Not enough Star Dust', `You need ${STAR_DUST.shop.extraSwipesPack} ${STAR_DUST.currencyName} for this pack.`);
  };

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.subtitle}>Streak days build momentum. Star Dust is the spendable reward layer.</Text>
        <Text style={styles.subtitle}>Earn it from rituals, milestone streaks, sharing, and sponsor videos.</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.backRow}>
          <Pressable onPress={() => router.back()} style={({ pressed }) => [{ padding: 10, opacity: pressed ? 0.85 : 1 }] }>
            <Text style={styles.backText}>Back</Text>
          </Pressable>
        </View>

        <View style={styles.walletCard}>
          <View style={styles.walletRow}>
            <View style={styles.walletStat}>
              <Text style={styles.streakLabel}>Star Dust</Text>
              <Text style={styles.walletValue}>{wallet.balance}</Text>
              <Text style={styles.streakHint}>Your spendable reward balance.</Text>
            </View>

            <View style={styles.walletDivider} />

            <View style={styles.walletStat}>
              <Text style={styles.streakLabel}>Current streak</Text>
              <Text style={styles.streakValue}>{currentStreak} days</Text>
              <Text style={styles.streakHint}>Momentum that unlocks milestone drops and fuels your wallet.</Text>
            </View>
          </View>

          <View style={styles.walletMetaRow}>
            <Text style={styles.walletMetaText}>Lifetime earned: {wallet.lifetimeEarned} Star Dust</Text>
            <Text style={styles.walletMetaText}>Bonus swipes left today: {swipeAllowance.bonusLeft}</Text>
          </View>

          <View style={styles.walletMetaRow}>
            <Text style={styles.walletMetaText}>{hasGoDeeperPass ? `Go Deeper pass active until ${goDeeperExpiry}` : 'Go Deeper pass inactive'}</Text>
            <Text style={styles.walletMetaText}>Sponsor videos left today: {sponsorWatchesLeft}</Text>
          </View>
        </View>

        <Text style={styles.sectionTitle}>Collect Star Dust</Text>

        {starDustWays.map((way) => (
          <View key={way.key} style={styles.rewardCard}>
            <View style={styles.rewardHeaderRow}>
              <Text style={styles.rewardTitle}>{way.title}</Text>
              <View style={styles.amountPill}>
                <Text style={styles.amountPillText}>+{way.amount}</Text>
              </View>
            </View>
            <Text style={styles.rewardDescription}>{way.description}</Text>
            <Text style={styles.statusLabel}>{way.status}</Text>
          </View>
        ))}

        <View style={styles.sponsorCard}>
          <View style={styles.rewardHeaderRow}>
            <Text style={styles.rewardTitle}>Watch sponsor spotlight</Text>
            <View style={styles.amountPill}>
              <Text style={styles.amountPillText}>+{STAR_DUST.sponsorVideo}</Text>
            </View>
          </View>
          <Text style={styles.rewardDescription}>Watch a short sponsor video and earn {STAR_DUST.sponsorVideo} {STAR_DUST.currencyName}. Up to {STAR_DUST.sponsorDailyLimit} per day.</Text>
          <Pressable
            style={({ pressed }) => [
              styles.sponsorButton,
              (sponsorWatchesLeft <= 0 || adError) && styles.sponsorButtonDisabled,
              pressed && { opacity: 0.92 },
            ]}
            onPress={handleSponsorWatch}
            disabled={sponsorWatchesLeft <= 0}
          >
            <Text style={styles.sponsorButtonText}>
              {sponsorWatchesLeft <= 0
                ? 'Sponsor bonuses collected'
                : adLoaded
                  ? `Watch to earn ${STAR_DUST.sponsorVideo} ${STAR_DUST.currencyName} (${sponsorWatchesLeft} left)`
                  : 'Loading ad\u2026'}
            </Text>
          </Pressable>
        </View>

        <Text style={styles.sectionTitle}>Spend Star Dust</Text>
        <Text style={styles.sectionCopy}>Spend your wallet on temporary perks instead of waiting for a subscription.</Text>

        <View style={styles.rewardCard}>
          <View style={styles.rewardHeaderRow}>
            <Text style={styles.rewardTitle}>Go Deeper Pass (24h)</Text>
            <View style={styles.amountPill}>
              <Text style={styles.amountPillText}>-{STAR_DUST.shop.goDeeperPass}</Text>
            </View>
          </View>
          <Text style={styles.rewardDescription}>Unlock the extended reading flow for 24 hours from both Home and Daily.</Text>
          <Text style={styles.statusLabel}>{hasGoDeeperPass ? 'Pass active now' : 'Ready to unlock'}</Text>
          <Pressable
            style={({ pressed }) => [styles.redeemButton, (wallet.balance < STAR_DUST.shop.goDeeperPass || hasGoDeeperPass) && styles.redeemButtonDisabled, pressed && { opacity: 0.9 }]}
            onPress={handleUnlockGoDeeper}
            disabled={wallet.balance < STAR_DUST.shop.goDeeperPass || hasGoDeeperPass}
          >
            <Text style={styles.redeemButtonText}>{hasGoDeeperPass ? 'Pass Active' : 'Unlock with Star Dust'}</Text>
          </Pressable>
        </View>

        <View style={styles.rewardCard}>
          <View style={styles.rewardHeaderRow}>
            <Text style={styles.rewardTitle}>Extra Swipes (+10)</Text>
            <View style={styles.amountPill}>
              <Text style={styles.amountPillText}>-{STAR_DUST.shop.extraSwipesPack}</Text>
            </View>
          </View>
          <Text style={styles.rewardDescription}>Adds 10 more swipes to today&apos;s Match deck and persists in the reward ledger.</Text>
          <Text style={styles.statusLabel}>{swipeAllowance.bonusLeft > 0 ? `${swipeAllowance.bonusLeft} bonus swipes left today` : 'No active swipe boost'}</Text>
          <Pressable
            style={({ pressed }) => [styles.redeemButton, wallet.balance < STAR_DUST.shop.extraSwipesPack && styles.redeemButtonDisabled, pressed && { opacity: 0.9 }]}
            onPress={handleUnlockExtraSwipes}
            disabled={wallet.balance < STAR_DUST.shop.extraSwipesPack}
          >
            <Text style={styles.redeemButtonText}>Buy swipe pack</Text>
          </Pressable>
        </View>

        {!isPremium ? (
          <Pressable style={styles.learnPremium} onPress={() => openPremiumScreen(router, 'rewards_upsell')}>
            <Text style={styles.learnPremiumText}>Need everything unlocked? Upgrade to Premium</Text>
          </Pressable>
        ) : null}

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Wallet Activity</Text>

          {activities.length === 0 ? (
            <View style={styles.empty}>
              <Text style={styles.hint}>No Star Dust activity yet. Complete today&apos;s ritual to start building your wallet.</Text>
            </View>
          ) : (
            activities.slice(0, 6).map((activity) => (
              <View key={activity.id} style={styles.activityCard}>
                <View style={styles.activityHeader}>
                  <Text style={styles.activityTitle}>{activity.title}</Text>
                  <Text style={[styles.activityAmount, activity.kind === 'spend' && styles.activityAmountSpend]}>
                    {activity.kind === 'spend' ? '-' : '+'}{activity.amount}
                  </Text>
                </View>
                <Text style={styles.activityDetail}>{activity.detail}</Text>
                <Text style={styles.activityMeta}>{activity.dateKey}</Text>
              </View>
            ))
          )}

          <Text style={[styles.sectionTitle, { marginTop: 18 }]}>Milestones</Text>

          {loading ? (
            <Text style={styles.hint}>Loading…</Text>
          ) : history.length === 0 ? (
            <View style={styles.empty}>
              <Text style={styles.hint}>No milestones earned yet. Complete daily rituals to start a streak.</Text>
            </View>
          ) : (
            history.map((item) => (
              <RewardItem key={item.id} streak={item.streak} label={item.label} dateKey={item.dateKey} />
            ))
          )}
        </View>

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
  subtitle: {
    color: colors.textMuted,
    marginTop: 6,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 6,
    paddingBottom: 160,
  },
  backRow: {
    marginBottom: 12,
  },
  backText: {
    color: colors.accent,
    fontWeight: '700',
  },
  section: {
    marginTop: 12,
  },
  streakLabel: {
    color: colors.textMuted,
    fontSize: 12,
    textTransform: 'uppercase',
    letterSpacing: 1.2,
    marginBottom: 4,
  },
  streakValue: {
    color: colors.accent,
    fontSize: 28,
    fontWeight: '800',
    marginBottom: 6,
  },
  walletCard: {
    borderRadius: 18,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 16,
    marginBottom: 14,
  },
  walletRow: {
    flexDirection: 'row',
    alignItems: 'stretch',
  },
  walletStat: {
    flex: 1,
  },
  walletDivider: {
    width: 1,
    backgroundColor: colors.cardBorder,
    marginHorizontal: 14,
  },
  walletValue: {
    color: colors.text,
    fontSize: 30,
    fontWeight: '800',
    marginBottom: 6,
  },
  walletMetaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 12,
    marginTop: 14,
  },
  walletMetaText: {
    color: colors.textMuted,
    fontSize: 12,
    flex: 1,
  },
  streakHint: {
    color: colors.textSoft,
    fontSize: 13,
    lineHeight: 19,
  },
  sectionTitle: {
    color: colors.accent,
    marginBottom: 10,
    fontWeight: '700',
  },
  rewardCard: {
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 12,
    marginBottom: 10,
  },
  rewardHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 8,
    marginBottom: 6,
  },
  rewardTitle: {
    flex: 1,
    color: colors.text,
    fontSize: 15,
    fontWeight: '700',
  },
  amountPill: {
    borderRadius: 999,
    backgroundColor: 'rgba(214,181,107,0.14)',
    borderWidth: 1,
    borderColor: 'rgba(214,181,107,0.28)',
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  amountPillText: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '800',
  },
  rewardDescription: {
    color: colors.textSoft,
    fontSize: 13,
    lineHeight: 19,
    marginBottom: 8,
  },
  statusLabel: {
    color: colors.textMuted,
    fontSize: 12,
    fontWeight: '600',
  },
  sponsorCard: {
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 12,
    marginBottom: 14,
  },
  sponsorButton: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: 'rgba(214,181,107,0.28)',
    backgroundColor: 'rgba(214,181,107,0.14)',
    paddingVertical: 11,
    alignItems: 'center',
  },
  sponsorButtonText: {
    color: colors.accent,
    fontWeight: '700',
    fontSize: 13,
  },
  redeemButton: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(214,181,107,0.12)',
    paddingVertical: 10,
    alignItems: 'center',
    marginTop: 8,
  },
  redeemButtonDisabled: {
    opacity: 0.45,
  },
  sponsorButtonDisabled: {
    opacity: 0.45,
  },
  redeemButtonText: {
    color: colors.accent,
    fontSize: 13,
    fontWeight: '700',
  },
  learnPremium: {
    marginBottom: 14,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.03)',
    paddingVertical: 11,
    alignItems: 'center',
  },
  learnPremiumText: {
    color: colors.text,
    fontSize: 13,
    fontWeight: '700',
  },
  hint: {
    color: colors.textMuted,
  },
  sectionCopy: {
    color: colors.textMuted,
    marginBottom: 10,
  },
  empty: {
    paddingVertical: 18,
  },
  activityCard: {
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 12,
    marginBottom: 10,
  },
  activityHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
    gap: 12,
  },
  activityTitle: {
    color: colors.text,
    fontWeight: '700',
    flex: 1,
  },
  activityAmount: {
    color: colors.accent,
    fontWeight: '800',
  },
  activityAmountSpend: {
    color: colors.textMuted,
  },
  activityDetail: {
    color: colors.textSoft,
    fontSize: 13,
    lineHeight: 18,
  },
  activityMeta: {
    color: colors.textMuted,
    fontSize: 11,
    marginTop: 8,
  },
});
