export type MilestoneRecord = {
  id: string; // simple unique id (timestamp-based)
  streak: number;
  label?: string;
  dateKey: string; // YYYY-MM-DD
  createdAt: string; // ISO timestamp
};

export type RewardActivitySource =
  | 'daily-ritual'
  | 'streak-milestone'
  | 'watch-ad'
  | 'share-ritual'
  | 'redeem-go-deeper'
  | 'redeem-extra-swipes';

export type RewardActivityKind = 'earn' | 'spend';

export type RewardActivity = {
  id: string;
  amount: number;
  kind: RewardActivityKind;
  source: RewardActivitySource;
  title: string;
  detail: string;
  dateKey: string;
  createdAt: string;
};

export type RewardsWallet = {
  balance: number;
  lifetimeEarned: number;
  lastDailyCompletionAwardedDate?: string;
  lastSharedDate?: string;
  adWatchDate?: string;
  adWatchCountToday: number;
  claimedMilestones: number[];
  updatedAt?: string;
};

export type RewardsPerks = {
  goDeeperPassExpiresAt?: number;
  extraSwipesDate?: string;
  extraSwipesRemaining: number;
  swipeUsageDate?: string;
  swipeUsageCount: number;
  updatedAt?: string;
};

export type RewardGrantResult = {
  awarded: boolean;
  amount: number;
  reason?: 'already_claimed' | 'limit_reached' | 'not_eligible';
  wallet: RewardsWallet;
  activity?: RewardActivity;
};

export type RewardSpendResult = {
  success: boolean;
  amount: number;
  reason?: 'insufficient_balance' | 'already_active';
  wallet: RewardsWallet;
  perks: RewardsPerks;
  activity?: RewardActivity;
};

export type SwipeAllowance = {
  used: number;
  baseLeft: number;
  bonusLeft: number;
  totalLeft: number;
  totalLimit: number;
};
