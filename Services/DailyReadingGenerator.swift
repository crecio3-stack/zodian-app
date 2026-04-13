import Foundation

enum DailyReadingGenerator {
    static func generate(for archetype: Archetype) -> DailyReading {
        let mood = moodForToday(archetypeId: archetype.id)
        let theme = themeForMood(mood)
        let summary = summaryFor(archetype: archetype, mood: mood)
        let love = loveFor(archetype: archetype, mood: mood)
        let work = workFor(archetype: archetype, mood: mood)
        let growth = growthFor(archetype: archetype, mood: mood)
        let caution = cautionFor(archetype: archetype, mood: mood)
        let opportunity = opportunityFor(archetype: archetype, mood: mood)

        return DailyReading(
            theme: theme,
            summary: summary,
            mood: mood.rawValue,
            love: love,
            work: work,
            growth: growth,
            caution: caution,
            opportunity: opportunity
        )
    }

    private static func moodForToday(archetypeId: String) -> DailyMood {
        let moods = DailyMood.allCases
        let daySeed = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let combined = abs(archetypeId.hashValue ^ daySeed)
        return moods[combined % moods.count]
    }

    private static func themeForMood(_ mood: DailyMood) -> String {
        switch mood {
        case .clarity:
            return "Clear Seeing"
        case .magnetism:
            return "Quiet Attraction"
        case .restraint:
            return "Sacred Restraint"
        case .devotion:
            return "Steady Heart"
        case .momentum:
            return "Directed Momentum"
        case .softness:
            return "Gentle Power"
        }
    }

    private static func summaryFor(archetype: Archetype, mood: DailyMood) -> String {
        switch mood {
        case .clarity:
            return "Today favors discernment. \(archetype.title) is strongest when intuition is paired with clean decision-making."
        case .magnetism:
            return "Your energy is more noticeable than usual today. Let attraction come through presence rather than performance."
        case .restraint:
            return "You do not need to force movement. There is power in allowing timing, tone, and instinct to work together."
        case .devotion:
            return "What you tend with care deepens today. Return to what matters instead of scattering your attention."
        case .momentum:
            return "This is a day to move something forward. A small but honest action will carry more weight than overplanning."
        case .softness:
            return "You do not need to harden to be effective. Softness can be structure when it is paired with self-trust."
        }
    }

    private static func loveFor(archetype: Archetype, mood: DailyMood) -> String {
        switch mood {
        case .clarity:
            return "In love, clarity is kinder than mixed signals. \(archetype.loveStyle)"
        case .magnetism:
            return "Romantic energy is heightened. Let curiosity and reciprocity lead instead of trying to control the outcome."
        case .restraint:
            return "Not every feeling needs immediate expression. Today favors quiet honesty over emotional overexposure."
        case .devotion:
            return "Small gestures land strongly today. Consistency matters more than intensity."
        case .momentum:
            return "If there is a conversation you’ve delayed, this is a good day to begin it with directness and warmth."
        case .softness:
            return "Your tenderness is part of your appeal today. Lead with sincerity, not defense."
        }
    }

    private static func workFor(archetype: Archetype, mood: DailyMood) -> String {
        switch mood {
        case .clarity:
            return "Prioritize what is essential. \(archetype.workStyle)"
        case .magnetism:
            return "Your presence carries influence today. Let others feel your conviction without overselling it."
        case .restraint:
            return "Not every opportunity deserves your energy. Focus on the one thing that actually matters."
        case .devotion:
            return "Steady craftsmanship beats dramatic effort today. Build patiently."
        case .momentum:
            return "Push forward on the task that has been waiting for your confidence."
        case .softness:
            return "A calmer, more measured approach will outperform pressure and urgency."
        }
    }

    private static func growthFor(archetype: Archetype, mood: DailyMood) -> String {
        switch mood {
        case .clarity:
            return "Growth today comes from naming what is true without adding extra story around it."
        case .magnetism:
            return "Notice where you seek validation and where you genuinely want connection. They are not always the same."
        case .restraint:
            return "Let your next move come from intention, not from discomfort with stillness."
        case .devotion:
            return "Return to your actual values. Repetition in the right direction is transformation."
        case .momentum:
            return "Take one concrete step. Motion will teach you what thinking cannot."
        case .softness:
            return "Your nervous system may need gentleness before your ambition can become clear."
        }
    }

    private static func cautionFor(archetype: Archetype, mood: DailyMood) -> String {
        switch mood {
        case .clarity:
            return "Avoid overcomplicating what is already visible."
        case .magnetism:
            return "Do not confuse attention with alignment."
        case .restraint:
            return "Be careful not to turn self-protection into distance."
        case .devotion:
            return "Loyalty should not become self-abandonment."
        case .momentum:
            return "Speed without alignment will create extra cleanup later."
        case .softness:
            return "Do not mistake gentleness for passivity. You still need boundaries."
        }
    }

    private static func opportunityFor(archetype: Archetype, mood: DailyMood) -> String {
        switch mood {
        case .clarity:
            return "A cleaner decision opens space for more peace than you expect."
        case .magnetism:
            return "An unexpected invitation or conversation may hold more potential than first appears."
        case .restraint:
            return "A quiet pause helps you notice where your energy is best invested."
        case .devotion:
            return "What you nurture today can become part of your longer-term rhythm."
        case .momentum:
            return "A small decisive action creates disproportionate forward motion."
        case .softness:
            return "Receiving support without resistance is part of today’s growth."
        }
    }
}
