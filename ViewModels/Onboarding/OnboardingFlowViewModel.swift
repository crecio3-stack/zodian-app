import Foundation
import Combine
import SwiftData

@MainActor
final class OnboardingFlowViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var birthday: Date = Date()
    @Published var birthTime: Date?
    @Published var birthPlaceRaw: String = ""
    @Published var birthPlaceNormalized: String?
    @Published var birthTimezoneIdentifier: String?

    @Published var westernSign: WesternZodiac?
    @Published var chineseSign: ChineseZodiac?
    @Published var identityContent: ZodiacIdentityContent?
    @Published var previewReading: DailyReading?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func computeSigns() {
        let result = AstrologyCalculator.combinedSigns(from: birthday)
        westernSign = result.western
        chineseSign = result.chinese
    }

    func resolveIdentityContent() {
        guard let western = westernSign,
              let chinese = chineseSign else { return }
        guard let content = ZodiacIdentityContentService.shared.content(
            forWestern: western.rawValue,
            chinese: chinese.rawValue
        ) else {
            print("[OnboardingFlowViewModel] Missing archetype-backed identity content for \(western.rawValue)-\(chinese.rawValue)")
            errorMessage = "Failed to generate identity"
            identityContent = nil
            return
        }
#if DEBUG
        print("[OnboardingFlowViewModel] Resolving identity with western='\(western.rawValue)' chinese='\(chinese.rawValue)' -> \(content.id)")
#endif
        identityContent = content
    }

    func prepareReveal() {
        isLoading = true
        errorMessage = nil

        computeSigns()
        resolveIdentityContent()
        buildPreviewReading()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isLoading = false
        }
    }

    private func buildPreviewReading() {
        guard let western = westernSign,
              let chinese = chineseSign,
              let identityContent,
              let archetype = ArchetypeService.shared.archetypeIfLoaded(forId: identityContent.id) else {
            previewReading = nil
            print("[OnboardingFlowViewModel] Missing archetype-backed preview reading content")
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let previewUser = UserProfile(
            name: trimmedName.isEmpty ? "Friend" : trimmedName,
            birthday: birthday,
            birthTime: birthTime,
            birthPlaceRaw: birthPlaceRaw.isEmpty ? nil : birthPlaceRaw,
            birthPlaceNormalized: birthPlaceNormalized,
            birthTimezoneIdentifier: birthTimezoneIdentifier,
            westernSignRaw: western.rawValue,
            chineseSignRaw: chinese.rawValue,
            archetypeId: identityContent.id
        )

        previewReading = DailyReadingGenerator.generate(
            context: .init(
                archetype: archetype,
                user: previewUser,
                streak: 0,
                date: Date(),
                previousIdentities: [],
                recentThemes: [],
                recentTones: [],
                lastReflectionTag: nil,
                skyContext: DailySkyContextProvider.context(for: Date())
            )
        )
    }

    func applyBirthplace(
        raw: String,
        normalized: String?,
        timezoneIdentifier: String?
    ) {
        birthPlaceRaw = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        birthPlaceNormalized = normalized?.trimmingCharacters(in: .whitespacesAndNewlines)
        birthTimezoneIdentifier = timezoneIdentifier
    }

    func updateBirthplaceRaw(_ raw: String) {
        birthPlaceRaw = raw
        birthPlaceNormalized = nil
        birthTimezoneIdentifier = nil
    }

    func finalizeOptionalInputs() {
        let trimmedRaw = birthPlaceRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        birthPlaceRaw = trimmedRaw

        if trimmedRaw.isEmpty {
            birthPlaceRaw = ""
            birthPlaceNormalized = nil
            birthTimezoneIdentifier = nil
        }
    }

    func clearOptionalRefinement() {
        birthTime = nil
        birthPlaceRaw = ""
        birthPlaceNormalized = nil
        birthTimezoneIdentifier = nil
    }

    func completeOnboarding(
        store: AppStore,
        context: ModelContext
    ) {
        guard let western = westernSign,
              let chinese = chineseSign,
              let identityContent else {
            errorMessage = "Failed to generate identity"
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = trimmedName.isEmpty ? "Friend" : trimmedName
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\UserProfile.createdAt, order: .forward)]
        )
        let user: UserProfile
        do {
            let users = try context.fetch(descriptor)

            if let existingUser = users.first {
                existingUser.name = resolvedName
                existingUser.birthday = birthday
                existingUser.birthTime = birthTime
                existingUser.birthPlaceRaw = birthPlaceRaw.isEmpty ? nil : birthPlaceRaw
                existingUser.birthPlaceNormalized = birthPlaceNormalized
                existingUser.birthTimezoneIdentifier = birthTimezoneIdentifier
                existingUser.westernSignRaw = western.rawValue
                existingUser.chineseSignRaw = chinese.rawValue
                existingUser.archetypeId = identityContent.id

                for duplicate in users.dropFirst() {
                    context.delete(duplicate)
                }
                user = existingUser
            } else {
                let newUser = UserProfile(
                    name: resolvedName,
                    birthday: birthday,
                    birthTime: birthTime,
                    birthPlaceRaw: birthPlaceRaw.isEmpty ? nil : birthPlaceRaw,
                    birthPlaceNormalized: birthPlaceNormalized,
                    birthTimezoneIdentifier: birthTimezoneIdentifier,
                    westernSignRaw: western.rawValue,
                    chineseSignRaw: chinese.rawValue,
                    archetypeId: identityContent.id
                )
                context.insert(newUser)
                user = newUser
            }
        } catch {
            errorMessage = "Failed to prepare profile"
            print("Fetch error: \(error)")
            return
        }

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save profile"
            print("Save error: \(error)")
            return
        }


        store.currentUser = user
        store.completeOnboarding()
        AnalyticsService.shared.track(
            .onboardingCompleted(
                identityID: identityContent.id,
                westernSign: western.rawValue,
                chineseSign: chinese.rawValue,
                nameProvided: !trimmedName.isEmpty
            )
        )
    }

    var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
