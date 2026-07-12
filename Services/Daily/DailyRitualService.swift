import Foundation

private struct StructuredDailyRead {
    let intro: String
    let pullQuote: String
    let deeperRead: String
    let watchFor: String
    let move: String
    let ritualText: String
    let actionText: String
    let source: DailyRitualSource
}

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
            return "The Supabase ritual endpoint URL could not be built"
        case .invalidResponse:
            return "The ritual response could not be decoded"
        case let .unexpectedStatusCode(code):
            return "The ritual request failed with status code \(code)"
        }
    }
}

final class DailyRitualService {
    static let shared = DailyRitualService()

    private static let cacheNamespace = "daily-ritual-v5"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let defaults: UserDefaults
    private let retryPolicy: NetworkRetryPolicy
    private let cacheStore = DailyRitualCacheStore.shared
    private var inMemoryCache: [String: DailyRitualResponse] = [:]

    private init(
        session: URLSession = .shared,
        defaults: UserDefaults = .standard,
        retryPolicy: NetworkRetryPolicy = .standard
    ) {
        self.session = session
        self.defaults = defaults
        self.retryPolicy = retryPolicy

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    enum FetchOutcome {
        case ready(DailyRitualResponse)
        case notReady
        case failed(String)
    }

    func fetchDailyRitual(westernSign: String, easternSign: String) async -> FetchOutcome {
        let ritualDate = Self.localDateString(Date())
        let cacheKey = cacheKey(for: ritualDate, westernSign: westernSign, easternSign: easternSign)

        let request: URLRequest
        do {
            request = try buildRequest(
                westernSign: westernSign,
                easternSign: easternSign
            )
        } catch {
            log("fetch failed before request: \(error.localizedDescription)")
            return .failed(error.localizedDescription)
        }

        log("fetch started")

        for attempt in 0...retryPolicy.maximumRetryCount {
            if let delay = retryPolicy.delayNanoseconds(beforeRetry: attempt) {
                log("retry attempt \(attempt)")
                try? await Task.sleep(nanoseconds: delay)
            }

            let outcome = await fetchOnce(request: request, cacheKey: cacheKey)
            switch outcome {
            case .ready(let ritual):
                saveCachedRitual(ritual, cacheKey: cacheKey)
                log("fetch succeeded with structured fields")
                return .ready(ritual)
            case .notReady:
                log("incomplete response detected")
                return .notReady
            case .failed:
                log("fetch failed")
            }
        }

        if let cached = loadCachedRitual(for: cacheKey) {
            log("cached read used after retries")
            return .ready(cached)
        }

        return .notReady
    }

    func preloadDailyRitual(westernSign: String, easternSign: String) async {
        _ = await fetchDailyRitual(westernSign: westernSign, easternSign: easternSign)
    }

    private func fetchOnce(request: URLRequest, cacheKey: String) async -> FetchOutcome {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failed(DailyRitualServiceError.invalidResponse.localizedDescription)
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let ritual = try decodeRitual(from: data)
                    if ritual.isReadyForDisplay {
                        return .ready(ritual)
                    }

                    log("incomplete response")
                    return .notReady
                } catch {
                    log("decode failed")
                    return .failed(DailyRitualServiceError.invalidResponse.localizedDescription)
                }
            case 404:
                log("404 not ready")
                return .notReady
            default:
                log("unexpected status \(httpResponse.statusCode)")
                if retryPolicy.shouldRetry(statusCode: httpResponse.statusCode) {
                    return .failed(DailyRitualServiceError.unexpectedStatusCode(httpResponse.statusCode).localizedDescription)
                }
                return .failed(DailyRitualServiceError.unexpectedStatusCode(httpResponse.statusCode).localizedDescription)
            }
        } catch {
            OperationalLogger.error(
                OperationalError(
                    kind: retryPolicy.shouldRetry(error: error) ? .network : .unknown,
                    category: .content,
                    code: "daily_read_request_failed",
                    underlyingError: error
                )
            )
            return .failed(error.localizedDescription)
        }
    }

    private func buildRequest(westernSign: String, easternSign: String) throws -> URLRequest {
        guard
            let endpointURL = AppConfiguration.supabaseURL,
            let anonKey = AppConfiguration.supabaseAnonKey
        else {
            throw DailyRitualServiceError.missingConfiguration
        }

        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw DailyRitualServiceError.invalidEndpoint
        }

        let trimmedPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = "/\(trimmedPath)/functions/v1/get-daily-ritual"
            .replacingOccurrences(of: "//", with: "/")
        components.queryItems = [
            URLQueryItem(name: "ritual_date", value: Self.localDateString(Date())),
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

    private func cacheKey(for ritualDate: String, westernSign: String, easternSign: String) -> String {
        [
            Self.cacheNamespace,
            ritualDate,
            westernSign.lowercased(),
            easternSign.lowercased()
        ].joined(separator: ".")
    }

    private func loadCachedRitual(for key: String) -> DailyRitualResponse? {
        if let cached = inMemoryCache[key], cached.source != .localFallback, cached.isReadyForDisplay {
            return cached
        }

        if let ritual = cacheStore.load(for: key) {
            inMemoryCache[key] = ritual
            return ritual
        }

        defaults.removeObject(forKey: key)
        inMemoryCache.removeValue(forKey: key)
        return nil
    }

    private func saveCachedRitual(_ ritual: DailyRitualResponse, cacheKey: String) {
        guard ritual.source != .localFallback, ritual.isReadyForDisplay else { return }
        inMemoryCache[cacheKey] = ritual
        cacheStore.save(ritual, for: cacheKey)
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
            let structuredRead = structuredRead(from: payloadDictionary)
        else {
            throw DailyRitualServiceError.invalidResponse
        }

        let westernSign = normalizedString(payloadDictionary["western_sign"])
        let easternSign = normalizedString(payloadDictionary["eastern_sign"])

        return DailyRitualResponse(
            id: normalizedString(payloadDictionary["id"]),
            ritualDate: normalizedString(payloadDictionary["ritual_date"]),
            westernSign: westernSign,
            easternSign: easternSign,
            title: title.removingSignPairPrefix(westernSign: westernSign, easternSign: easternSign),
            intro: structuredRead.intro,
            pullQuote: structuredRead.pullQuote,
            deeperRead: structuredRead.deeperRead,
            watchFor: structuredRead.watchFor,
            move: structuredRead.move,
            ritualText: structuredRead.ritualText,
            actionText: structuredRead.actionText,
            createdAt: normalizedString(payloadDictionary["created_at"]),
            source: structuredRead.source,
            patternIntelligence: patternIntelligenceMetadata(from: payloadDictionary)
        )
    }

    private func normalizedString(_ value: Any?) -> String? {
        guard let string = value as? String else { return nil }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func normalizedDouble(_ value: Any?) -> Double? {
        switch value {
        case let double as Double:
            return double.isFinite ? double : nil
        case let int as Int:
            return Double(int)
        case let number as NSNumber:
            return number.doubleValue.isFinite ? number.doubleValue : nil
        case let string as String:
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value = Double(trimmed), value.isFinite else { return nil }
            return value
        default:
            return nil
        }
    }

    private func normalizedStringArray(_ value: Any?) -> [String] {
        if let strings = value as? [String] {
            return strings.compactMap { normalizedString($0) }
        }

        if let values = value as? [Any] {
            return values.compactMap { normalizedString($0) }
        }

        if let string = normalizedString(value) {
            return string
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return []
    }

    private func patternIntelligenceMetadata(from payloadDictionary: [String: Any]) -> DailyReadPatternIntelligenceMetadata? {
        let nested = payloadDictionary["pattern_intelligence"] as? [String: Any]
        let source = nested ?? payloadDictionary
        let metadata = DailyReadPatternIntelligenceMetadata(
            confidence: normalizedDouble(source["confidence"]),
            reflection: normalizedDouble(source["reflection"]),
            connection: normalizedDouble(source["connection"]),
            growth: normalizedDouble(source["growth"]),
            momentum: normalizedDouble(source["momentum"]),
            primarySignal: normalizedString(source["primary_signal"]),
            secondarySignal: normalizedString(source["secondary_signal"]),
            emotionalTone: normalizedString(source["emotional_tone"]),
            themeTags: normalizedStringArray(source["theme_tags"])
        )

        return metadata.hasAnyValue ? metadata : nil
    }

    private func structuredRead(from payloadDictionary: [String: Any]) -> StructuredDailyRead? {
        let legacyText = normalizedString(payloadDictionary["ritual_text"])
        let legacyAction = normalizedString(payloadDictionary["action_text"])
        let sentences = splitSentences(from: legacyText ?? "")
        let hasStructuredRow = [
            normalizedString(payloadDictionary["intro"]),
            normalizedString(payloadDictionary["pull_quote"]),
            normalizedString(payloadDictionary["deeper_read"]),
            normalizedString(payloadDictionary["watch_for"]),
            normalizedString(payloadDictionary["move"])
        ].contains { $0 != nil }

        guard
            let title = normalizedString(payloadDictionary["title"]),
            let intro = normalizedString(payloadDictionary["intro"]) ?? sentences.first ?? legacyText
        else {
            return nil
        }

        let move = normalizedString(payloadDictionary["move"]) ?? legacyAction ?? ""
        let pullQuote = normalizedString(payloadDictionary["pull_quote"])
            ?? meaningful(sentences.dropFirst().first, comparedTo: [title, intro])
            ?? ""
        let legacyDeeperRead = Array(sentences.dropFirst(2)).joined(separator: " ")
        let deeperRead = normalizedString(payloadDictionary["deeper_read"])
            ?? meaningful(legacyDeeperRead, comparedTo: [title, intro, pullQuote])
            ?? ""
        let watchFor = normalizedString(payloadDictionary["watch_for"]) ?? ""

        let ritualText = legacyText ?? [intro, pullQuote, deeperRead]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: " ")
        let actionText = legacyAction ?? move
        let source: DailyRitualSource = title.isDailyReadUnavailableTitle ? .notReadyFallback : (hasStructuredRow ? .structuredSupabaseRow : .legacySupabaseRow)

        return StructuredDailyRead(
            intro: intro,
            pullQuote: pullQuote,
            deeperRead: deeperRead,
            watchFor: watchFor,
            move: move,
            ritualText: ritualText,
            actionText: actionText,
            source: source
        )
    }

    private func meaningful(_ value: String?, comparedTo nearbyValues: [String]) -> String? {
        guard let value = value?.nilIfBlank else { return nil }
        let fingerprint = value.dailyReadFingerprint
        guard !nearbyValues.contains(where: { $0.dailyReadFingerprint == fingerprint }) else {
            return nil
        }

        return value
    }

    private func splitSentences(from text: String) -> [String] {
        let trimmed = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        guard !trimmed.isEmpty else { return [] }

        let sentenceEndings = CharacterSet(charactersIn: ".!?")
        let sentences = trimmed
            .components(separatedBy: sentenceEndings)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { sentence -> String in
                guard let range = trimmed.range(of: sentence),
                      let nextCharacter = trimmed[range.upperBound...].first,
                      ".!?".contains(nextCharacter) else {
                    return sentence
                }

                return "\(sentence)\(nextCharacter)"
            }

        return sentences.isEmpty ? [trimmed] : sentences
    }

    private static func localDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func log(_ message: String) {
        OperationalLogger.debug(message, category: .content)
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var trimmedAndCollapsed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var dailyReadFingerprint: String {
        trimmedAndCollapsed
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
    }

    var isDailyReadUnavailableTitle: Bool {
        let normalized = dailyReadFingerprint
        return normalized == "not ready yet" || normalized == "your read is still forming"
    }

    func removingSignPairPrefix(westernSign: String?, easternSign: String?) -> String {
        guard let westernSign, let easternSign else {
            return self
        }

        let escapedWestern = NSRegularExpression.escapedPattern(for: westernSign)
        let escapedEastern = NSRegularExpression.escapedPattern(for: easternSign)
        let pattern = #"^\s*\#(escapedWestern)\s*[x×]\s*\#(escapedEastern)\s*:?\s*"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return self
        }

        let range = NSRange(startIndex..<endIndex, in: self)
        let cleaned = regex.stringByReplacingMatches(in: self, range: range, withTemplate: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned.isEmpty ? self : cleaned
    }
}
