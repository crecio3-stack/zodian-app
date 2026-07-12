import Foundation

struct RewardProgressState {
    let streak: Int
    let unlockedRewards: Set<String>
}

struct RewardMilestoneResult {
    let rewardsToUnlock: Set<String>
    let bonusPointsAwarded: Int
    let shouldInsertStreakMilestoneLedgerEntry: Bool
}

enum RewardProgressService {
    static func nextRewardTitle(for streak: Int) -> String {
        if streak < 7 {
            return "7-Day Bonus"
        } else if streak < 14 {
            return "14-Day Preview"
        } else if streak < 30 {
            return "30-Day Reward Access"
        } else {
            return "All milestone rewards unlocked"
        }
    }

    static func nextRewardSubtitle(for streak: Int) -> String {
        if streak < 7 {
            return "Earn a 25-point streak milestone bonus."
        } else if streak < 14 {
            return "Open Pattern Archive preview for today."
        } else if streak < 30 {
            return "Open reward-based Pattern Archive access."
        } else {
            return "You’ve completed the current streak roadmap."
        }
    }

    static func daysUntilNextReward(for streak: Int) -> Int {
        if streak < 7 {
            return 7 - streak
        } else if streak < 14 {
            return 14 - streak
        } else if streak < 30 {
            return 30 - streak
        } else {
            return 0
        }
    }

    static func nextRewardProgress(for streak: Int) -> Double {
        let target: Double
        let start: Double

        if streak < 7 {
            start = 0
            target = 7
        } else if streak < 14 {
            start = 7
            target = 14
        } else if streak < 30 {
            start = 14
            target = 30
        } else {
            return 1.0
        }

        let normalized = (Double(streak) - start) / (target - start)
        return min(max(normalized, 0), 1)
    }

    static func milestoneResult(
        previousStreak: Int,
        currentState: RewardProgressState
    ) -> RewardMilestoneResult {
        guard currentState.streak != previousStreak else {
            return RewardMilestoneResult(
                rewardsToUnlock: [],
                bonusPointsAwarded: 0,
                shouldInsertStreakMilestoneLedgerEntry: false
            )
        }

        var rewardsToUnlock = Set<String>()
        var bonusPointsAwarded = 0
        var shouldInsertLedgerEntry = false

        if currentState.streak >= 7,
           !currentState.unlockedRewards.contains(RewardKey.bonus7DayClaimed) {
            rewardsToUnlock.insert(RewardKey.bonus7DayClaimed)
            bonusPointsAwarded += 25
            shouldInsertLedgerEntry = true
        }

        if currentState.streak >= 14,
           !currentState.unlockedRewards.contains(RewardKey.preview14Day) {
            rewardsToUnlock.insert(RewardKey.preview14Day)
        }

        if currentState.streak >= 30 {
            rewardsToUnlock.insert(RewardKey.premiumTrial30Day)
        }

        return RewardMilestoneResult(
            rewardsToUnlock: rewardsToUnlock,
            bonusPointsAwarded: bonusPointsAwarded,
            shouldInsertStreakMilestoneLedgerEntry: shouldInsertLedgerEntry
        )
    }
}
