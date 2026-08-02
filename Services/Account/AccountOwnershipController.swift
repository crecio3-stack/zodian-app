import AuthenticationServices
import Combine
import CryptoKit
import Foundation
import Supabase

nonisolated struct AccountAuthSession: Equatable, Sendable {
    let userID: UUID
    let expiresAt: Date
    let isAnonymous: Bool
    let linkedProviders: Set<String>
    let accessToken: String
}

nonisolated protocol AccountAuthClient: Sendable {
    var hasStoredSession: Bool { get }

    func validSession() async throws -> AccountAuthSession
    func signInAnonymously(metadata: [String: AnyJSON]) async throws -> AccountAuthSession
    func linkedProviders() async throws -> Set<String>
    func linkApple(idToken: String, nonce: String) async throws -> AccountAuthSession
}

nonisolated struct SupabaseAccountAuthClient: AccountAuthClient {
    let client: SupabaseClient

    var hasStoredSession: Bool {
        client.auth.currentSession != nil
    }

    func validSession() async throws -> AccountAuthSession {
        let session = try await client.auth.session
        return Self.map(session)
    }

    func signInAnonymously(metadata: [String: AnyJSON]) async throws -> AccountAuthSession {
        let session = try await client.auth.signInAnonymously(data: metadata)
        return Self.map(session)
    }

    func linkedProviders() async throws -> Set<String> {
        Set(try await client.auth.userIdentities().map(\.provider))
    }

    func linkApple(idToken: String, nonce: String) async throws -> AccountAuthSession {
        let session = try await client.auth.linkIdentityWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
        return Self.map(session)
    }

    private static func map(_ session: Session) -> AccountAuthSession {
        AccountAuthSession(
            userID: session.user.id,
            expiresAt: Date(timeIntervalSince1970: session.expiresAt),
            isAnonymous: session.user.isAnonymous,
            linkedProviders: Set(session.user.identities?.map(\.provider) ?? []),
            accessToken: session.accessToken
        )
    }
}

@MainActor
protocol AccountOwnershipProviding: AnyObject {
    func ensureAcknowledgedAccount() async throws -> AccountID
}

@MainActor
enum AccountBackedPersistenceGate {
    static func perform<Result>(
        ownership: any AccountOwnershipProviding,
        persistence: () throws -> Result
    ) async throws -> Result {
#if DEBUG
        print("[AccountPersistenceGate] Waiting for server Account acknowledgment")
#endif
        _ = try await ownership.ensureAcknowledgedAccount()
#if DEBUG
        print("[AccountPersistenceGate] Account acknowledged; persistence may begin")
#endif
        let result = try persistence()
#if DEBUG
        print("[AccountPersistenceGate] Account-backed persistence completed")
#endif
        return result
    }
}

nonisolated struct AccountSessionSnapshot: Equatable, Sendable {
    let accountID: AccountID
    let installationID: InstallationID
    let deviceRegistrationID: DeviceRegistrationID
    let sessionID: SessionID
    let expiresAt: Date
    let isAnonymous: Bool
    let linkedProviders: Set<String>

    var isAppleLinked: Bool {
        linkedProviders.contains("apple")
    }
}

nonisolated struct AccountOwnershipFailure: Error, Equatable, Sendable {
    nonisolated enum Kind: Equatable, Sendable {
        case configuration
        case bootstrap
        case appleCredential
        case appleLink
        case ownershipInvariant
    }

    let kind: Kind
    let message: String

    var retryTitle: String {
        switch kind {
        case .appleCredential, .appleLink:
            return "Try Apple Again"
        case .configuration, .bootstrap, .ownershipInvariant:
            return "Retry"
        }
    }
}

nonisolated enum AccountOwnershipState: Equatable, Sendable {
    case idle
    case bootstrapping
    case anonymous(AccountSessionSnapshot)
    case linked(AccountSessionSnapshot)
    case failed(AccountOwnershipFailure)

    var snapshot: AccountSessionSnapshot? {
        switch self {
        case .anonymous(let snapshot), .linked(let snapshot):
            return snapshot
        case .idle, .bootstrapping, .failed:
            return nil
        }
    }
}

@MainActor
final class AccountOwnershipController: ObservableObject, AccountOwnershipProviding {
    static let contractVersion = "1.0"

    @Published private(set) var state: AccountOwnershipState = .idle

    let installationIdentity: InstallationIdentity

    private let authClient: (any AccountAuthClient)?
    private let configurationFailure: AccountOwnershipFailure?
    private var bootstrapTask: Task<AccountSessionSnapshot, Error>?
    private var appleNonce: String?

