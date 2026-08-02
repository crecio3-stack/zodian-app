import Foundation
import Security

/// Versioned cache envelope for the canonical title/read runtime contract.
/// `legacyResponse` is retained only for read-only archive migration. New
/// Beta/Release records store title/read plus non-content diagnostics.
struct TodaysLensRuntimeCacheRecord: Codable, Equatable {
    static let currentSchemaVersion = 2

    let schemaVersion: Int
    let content: TodaysLensRuntimeContent
    let metadata: TodaysLensRuntimeMetadata?
    let legacyResponse: DailyRitualResponse?

    init(
        content: TodaysLensRuntimeContent,
        metadata: TodaysLensRuntimeMetadata? = nil,
        legacyResponse: DailyRitualResponse? = nil,
        schemaVersion: Int = currentSchemaVersion
    ) {
        self.schemaVersion = schemaVersion
        self.content = content
        self.metadata = metadata
        self.legacyResponse = legacyResponse
    }
}

final class DailyRitualCacheStore {
    static let shared = DailyRitualCacheStore()

    private let defaults: UserDefaults
    private let keychainService = "com.zodian.daily-ritual-cache"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Compatibility API for the existing six-field runtime.
    func load(for key: String) -> DailyRitualResponse? {
        if let keychainData = loadDataFromKeychain(for: key),
           let record = Self.decodeRuntimeRecord(from: keychainData) {
            migrateIfNeeded(record, originalData: keychainData, for: key)
            return record.legacyResponse
        }

        guard let defaultsData = defaults.data(forKey: key) else {
            return nil
        }

        guard let record = Self.decodeRuntimeRecord(from: defaultsData) else {
            defaults.removeObject(forKey: key)
            deleteFromKeychain(for: key)
            return nil
        }

        let migratedData = Self.encode(record) ?? defaultsData
        defaults.set(migratedData, forKey: key)
        saveToKeychain(migratedData, for: key)
        return record.legacyResponse
    }

    func save(_ ritual: DailyRitualResponse, for key: String) {
        guard ritual.source != .localFallback, ritual.isReadyForDisplay else { return }
        save(
            TodaysLensRuntimeCacheRecord(
                content: LegacyDailyRitualAdapter.runtimeContent(from: ritual),
                legacyResponse: ritual
            ),
            for: key
        )
    }

    /// Canonical cache API. It can restore both new title/read envelopes and
    /// old raw `DailyRitualResponse` cache entries.
    func loadRuntimeContent(for key: String) -> TodaysLensRuntimeContent? {
        loadRuntimeRecord(for: key)?.content
    }

    func loadRuntimeRecord(for key: String) -> TodaysLensRuntimeCacheRecord? {
        if let keychainData = loadDataFromKeychain(for: key),
           let record = Self.decodeRuntimeRecord(from: keychainData) {
            migrateIfNeeded(record, originalData: keychainData, for: key)
            return record
        }

        guard let defaultsData = defaults.data(forKey: key),
              let record = Self.decodeRuntimeRecord(from: defaultsData) else {
            return nil
        }

        let migratedData = Self.encode(record) ?? defaultsData
        defaults.set(migratedData, forKey: key)
        saveToKeychain(migratedData, for: key)
        return record
    }

    func saveRuntimeContent(
        _ content: TodaysLensRuntimeContent,
        metadata: TodaysLensRuntimeMetadata? = nil,
        legacyResponse: DailyRitualResponse? = nil,
        for key: String
    ) {
        guard content.isReadyForDisplay else { return }
        save(
            TodaysLensRuntimeCacheRecord(
                content: content,
                metadata: metadata,
                legacyResponse: legacyResponse
            ),
            for: key
        )
    }

    private func save(_ record: TodaysLensRuntimeCacheRecord, for key: String) {
        guard let data = Self.encode(record) else { return }

        defaults.set(data, forKey: key)
        saveToKeychain(data, for: key)
    }

    func remove(for key: String) {
        defaults.removeObject(forKey: key)
        deleteFromKeychain(for: key)
    }

    /// Removes only Today’s Lens cache entries. It never touches user profiles,
    /// saved reads, points, streaks, or any other persisted application state.
    func removeAllDailyLensEntries() {
        let cachePrefixes = ["daily-ritual-v5.", "daily-ritual.last-good."]
        for key in defaults.dictionaryRepresentation().keys where cachePrefixes.contains(where: key.hasPrefix) {
            defaults.removeObject(forKey: key)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func encode(_ record: TodaysLensRuntimeCacheRecord) -> Data? {
        try? JSONEncoder().encode(record)
    }

    static func decodeRuntimeRecord(from data: Data) -> TodaysLensRuntimeCacheRecord? {
        if let record = try? JSONDecoder().decode(TodaysLensRuntimeCacheRecord.self, from: data),
           [1, TodaysLensRuntimeCacheRecord.currentSchemaVersion].contains(record.schemaVersion),
           record.content.isReadyForDisplay {
            return TodaysLensRuntimeCacheRecord(
                content: record.content,
                metadata: record.metadata,
                legacyResponse: record.legacyResponse
            )
        }

        // Transparent migration for caches written before the title/read
        // envelope existed.
        if let ritual = try? JSONDecoder().decode(DailyRitualResponse.self, from: data),
           ritual.source != .localFallback,
           ritual.isReadyForDisplay {
            return TodaysLensRuntimeCacheRecord(
                content: LegacyDailyRitualAdapter.runtimeContent(from: ritual),
                legacyResponse: ritual
            )
        }

        return nil
    }

    private func migrateIfNeeded(
        _ record: TodaysLensRuntimeCacheRecord,
        originalData: Data,
        for key: String
    ) {
        guard (try? JSONDecoder().decode(TodaysLensRuntimeCacheRecord.self, from: originalData)) == nil,
              let migratedData = Self.encode(record) else {
            return
        }
        defaults.set(migratedData, forKey: key)
        saveToKeychain(migratedData, for: key)
    }

    private func saveToKeychain(_ data: Data, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let insertQuery = query.merging(attributes, uniquingKeysWith: { _, new in new })
        let status = SecItemAdd(insertQuery as CFDictionary, nil)

        if status == errSecDuplicateItem {
            SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        }
    }

    private func loadDataFromKeychain(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            return nil
        }

        return result as? Data
    }

    private func deleteFromKeychain(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
