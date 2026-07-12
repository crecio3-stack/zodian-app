#if DEBUG
import Foundation
import Supabase

@MainActor
enum Sprint1AccountValidationHarness {
    private struct HarnessFailure: Error {
        let message: String
    }

    private struct ForcedFailure: Error {}

    static func run() async {
        let checks: [(String, () async throws -> Void)] = [
            ("anonymous bootstrap success", testAnonymousBootstrapSuccess),
            ("anonymous bootstrap failure and retry", testBootstrapFailureAndRetry),
            ("persistence blocked before acknowledgment", testPersistenceGate),
            ("identifier authority and reinstall lifecycle", testIdentifierAuthority),
            ("Apple link preserves Account ID", testAppleLinkPreservesAccountID),
            ("Apple link retry does not duplicate Account", testAppleLinkRetry),
            ("Apple provider unavailable failure", testAppleProviderUnavailable)
        ]

        var failures: [String] = []

        print("[Sprint1Validation] BEGIN")
        for (name, check) in checks {
            do {
                try await check()
                print("[Sprint1Validation] PASS: \(name)")
            } catch {
                failures.append("\(name): \(error)")
                print("[Sprint1Validation] FAIL: \(name) — \(error)")
            }
        }

        if failures.isEmpty {
            print("[Sprint1Validation] RESULT: PASS (\(checks.count)/\(checks.count))")
        } else {
            print("[Sprint1Validation] RESULT: FAIL (\(checks.count - failures.count)/\(checks.count))")
            assertionFailure(failures.joined(separator: "\n"))
        }
    }

    private static func testAnonymousBootstrapSuccess() async throws {
        let accountUUID = UUID()
        let auth = DebugAccountAuthClient(
            anonymousResults: [.success(session(userID: accountUUID))]
        )
        let controller = AccountOwnershipController(
            authClient: auth,
            installationIdentity: installationIdentity()
        )

        let accountID = try await controller.ensureAcknowledgedAccount()
        let snapshot = try requireValue(controller.state.snapshot, "Session snapshot was missing")

        try require(accountID.rawValue == accountUUID.uuidString.lowercased(), "Server user ID was not used")
        try require(accountID.rawValue != snapshot.installationID.rawValue, "Installation ID became Account ID")
        try require(accountID.rawValue != snapshot.deviceRegistrationID.rawValue, "Device Registration ID became Account ID")
        try require(auth.anonymousCallCount == 1, "Anonymous bootstrap should occur exactly once")
        try require(controller.state.snapshot?.isAnonymous == true, "Session should remain anonymous")
    }

    private static func testBootstrapFailureAndRetry() async throws {
        let accountUUID = UUID()
        let auth = DebugAccountAuthClient(
            anonymousResults: [
                .failure(ForcedFailure()),
                .success(session(userID: accountUUID))
            ]
        )
        let controller = AccountOwnershipController(
            authClient: auth,
            installationIdentity: installationIdentity()
        )

        do {
            _ = try await controller.ensureAcknowledgedAccount()
            throw HarnessFailure(message: "Initial bootstrap unexpectedly succeeded")
        } catch let failure as AccountOwnershipFailure {
            try require(failure.kind == .bootstrap, "Failure was not classified as bootstrap")
        }

        let recovered = await controller.retryBootstrap()
        try require(recovered, "Retry did not recover")
        try require(auth.anonymousCallCount == 2, "Retry did not make exactly one new bootstrap request")
        try require(controller.accountID?.rawValue == accountUUID.uuidString.lowercased(), "Retry changed authority")
    }

    private static func testPersistenceGate() async throws {
        let ownership = DebugOwnershipProvider(result: .failure(ForcedFailure()))
        var didPersist = false

        do {
            try await AccountBackedPersistenceGate.perform(ownership: ownership) {
                didPersist = true
            }
            throw HarnessFailure(message: "Persistence gate unexpectedly succeeded")
        } catch is ForcedFailure {
            // Expected.
        }

        try require(!didPersist, "Persistence executed before server acknowledgment")
    }

    private static func testIdentifierAuthority() throws {
        let suiteName = "Sprint1AccountValidationHarness.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            throw HarnessFailure(message: "Could not create isolated defaults")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let first = InstallationIdentityStore(defaults: defaults).current()
        let repeated = InstallationIdentityStore(defaults: defaults).current()

        try require(first == repeated, "Identifiers changed within one installation")
        try require(
            first.installationID.rawValue != first.deviceRegistrationID.rawValue,
            "Installation and Device Registration IDs collided"
        )

        defaults.removePersistentDomain(forName: suiteName)
        let afterReinstall = InstallationIdentityStore(defaults: defaults).current()

        try require(
            first.installationID != afterReinstall.installationID,
            "Installation ID survived simulated reinstall"
        )
        try require(
            first.deviceRegistrationID != afterReinstall.deviceRegistrationID,
            "Device Registration ID survived simulated reinstall"
        )
    }

    private static func testAppleLinkPreservesAccountID() async throws {
        let accountUUID = UUID()
        let anonymous = session(userID: accountUUID)
        let linked = session(userID: accountUUID, isAnonymous: false, providers: ["apple"])
        let auth = DebugAccountAuthClient(
            anonymousResults: [.success(anonymous)],
            appleLinkResults: [.success(linked)]
        )
        let controller = AccountOwnershipController(
            authClient: auth,
            installationIdentity: installationIdentity()
        )

        let before = try await controller.ensureAcknowledgedAccount()
        try await controller.linkApple(idToken: "debug-token", nonce: "debug-nonce")
        let after = try requireValue(controller.accountID, "Linked Account ID was missing")

        try require(before == after, "Apple link changed Account ID")
        try require(controller.isAppleLinked, "Apple provider was not reflected in session state")
        try require(auth.anonymousCallCount == 1, "Apple link created another anonymous Account")
    }