    init(
        bundle: Bundle = .main,
        installationStore: InstallationIdentityStore? = nil
    ) {
        installationIdentity = (installationStore ?? InstallationIdentityStore()).current()

        guard let configuration = AppConfiguration.supabaseConfiguration(bundle: bundle) else {
            authClient = nil
            configurationFailure = AccountOwnershipFailure(
                kind: .configuration,
                message: "Account ownership is temporarily unavailable. Check the app configuration and try again."
            )
            return
        }

        authClient = SupabaseAccountAuthClient(
            client: SupabaseClient(
                supabaseURL: configuration.url,
                supabaseKey: configuration.clientKey
            )
        )
        configurationFailure = nil
    }

    init(
        authClient: any AccountAuthClient,
        installationIdentity: InstallationIdentity
    ) {
        self.authClient = authClient
        self.installationIdentity = installationIdentity
        configurationFailure = nil
    }

    var accountID: AccountID? {
        state.snapshot?.accountID
    }

    var isAppleLinked: Bool {
        state.snapshot?.isAppleLinked == true
    }

    func bootstrapForApplicationLaunch() async {
        do {
            _ = try await ensureAcknowledgedAccount()
        } catch {
            // Launch remains available for existing beta data. New persistent
            // onboarding is still blocked at its explicit ownership gate.
            OperationalLogger.error(
                OperationalError(
                    kind: .authentication,
                    category: .account,
                    code: "launch_bootstrap_failed",
                    underlyingError: error
                )
            )
        }
    }

    @discardableResult
    func retryBootstrap() async -> Bool {
        do {
            _ = try await ensureAcknowledgedAccount()
            return true
        } catch {
            return false
        }
    }

    func ensureAcknowledgedAccount() async throws -> AccountID {
        let snapshot = try await acknowledgedSnapshot()
        return snapshot.accountID
    }

    func feedbackAuthenticationContext() async throws -> DailyLensFeedbackAuthentication {
        guard let authClient else {
            throw configurationFailure ?? AccountOwnershipFailure(
                kind: .configuration,
                message: "Account ownership is unavailable."
            )
        }
        _ = try await acknowledgedSnapshot()
        let session = try await authClient.validSession()
        return DailyLensFeedbackAuthentication(
            userID: session.userID.uuidString.lowercased(),
            installationID: installationIdentity.installationID.rawValue,
            accessToken: session.accessToken
        )
    }

