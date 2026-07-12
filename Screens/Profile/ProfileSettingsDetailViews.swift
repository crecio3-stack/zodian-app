import SwiftUI
import SwiftData
import AuthenticationServices
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

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Account",
                    subtitle: "Name, birthday, and account recovery"
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

                SectionHeader(
                    title: "Sign-in",
                    subtitle: "Protect this account with a recovery credential"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        appleAccountLinkSection

                        if !accountOwnership.isAppleLinked {
                            Text("Until Apple is linked, this account can be lost if the app is removed or this device is replaced.")
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)
                                .fixedSize(horizontal: false, vertical: true)
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
                statusMessage = "Connected with Apple. Your Account ID stayed the same."
                errorMessage = nil
            case .failed(let failure):
                errorMessage = failure.message
            case .idle, .bootstrapping, .anonymous:
                break
            }
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
}

struct PrivacySettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context
    @Query(sort: \ConnectUserProfile.updatedAt, order: .reverse) private var connectProfiles: [ConnectUserProfile]

    @State private var statusMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Privacy",
                    subtitle: "Local visibility controls for beta"
                )

                TarotCardContainer {
                    VStack(spacing: 0) {
                        privacyToggleRow(
                            title: "Show me in Connect",
                            subtitle: "When off, your Connect card is hidden from discovery on this device.",
                            isOn: $store.showMeInConnect
                        )
                        .onChange(of: store.showMeInConnect) {
                            applyConnectVisibility()
                        }

                        divider

                        privacyToggleRow(
                            title: "Allow discovery",
                            subtitle: "Controls whether your completed card can appear in the Connect discovery pool.",
                            isOn: $store.allowProfileDiscovery
                        )
                        .onChange(of: store.allowProfileDiscovery) {
                            applyConnectVisibility()
                        }

                        divider

                        privacyToggleRow(
                            title: "Saved profile previews",
                            subtitle: "Allows local saved or shared profile previews to show basic card details.",
                            isOn: $store.allowSavedSharedProfilePreviews
                        )
                    }
                }

                if let statusMessage {
                    settingsStatusText(statusMessage, color: ZD.Color.accent)
                }

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(connectVisibilityTitle)
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(connectVisibilityBody)
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                            .fixedSize(horizontal: false, vertical: true)
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
        .onAppear {
            applyConnectVisibility(showStatus: false)
        }
    }

    private var connectVisibilityTitle: String {
        store.connectVisibilityAllowsDiscovery ? "Connect visibility is on" : "Connect visibility is off"
    }

    private var connectVisibilityBody: String {
        if connectProfiles.first == nil {
            return "You do not have a Connect card yet. These settings will apply when you create one."
        }

        return store.connectVisibilityAllowsDiscovery
            ? "Your Connect card can appear in local beta discovery."
            : "Your Connect card is hidden from discovery until these controls are turned back on."
    }

    private func privacyToggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(subtitle)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: ZD.Color.accent))
        .padding(.vertical, 12)
    }

    private func applyConnectVisibility(showStatus: Bool = true) {
        let isVisible = store.connectVisibilityAllowsDiscovery
        let profilesNeedingUpdate = connectProfiles.filter { $0.isVisible != isVisible }
        guard !profilesNeedingUpdate.isEmpty else { return }

        for profile in connectProfiles {
            profile.isVisible = isVisible
            profile.updatedAt = Date()
        }

        do {
            try context.save()
            store.markIdentityStateChanged()
            if showStatus {
                statusMessage = isVisible
                    ? "Connect discovery is visible again."
                    : "Your Connect card is hidden from discovery."
            }
        } catch {
            statusMessage = "Privacy setting saved, but Connect card visibility could not update."
        }
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
                    subtitle: "Feedback and beta help"
                )

                TarotCardContainer {
                    VStack(spacing: 0) {
                        Button(action: submitFeedback) {
                            supportRow(
                                title: "Submit feedback",
                                subtitle: "Send notes with beta debugging context",
                                icon: "paperplane.fill",
                                trailing: "Email"
                            )
                        }
                        .buttonStyle(.plain)

                        divider

                        NavigationLink {
                            TestFlightFeedbackView()
                        } label: {
                            supportRow(
                                title: "How to send TestFlight feedback",
                                subtitle: "Best path for screenshots and device logs",
                                icon: "testtube.2",
                                trailing: nil
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
                subject: "Zodian Beta Feedback",
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
Debug context
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

struct TestFlightFeedbackView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "TestFlight Feedback",
                    subtitle: "The best route when screenshots matter"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 14) {
                        instructionRow("Take a screenshot when something feels off.")
                        instructionRow("Tap the TestFlight feedback prompt if it appears.")
                        instructionRow("Or open TestFlight > Zodian > Send Beta Feedback.")
                        instructionRow("Add what happened, what you expected, and attach screenshots if helpful.")
                    }
                }
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("TestFlight")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private func instructionRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)
                .padding(.top, 3)

            Text(text)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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
                    subtitle: "Today’s Lens entries you kept"
                )

                if savedReadings.isEmpty {
                    TarotCardContainer {
                        Text("Saved Today’s Lens entries will appear here after you save one from Lens.")
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

                    Text(reading.identity ?? reading.theme)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(2)

                    Text(reading.insight ?? reading.summary)
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
                        Text(reading.identity ?? reading.theme)
                            .font(ZD.Font.title())
                            .foregroundStyle(ZD.Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

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
        Zodian Today’s Lens
        \(reading.createdAt.formatted(date: .abbreviated, time: .omitted))

        \(reading.identity ?? reading.theme)

        \(body)
        """
    }
}
