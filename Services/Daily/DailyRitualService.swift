import Foundation

enum DailyRitualServiceError: LocalizedError {
    case missingConfiguration
    case invalidEndpoint
    case invalidResponse
    case unexpectedStatusCode(Int)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Missing Supabase configuration. Set the Supabase URL and anon key for this app target."
        case .invalidEndpoint:
            return "The Supabase ritual endpoint URL could not be built."
        case .invalidResponse:
            return "The ritual response could not be decoded."
        case let .unexpectedStatusCode(code):
            return "The ritual request failed with status code \(code)."
        }
    }
}

final class DailyRitualService {
    static let shared = DailyRitualService()

    private static let fallbackSupabaseURL = URL(string: "https://xyyahrqfmdblvonnaifi.supabase.co")!

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let defaults: UserDefaults

    private init(
        session: URLSession = .shared,
        defaults: UserDefaults = .standard
    ) {
        self.session = session
        self.defaults = defaults

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder
    }

    func fetchDailyRitual(westernSign: String, easternSign: String) async throws -> DailyRitualResponse? {
        let ritualDate = Self.utcDateString(Date())
        let cacheKey = cacheKey(for: ritualDate, westernSign: westernSign, easternSign: easternSign)

        if let cached = loadCachedRitual(for: cacheKey) {
            return cached
        }

        let request = try buildRequest(
            westernSign: westernSign,
            easternSign: easternSign
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DailyRitualServiceError.invalidResponse
        }

        let responseBody = String(data: data, encoding: .utf8) ?? "<non-utf8 response>"

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let ritual = try decodeRitual(from: data)
                guard !isPlaceholderRitual(ritual) else {
                    return nil
                }
                saveCachedRitual(ritual, cacheKey: cacheKey)
                return ritual
            } catch {
                print("[DailyRitualService] Decode failed. Body:", responseBody)
                throw DailyRitualServiceError.invalidResponse
            }
        case 404:
            return nil
        default:
            print("[DailyRitualService] Unexpected status \(httpResponse.statusCode). Body:", responseBody)
            throw DailyRitualServiceError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }

    func preloadDailyRitual(westernSign: String, easternSign: String) async {
        _ = try? await fetchDailyRitual(westernSign: westernSign, easternSign: easternSign)
    }

    private func buildRequest(westernSign: String, easternSign: String) throws -> URLRequest {
        let baseURLString =
            configuredValue(for: "VITE_SUPABASE_URL")
            ?? configuredValue(for: "SUPABASE_URL")

        let anonKey =
            configuredValue(for: "VITE_SUPABASE_ANON_KEY")
            ?? configuredValue(for: "SUPABASE_ANON_KEY")
            ?? configuredValue(for: "PUBLIC_SUPABASE_ANON_KEY")
            ?? configuredValue(for: "EXPO_PUBLIC_SUPABASE_ANON_KEY")

        guard let baseURLString, let anonKey else {
            throw DailyRitualServiceError.missingConfiguration
        }

        let endpointURL = URL(string: baseURLString) ?? Self.fallbackSupabaseURL

        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw DailyRitualServiceError.invalidEndpoint
        }

        let trimmedPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = "/\(trimmedPath)/functions/v1/get-daily-ritual"
            .replacingOccurrences(of: "//", with: "/")
        components.queryItems = [
            URLQueryItem(name: "western_sign", value: westernSign),
            URLQueryItem(name: "eastern_sign", value: easternSign)
        ]

        guard let url = components.url else {
            throw DailyRitualServiceError.invalidEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if !anonKey.isEmpty {
            request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(anonKey, forHTTPHeaderField: "apikey")
        }

        return request
    }

    private func configuredValue(for key: String) -> String? {
        let envValue = ProcessInfo.processInfo.environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let envValue, !envValue.isEmpty {
            return envValue
        }

        if let bundleValue = Bundle.main.object(forInfoDictionaryKey: key) as? String {
            let trimmed = bundleValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        return nil
    }

    private func cacheKey(for ritualDate: String, westernSign: String, easternSign: String) -> String {
        [
            "daily-ritual",
            ritualDate,
            westernSign.lowercased(),
            easternSign.lowercased()
        ].joined(separator: ".")
    }

    private func loadCachedRitual(for key: String) -> DailyRitualResponse? {
        guard let data = defaults.data(forKey: key) else { return nil }
        guard let ritual = try? decoder.decode(DailyRitualResponse.self, from: data) else {
            return nil
        }

        if isPlaceholderRitual(ritual) {
            defaults.removeObject(forKey: key)
            return nil
        }

        return ritual
    }

    private func saveCachedRitual(_ ritual: DailyRitualResponse, cacheKey: String) {
        guard !isPlaceholderRitual(ritual) else { return }
        guard let data = try? encoder.encode(ritual) else { return }
        defaults.set(data, forKey: cacheKey)
    }

    private func decodeRitual(from data: Data) throws -> DailyRitualResponse {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = jsonObject as? [String: Any]
        else {
            throw DailyRitualServiceError.invalidResponse
        }

        let payloadDictionary =
            (dictionary["data"] as? [String: Any])
            ?? (dictionary["ritual"] as? [String: Any])
            ?? (dictionary["result"] as? [String: Any])
            ?? dictionary

        guard
            let title = normalizedString(payloadDictionary["title"]),
            let ritualText = normalizedString(payloadDictionary["ritual_text"]),
            let actionText = normalizedString(payloadDictionary["action_text"])
        else {
            throw DailyRitualServiceError.invalidResponse
        }

        return DailyRitualResponse(
            id: normalizedString(payloadDictionary["id"]),
            ritualDate: normalizedString(payloadDictionary["ritual_date"]),
            westernSign: normalizedString(payloadDictionary["western_sign"]),
            easternSign: normalizedString(payloadDictionary["eastern_sign"]),
            title: title,
            ritualText: ritualText,
            actionText: actionText,
            createdAt: normalizedString(payloadDictionary["created_at"])
        )
    }

    private func normalizedString(_ value: Any?) -> String? {
        guard let string = value as? String else { return nil }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func isPlaceholderRitual(_ ritual: DailyRitualResponse) -> Bool {
        ritual.title.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare("Not ready yet") == .orderedSame
    }

    private static func utcDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