    func prepareAppleLinkRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.makeNonce()
        appleNonce = nonce
        request.requestedScopes = [.email]
        request.nonce = Self.sha256(nonce)
    }

    func completeAppleLink(_ result: Result<ASAuthorization, Error>) async {
        do {
            let authorization = try result.get()
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let token = String(data: tokenData, encoding: .utf8),
                let nonce = appleNonce
            else {
                throw AccountOwnershipFailure(
                    kind: .appleCredential,
                    message: "Apple did not return a usable credential. Please try again."
                )
            }

            appleNonce = nil
            try await linkApple(idToken: token, nonce: nonce)
        } catch let failure as AccountOwnershipFailure {
            state = .failed(failure)
        } catch {
            state = .failed(
                AccountOwnershipFailure(
                    kind: .appleCredential,
                    message: "Apple sign-in could not be completed. Please try again."
                )
            )
        }
    }

    private func acknowledgedSnapshot() async throws -> AccountSessionSnapshot {
        if let snapshot = state.snapshot {
            return snapshot
        }

        if let bootstrapTask {
            return try await bootstrapTask.value
        }

        if let configurationFailure {
            state = .failed(configurationFailure)
            throw configurationFailure
        }

        guard let authClient else {
            let failure = AccountOwnershipFailure(
                kind: .configuration,
                message: "Account ownership is temporarily unavailable. Please try again."
            )
            state = .failed(failure)
            throw failure
        }

        state = .bootstrapping

        let identity = installationIdentity
        let task = Task<AccountSessionSnapshot, Error> {
            let session: AccountAuthSession

            if authClient.hasStoredSession {
                // A stored session is an existing ownership claim. If it cannot
                // be validated, never create a competing anonymous Account.
                session = try await authClient.validSession()
            } else {
                session = try await authClient.signInAnonymously(
                    metadata: [
                        "installation_id": .string(identity.installationID.rawValue),
                        "device_registration_id": .string(identity.deviceRegistrationID.rawValue),
                        "account_contract_version": .string(Self.contractVersion)
                    ]
                )
            }

            return Self.snapshot(from: session, installationIdentity: identity)
        }

        bootstrapTask = task

        do {
            let snapshot = try await task.value
            bootstrapTask = nil
            apply(snapshot)
            return snapshot
        } catch {
            bootstrapTask = nil
            let failure = AccountOwnershipFailure(
                kind: .bootstrap,
                message: "We couldn't secure ownership of your account. Check your connection and try again."
            )
            OperationalLogger.error(
                OperationalError(
                    kind: .authentication,
                    category: .account,
                    code: "anonymous_bootstrap_failed",
                    underlyingError: error
                )
            )
            state = .failed(failure)
            throw failure
        }
    }

    func linkApple(idToken: String, nonce: String) async throws {
        guard let authClient else {
            throw configurationFailure ?? AccountOwnershipFailure(
                kind: .configuration,
                message: "Account ownership is temporarily unavailable. Please try again."
            )
        }

        let before = try await acknowledgedSnapshot()

        let appleAlreadyLinked = before.isAppleLinked
            ? true
            : try await hasAppleIdentity(authClient: authClient)

        if appleAlreadyLinked {
            let refreshed = try await authClient.validSession()
            try applyLinkedSession(refreshed, expectedAccountID: before.accountID)
            return
        }

        do {
            let linkedSession = try await authClient.linkApple(idToken: idToken, nonce: nonce)
            try applyLinkedSession(linkedSession, expectedAccountID: before.accountID)
        } catch let failure as AccountOwnershipFailure
            where failure.kind == .ownershipInvariant {
            throw failure
        } catch {
            // A retry after an interrupted response may find that the server
            // already completed the link. Verify server state before failing.
            if (try? await hasAppleIdentity(authClient: authClient)) == true {
                let refreshed = try await authClient.validSession()
                try applyLinkedSession(refreshed, expectedAccountID: before.accountID)
                return
            }

            throw AccountOwnershipFailure(
                kind: .appleLink,
                message: "Apple could not be linked to this account. Your existing account is unchanged."
            )
        }
    }

    private func hasAppleIdentity(authClient: any AccountAuthClient) async throws -> Bool {
        try await authClient.linkedProviders().contains("apple")
    }

    private func applyLinkedSession(
        _ session: AccountAuthSession,
        expectedAccountID: AccountID
    ) throws {
        let snapshot = Self.snapshot(
            from: session,
            installationIdentity: installationIdentity
        )

        guard snapshot.accountID == expectedAccountID else {
            let failure = AccountOwnershipFailure(
                kind: .ownershipInvariant,
                message: "Account linking was stopped because ownership could not be verified."
            )
            state = .failed(failure)
            throw failure
        }

        state = .linked(snapshot)
    }

    private func apply(_ snapshot: AccountSessionSnapshot) {
        assert(
            snapshot.accountID.rawValue != snapshot.installationID.rawValue
                && snapshot.accountID.rawValue != snapshot.deviceRegistrationID.rawValue
                && snapshot.installationID.rawValue != snapshot.deviceRegistrationID.rawValue,
            "ADR-013 identifier authorities must remain distinct"
        )
        state = snapshot.isAppleLinked ? .linked(snapshot) : .anonymous(snapshot)
        AnalyticsService.shared.identify(accountID: snapshot.accountID)
        OperationalLogger.info(
            "account_acknowledged",
            category: .account,
            metadata: [
                "credential_state": snapshot.isAppleLinked ? "linked" : "anonymous",
                "contract_version": Self.contractVersion
            ]
        )
    }

    private static func snapshot(
        from session: AccountAuthSession,
        installationIdentity: InstallationIdentity
    ) -> AccountSessionSnapshot {
        let sessionFingerprint = SHA256.hash(data: Data(session.accessToken.utf8))
            .prefix(12)
            .map { String(format: "%02x", $0) }
            .joined()

        return AccountSessionSnapshot(
            accountID: AccountID(rawValue: session.userID.uuidString.lowercased()),
            installationID: installationIdentity.installationID,
            deviceRegistrationID: installationIdentity.deviceRegistrationID,
            sessionID: SessionID(rawValue: sessionFingerprint),
            expiresAt: session.expiresAt,
            isAnonymous: session.isAnonymous,
            linkedProviders: session.linkedProviders
        )
    }

    private static func makeNonce() -> String {
        "\(UUID().uuidString)-\(UUID().uuidString)"
    }

    private static func sha256(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
