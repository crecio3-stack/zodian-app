import SwiftUI
import SwiftData
#if DEBUG || BETA
import AuthenticationServices
#endif
import MessageUI
import UIKit

struct AccountSettingsView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var accountOwnership: AccountOwnershipController
    @Environment(\.modelContext) private var context
    @Query(sort: \UserProfile.createdAt, order: .forward) private var users: [UserProfile]
    @Query(sort: \ConnectUserProfile.updatedAt, order: .reverse) private var connectProfiles: [ConnectUserProfile]

    @State private var displayName = ""
    @State private var birthday = Date()
    @State private var originalName = ""
    @State private var originalBirthday = Date()
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var showDeleteConfirmation = false
    @State private var showDeletionSuccess = false
    @State private var isDeletingAccount = false
    @State private var deletionErrorMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Account",
                    subtitle: "Name and birthday"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        editableFieldSection

                        divider

                        identityPreviewSection
                    }
                }

                Button(action: saveAccount) {
                    HStack(spacing: 8) {
                        Text("Save changes")
                            .font(ZD.Font.body(.semibold))
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(canSave ? AnyShapeStyle(ZD.Gradient.gold) : AnyShapeStyle(ZD.Color.cardAlt.opacity(0.7)))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)

                if let statusMessage {
                    settingsStatusText(statusMessage, color: ZD.Color.accent)
                }

                if let errorMessage {
                    settingsStatusText(errorMessage, color: ZD.Color.error)
                }

#if DEBUG || BETA
                SectionHeader(
                    title: "Sign-in",
                    subtitle: "Link Apple to this Zodian account"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        appleAccountLinkSection

                        if !accountOwnership.isAppleLinked {
                            Text("Link Apple to this Zodian account.")
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
#endif

                SectionHeader(
                    title: "Delete account",
                    subtitle: "Permanently remove this account and its data"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("This deletes your account and clears your local profile, saved people, photos, Daily Lens cache, and notifications from this device.")
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(role: .destructive) {
                            if accountOwnership.requiresLocalAccountDeletionCleanup {
                                retryLocalAccountCleanup()
                            } else {
                                showDeleteConfirmation = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isDeletingAccount {
                                    ProgressView()
                                        .tint(ZD.Color.error)
                                } else {
                                    Image(systemName: "trash")
                                        .font(.system(size: 13, weight: .semibold))
                                }

                                Text(
                                    accountOwnership.requiresLocalAccountDeletionCleanup
                                        ? "Retry local cleanup"
                                        : "Delete account"
                                )
                                .font(ZD.Font.body(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(ZD.Color.error)
                        .disabled(isDeletingAccount)

                        if let deletionErrorMessage {
                            settingsStatusText(deletionErrorMessage, color: ZD.Color.error)
                        }
                    }
                }
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear(perform: loadAccount)
        .onChange(of: store.identityRefreshToken) {
            loadAccount()
        }
        .onChange(of: accountOwnership.state) { _, newState in
            switch newState {
            case .linked:
#if DEBUG || BETA
                statusMessage = "Connected with Apple. Your Account ID stayed the same."
                errorMessage = nil
#endif
            case .failed(let failure):
                errorMessage = failure.message
            case .idle, .bootstrapping, .deleting, .anonymous:
                break
            }
        }
        .confirmationDialog(
            "Delete your account?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone. Your account and local Zodian data will be removed.")
        }
        .alert("Account deleted", isPresented: $showDeletionSuccess) {
            Button("Continue") {
                store.completeAccountDeletion()
            }
        } message: {
            Text("Your Zodian account and local data were deleted.")
        }
    }

    private var editableFieldSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Display name")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)

                TextField("Display name", text: $displayName)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .textInputAutocapitalization(.words)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(ZD.Color.cardAlt.opacity(0.58))
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Birthday")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)

                DatePicker(
                    "Birthday",
                    selection: $birthday,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(ZD.Color.accent)

                Text("Changing this updates your Western × Eastern identity.")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var identityPreviewSection: some View {
        let signs = AstrologyCalculator.combinedSigns(from: birthday)
        let title = ZodiacIdentityContentService.shared.content(
            forWestern: signs.western.rawValue,
            chinese: signs.chinese.rawValue
        )?.title ?? "Identity will refresh after saving"

        return VStack(alignment: .leading, spacing: 5) {
            Text("Identity preview")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(0.9)

            Text("\(signs.western.displayName) × \(signs.chinese.displayName)")
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)

            Text(title)
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var canSave: Bool {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return trimmed != originalName || !Calendar.current.isDate(birthday, inSameDayAs: originalBirthday)
    }

    private func loadAccount() {
        store.loadUserIfNeeded(context: context)
        guard let user = store.currentUser ?? users.first else { return }

        displayName = user.name
        birthday = user.birthday
        originalName = user.name
        originalBirthday = user.birthday
    }

    private func saveAccount() {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Display name can't be empty."
            return
        }

        store.loadUserIfNeeded(context: context)
        guard let user = store.currentUser ?? users.first else {
            errorMessage = "Finish onboarding before editing account details."
            return
        }

        let oldName = user.name
        let signs = AstrologyCalculator.combinedSigns(from: birthday)
        guard let identityContent = ZodiacIdentityContentService.shared.content(
            forWestern: signs.western.rawValue,
            chinese: signs.chinese.rawValue
        ) else {
            errorMessage = "Couldn't resolve that identity yet."
            return
        }

        user.name = trimmedName
        user.birthday = birthday
        user.westernSignRaw = signs.western.rawValue
        user.chineseSignRaw = signs.chinese.rawValue
        user.archetypeId = identityContent.id

        updateConnectCardIfItStillMirrorsAccountName(oldName: oldName, newName: trimmedName)

        do {
            try context.save()
            store.currentUser = user
            store.markIdentityStateChanged()
            originalName = trimmedName
            originalBirthday = birthday
            statusMessage = "Saved. Your identity has been refreshed."
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't save right now. Try again."
        }
    }

    private func updateConnectCardIfItStillMirrorsAccountName(oldName: String, newName: String) {
        guard let profile = connectProfiles.first else { return }

        let oldFirstName = oldName.split(separator: " ").first.map(String.init) ?? oldName
        let newFirstName = newName.split(separator: " ").first.map(String.init) ?? newName
        let current = profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        if current.caseInsensitiveCompare(oldName) == .orderedSame ||
            current.caseInsensitiveCompare(oldFirstName) == .orderedSame {
            profile.displayName = newFirstName
        }

        if let years = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year,
           years > 0 {
            profile.age = years
        }
        profile.updatedAt = Date()
    }

    private func deleteAccount() {
        guard !isDeletingAccount else { return }

        isDeletingAccount = true
        deletionErrorMessage = nil

        Task { @MainActor in
            do {
                try await accountOwnership.deleteCurrentAccount()
                try await completeLocalAccountCleanup()
            } catch {
                deletionErrorMessage = accountOwnership.requiresLocalAccountDeletionCleanup
                    ? "Your online account was deleted, but this device could not clear all local data. Keep this screen open and try again."
                    : "Your account was not deleted. Check your connection and try again."
                isDeletingAccount = false
            }
        }
    }

    private func retryLocalAccountCleanup() {
        guard accountOwnership.requiresLocalAccountDeletionCleanup, !isDeletingAccount else { return }
        isDeletingAccount = true
        deletionErrorMessage = nil

        Task { @MainActor in
            do {
                try await completeLocalAccountCleanup()
            } catch {
                deletionErrorMessage = "Your online account was deleted, but this device could not clear all local data. Keep this screen open and try again."
                isDeletingAccount = false
            }
        }
    }

    private func completeLocalAccountCleanup() async throws {
        try store.purgeAccountLocalData(context: context)
        try await accountOwnership.completeLocalAccountDeletion()
        isDeletingAccount = false
        showDeletionSuccess = true
    }

#if DEBUG || BETA
    @ViewBuilder
    private var appleAccountLinkSection: some View {
        if accountOwnership.isAppleLinked {
            HStack(spacing: 12) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ZD.Color.textPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Connected with Apple")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Your recovery credential is active")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(ZD.Color.accent)
            }
            .padding(.vertical, 8)
        } else if case .bootstrapping = accountOwnership.state {
            HStack(spacing: 10) {
                ProgressView()
                    .tint(ZD.Color.accent)

                Text("Securing account…")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        } else {
            SignInWithAppleButton(
                .continue,
                onRequest: accountOwnership.prepareAppleLinkRequest,
                onCompletion: { result in
                    Task {
                        await accountOwnership.completeAppleLink(result)
                    }
                }
            )
            .signInWithAppleButtonStyle(.white)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
#endif
}

struct PrivacySettingsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Privacy",
                    subtitle: "Your people and identity stay under your control"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Saved people stay on this device")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text("People you add in Read Someone are stored locally. They do not need a Zodian account and are not visible to other people.")
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        divider

                        Text("Sharing is always explicit")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text("An identity card is only shared when you choose Share. Birth details are not included in shared content.")
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        divider

                        Link(destination: URL(string: "https://zodianapp.com/privacy")!) {
                            HStack(spacing: 8) {
                                Text("Privacy Policy")
                                    .font(ZD.Font.body(.semibold))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(ZD.Color.accent)
                        }
                    }
                }
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct SupportSettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showMailComposer = false
    @State private var showMailFallback = false
    @State private var copiedEmail = false

    private let supportEmail = "zodianapp@gmail.com"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Support",
                    subtitle: "Questions and feedback"
                )

                TarotCardContainer {
                    VStack(spacing: 0) {
                        Button(action: submitFeedback) {
                            supportRow(
                                title: "Submit feedback",
                                subtitle: "Tell us what happened and what you expected",
                                icon: "paperplane.fill",
                                trailing: "Email"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Contact email")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(supportEmail)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)

                        Button {
                            UIPasteboard.general.string = supportEmail
                            copiedEmail = true
                        } label: {
                            HStack(spacing: 8) {
                                Text(copiedEmail ? "Copied" : "Copy email")
                                    .font(ZD.Font.caption(.semibold))
                                Image(systemName: copiedEmail ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(ZD.Color.accent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showMailComposer) {
            MailComposeView(
                recipients: [supportEmail],
                subject: "Zodian Feedback",
                body: feedbackBody
            )
        }
        .alert("Email is unavailable", isPresented: $showMailFallback) {
            Button("Copy Email") {
                UIPasteboard.general.string = supportEmail
                copiedEmail = true
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Email is not configured on this device. You can contact us at \(supportEmail).")
        }
    }

    private var feedbackBody: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let identity = store.currentUser.map {
            "\($0.westernSign.displayName) × \($0.chineseSign.displayName)"
        } ?? "No user profile loaded"

        return """


What happened:

What I expected:

Screenshots attached:

---
    App details
App: Zodian \(version) (\(build))
Device: \(Self.deviceModel)
iOS: \(UIDevice.current.systemVersion)
Current tab: \(store.selectedTab.feedbackName)
Identity: \(identity)
"""
    }

    private static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(String(UnicodeScalar(UInt8(value))))
        }
    }

    private func submitFeedback() {
        if MFMailComposeViewController.canSendMail() {
            showMailComposer = true
        } else {
            showMailFallback = true
        }
    }

    private func supportRow(title: String, subtitle: String, icon: String, trailing: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            if let trailing {
                Text(trailing)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ZD.Color.muted)
            }
        }
        .padding(.vertical, 12)
    }
}

private struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(recipients)
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true)
        }
    }
}

