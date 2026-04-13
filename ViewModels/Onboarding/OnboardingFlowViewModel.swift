import Foundation
import Combine
import SwiftData
// Remove ArchetypeService dependency

@MainActor
final class OnboardingFlowViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var birthday: Date = Date()

    @Published var westernSign: WesternZodiac?
    @Published var chineseSign: ChineseZodiac?
    @Published var identityContent: ZodiacIdentityContent?

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
        let content = ZodiacIdentityContentService.shared.safeContent(forWestern: western.rawValue, chinese: chinese.rawValue)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isLoading = false
        }
    }

    func completeOnboarding(
        store: AppStore,
        context: ModelContext
    ) {
        guard let western = westernSign,
              let chinese = chineseSign,
              let identityContent else {
            errorMessage = "Failed to generate identity."
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
                    westernSignRaw: western.rawValue,
                    chineseSignRaw: chinese.rawValue,
                    archetypeId: identityContent.id
                )
                context.insert(newUser)
                user = newUser
            }
        } catch {
            errorMessage = "Failed to prepare profile."
            print("Fetch error: \(error)")
            return
        }

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save profile."
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