    private static func testAppleLinkRetry() async throws {
        let accountUUID = UUID()
        let linked = session(userID: accountUUID, isAnonymous: false, providers: ["apple"])
        let auth = DebugAccountAuthClient(
            anonymousResults: [.success(session(userID: accountUUID))],
            appleLinkResults: [.success(linked)]
        )
        let controller = AccountOwnershipController(
            authClient: auth,
            installationIdentity: installationIdentity()
        )

        _ = try await controller.ensureAcknowledgedAccount()
        try await controller.linkApple(idToken: "debug-token", nonce: "debug-nonce")
        try await controller.linkApple(idToken: "debug-token", nonce: "debug-nonce")

        try require(auth.appleLinkCallCount == 1, "Retry issued a duplicate provider link")
        try require(auth.anonymousCallCount == 1, "Retry created a duplicate Account")
        try require(controller.accountID?.rawValue == accountUUID.uuidString.lowercased(), "Retry changed Account ID")
    }

    private static func testAppleProviderUnavailable() async throws {
        let accountUUID = UUID()
        let auth = DebugAccountAuthClient(
            anonymousResults: [.success(session(userID: accountUUID))],
            appleLinkResults: [.failure(ForcedFailure())],
            providerResults: [
                .success([]),
                .failure(ForcedFailure())
            ]
        )
        let controller = AccountOwnershipController(
            authClient: auth,
            installationIdentity: installationIdentity()
        )

        let before = try await controller.ensureAcknowledgedAccount()

        do {
            try await controller.linkApple(idToken: "debug-token", nonce: "debug-nonce")
            throw HarnessFailure(message: "Unavailable Apple provider unexpectedly linked")
        } catch let failure as AccountOwnershipFailure {
            try require(failure.kind == .appleLink, "Provider failure was not classified as Apple link")
        }

        try require(controller.accountID == before, "Provider failure changed Account ID")
        try require(auth.anonymousCallCount == 1, "Provider failure created another Account")
    }

    private static func session(
        userID: UUID,
        isAnonymous: Bool = true,
        providers: Set<String> = []
    ) -> AccountAuthSession {
        AccountAuthSession(
            userID: userID,
            expiresAt: Date().addingTimeInterval(3_600),
            isAnonymous: isAnonymous,
            linkedProviders: providers,
            accessToken: "debug-access-\(userID.uuidString)"
        )
    }

    private static func installationIdentity() -> InstallationIdentity {
        InstallationIdentity(
            installationID: InstallationID(rawValue: UUID().uuidString.lowercased()),
            deviceRegistrationID: DeviceRegistrationID(rawValue: UUID().uuidString.lowercased())
        )
    }

    private static func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
        guard condition() else {
            throw HarnessFailure(message: message)
        }
    }

    private static func requireValue<Value>(_ value: Value?, _ message: String) throws -> Value {
        guard let value else {
            throw HarnessFailure(message: message)
        }
        return value
    }
}

nonisolated private final class DebugAccountAuthClient: @unchecked Sendable, AccountAuthClient {
    private let lock = NSLock()
    private var storedSession: AccountAuthSession?
    private var anonymousResults: [Result<AccountAuthSession, Error>]
    private var appleLinkResults: [Result<AccountAuthSession, Error>]
    private var providerResults: [Result<Set<String>, Error>]
    private var _anonymousCallCount = 0
    private var _appleLinkCallCount = 0

    init(
        anonymousResults: [Result<AccountAuthSession, Error>] = [],
        appleLinkResults: [Result<AccountAuthSession, Error>] = [],
        providerResults: [Result<Set<String>, Error>] = []
    ) {
        self.anonymousResults = anonymousResults
        self.appleLinkResults = appleLinkResults
        self.providerResults = providerResults
    }

    var hasStoredSession: Bool {
        lock.withLock { storedSession != nil }
    }

    var anonymousCallCount: Int {
        lock.withLock { _anonymousCallCount }
    }

    var appleLinkCallCount: Int {
        lock.withLock { _appleLinkCallCount }
    }

    func validSession() async throws -> AccountAuthSession {
        try lock.withLock {
            guard let storedSession else { throw ForcedDebugFailure() }
            return storedSession
        }
    }

    func signInAnonymously(metadata: [String: AnyJSON]) async throws -> AccountAuthSession {
        _ = metadata
        return try lock.withLock {
            _anonymousCallCount += 1
            let result = anonymousResults.isEmpty
                ? Result<AccountAuthSession, Error>.failure(ForcedDebugFailure())
                : anonymousResults.removeFirst()
            let session = try result.get()
            storedSession = session
            return session
        }
    }

    func linkedProviders() async throws -> Set<String> {
        try lock.withLock {
            if !providerResults.isEmpty {
                return try providerResults.removeFirst().get()
            }
            return storedSession?.linkedProviders ?? []
        }
    }

    func linkApple(idToken: String, nonce: String) async throws -> AccountAuthSession {
        _ = idToken
        _ = nonce
        return try lock.withLock {
            _appleLinkCallCount += 1
            let result = appleLinkResults.isEmpty
                ? Result<AccountAuthSession, Error>.failure(ForcedDebugFailure())
                : appleLinkResults.removeFirst()
            let session = try result.get()
            storedSession = session
            return session
        }
    }

    private struct ForcedDebugFailure: Error {}
}

@MainActor
private final class DebugOwnershipProvider: AccountOwnershipProviding {
    let result: Result<AccountID, Error>

    init(result: Result<AccountID, Error>) {
        self.result = result
    }

    func ensureAcknowledgedAccount() async throws -> AccountID {
        try result.get()
    }
}
#endif