private extension AppTab {
    var feedbackName: String {
        switch self {
        case .home: return "Lens"
        case .blueprint: return "Identity"
        case .connect: return "Connect"
        case .matches: return "My Circle"
        case .profile: return "Profile"
        }
    }
}

private var divider: some View {
    Rectangle()
        .fill(ZD.Color.border.opacity(0.24))
        .frame(height: 1)
}

private func settingsStatusText(_ text: String, color: Color) -> some View {
    Text(text)
        .font(ZD.Font.caption(.semibold))
        .foregroundStyle(color)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 2)
}

struct SavedDailyReadsView: View {
    @Query(sort: \SavedDailyReading.createdAt, order: .reverse) private var savedReadings: [SavedDailyReading]
    let navigationTitle: String

    init(navigationTitle: String = "Saved Reads") {
        self.navigationTitle = navigationTitle
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Saved reads",
                    subtitle: "Daily Lens entries you kept"
                )

                if savedReadings.isEmpty {
                    TarotCardContainer {
                        Text("Saved Daily Lens entries will appear here after you save one from Lens.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(savedReadings) { reading in
                            NavigationLink {
                                SavedDailyReadDetailView(reading: reading)
                            } label: {
                                savedReadRow(reading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private func savedReadRow(_ reading: SavedDailyReading) -> some View {
        TarotCardContainer {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(reading.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .textCase(.uppercase)

                    Text(savedRowTitle(for: reading))
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(2)

                    Text(reading.versionedLensContent?.read ?? reading.insight ?? reading.summary)
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ZD.Color.muted)
                    .padding(.top, 4)
            }
        }
    }

    private func savedRowTitle(for reading: SavedDailyReading) -> String {
        if let title = reading.versionedLensContent?.title,
           !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }
        if reading.versionedLensContent != nil {
            return "Daily Lens"
        }
        return reading.identity ?? reading.theme
    }
}

struct SavedDailyReadDetailView: View {
    let reading: SavedDailyReading
    @State private var showShareSheet = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Saved Lens",
                    subtitle: reading.createdAt.formatted(date: .long, time: .omitted)
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 14) {
                        if let title = reading.versionedLensContent?.title,
                           !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(title)
                                .font(ZD.Font.title())
                                .foregroundStyle(ZD.Color.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        } else if reading.versionedLensContent == nil {
                            Text(reading.identity ?? reading.theme)
                                .font(ZD.Font.title())
                                .foregroundStyle(ZD.Color.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let versionedRead {
                            Text(versionedRead)
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            if let intro {
                                Text(intro)
                                    .font(ZD.Font.body())
                                    .foregroundStyle(ZD.Color.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let pullQuote {
                                HStack(alignment: .top, spacing: 12) {
                                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                                        .fill(ZD.Color.accent.opacity(0.72))
                                        .frame(width: 3, height: 52)

                                    Text(pullQuote)
                                        .font(.system(size: 21, weight: .bold, design: .serif))
                                        .foregroundStyle(ZD.Color.textPrimary)
                                        .lineSpacing(4)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            if let deeperRead {
                                Text(deeperRead)
                                    .font(ZD.Font.body())
                                    .foregroundStyle(ZD.Color.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let watchFor {
                                readField("Watch", watchFor)
                            }

                            if let move {
                                readField("Move", move)
                            }
                        }
                    }
                }

                Button {
                    showShareSheet = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .bold))

                        Text("Share Lens")
                            .font(ZD.Font.body(.semibold))
                    }
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule(style: .continuous).fill(ZD.Gradient.gold))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Saved Lens")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showShareSheet) {
            ActivityShareSheet(activityItems: [shareText])
        }
    }

    private func readField(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(ZD.Color.accent)

            Text(value)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var intro: String? {
        normalizedSavedReadValue(reading.insight)
    }

    private var versionedRead: String? {
        reading.versionedLensContent?.read
    }

    private var pullQuote: String? {
        normalizedSavedReadValue(reading.summary)
    }

    private var deeperRead: String? {
        normalizedSavedReadValue(reading.focus ?? reading.work)
    }

    private var watchFor: String? {
        normalizedSavedReadValue(reading.caution)
    }

    private var move: String? {
        normalizedSavedReadValue(reading.affirmation ?? reading.opportunity)
    }

    private func normalizedSavedReadValue(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed, !trimmed.isEmpty else { return nil }
        return trimmed
    }

    private var shareText: String {
        if let content = reading.versionedLensContent {
            return DailyLensSharePayload(
                content: content,
                signLine: reading.createdAt.formatted(date: .abbreviated, time: .omitted)
            ).text
        }

        let body = [
            intro,
            pullQuote,
            deeperRead,
            watchFor.map { "Watch: \($0)" },
            move.map { "Move: \($0)" }
        ]
            .compactMap { $0 }
            .joined(separator: "\n\n")

        return """
        Zodian Daily Lens
        \(reading.createdAt.formatted(date: .abbreviated, time: .omitted))

        \(reading.versionedLensContent?.title ?? reading.identity ?? reading.theme)

        \(body)
        """
    }
}
