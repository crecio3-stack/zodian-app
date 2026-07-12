import Foundation
import Security

final class DailyRitualCacheStore {
    static let shared = DailyRitualCacheStore()

    private let defaults: UserDefaults
    private let keychainService = "com.zodian.daily-ritual-cache"

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(for key: String) -> DailyRitualResponse? {
        if let keychainData = loadDataFromKeychain(for: key),
           let ritual = decodeRitual(from: keychainData) {
            return ritual
        }

        guard let defaultsData = defaults.data(forKey: key) else {
            return nil
        }

        guard let ritual = decodeRitual(from: defaultsData) else {
            defaults.removeObject(forKey: key)
            deleteFromKeychain(for: key)
            return nil
        }

        saveToKeychain(defaultsData, for: key)
        return ritual
    }

    func save(_ ritual: DailyRitualResponse, for key: String) {
        guard ritual.source != .localFallback, ritual.isReadyForDisplay else { return }
        guard let data = try? JSONEncoder().encode(ritual) else { return }

        defaults.set(data, forKey: key)
        saveToKeychain(data, for: key)
    }

    func remove(for key: String) {
        defaults.removeObject(forKey: key)
        deleteFromKeychain(for: key)
    }

    private func decodeRitual(from data: Data) -> DailyRitualResponse? {
        guard let ritual = try? JSONDecoder().decode(DailyRitualResponse.self, from: data),
              ritual.source != .localFallback,
              ritual.isReadyForDisplay else {
            return nil
        }

        return ritual
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
