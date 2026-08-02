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

enum DailyRitualRequestScope: String, Equatable {
    case selfRead = "self"
    case savedPerson = "saved-person"
}

enum DailyRitualFetchOrigin: String, Equatable {
    case network
    case deviceCache = "device-cache"
}

enum DailyRitualFreshness: String, Equatable {
    case exact
    case staleFallback = "stale-fallback"
}

struct DailyRitualFetchMetadata: Equatable {
    let requestedDate: String
    let returnedDate: String
    let freshness: DailyRitualFreshness
    let origin: DailyRitualFetchOrigin
    let requestScope: DailyRitualRequestScope
    let batchID: String?
    let endpointStatus: Int?
    let storedProvenance: String?
    let publicationStatus: String?

    init(
        requestedDate: String,
        returnedDate: String,
        freshness: DailyRitualFreshness,
        origin: DailyRitualFetchOrigin,
        requestScope: DailyRitualRequestScope,
        batchID: String? = nil,
        endpointStatus: Int? = nil,
        storedProvenance: String? = nil,
        publicationStatus: String? = nil
    ) {
        self.requestedDate = requestedDate
        self.returnedDate = returnedDate
        self.freshness = freshness
        self.origin = origin
        self.requestScope = requestScope
        self.batchID = batchID
        self.endpointStatus = endpointStatus
        self.storedProvenance = storedProvenance
        self.publicationStatus = publicationStatus
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
        case ready(DailyRitualResponse, DailyRitualFetchMetadata)
        case notReady
        case failed(String)
    }

    enum CanonicalFetchOutcome {
        case ready(DailyLensContent, DailyRitualFetchMetadata)
        case notReady
        case failed(String)
    }

    /// Native title/read transport. It accepts the canonical response directly
    /// and adapts legacy six-field responses at this boundary. Existing
    /// `fetchDailyRitual` callers remain unchanged during the migration.
    func fetchTodaysLens(
        westernSign: String,
        easternSign: String,
        requestScope: DailyRitualRequestScope = .selfRead
    ) async -> CanonicalFetchOutcome {
        let requestedDate = Self.localDateString(Date())
        let key = cacheKey(for: requestedDate, westernSign: westernSign, easternSign: easternSign)

        let request: URLRequest
        do {
            request = try buildRequest(
                westernSign: westernSign,
                easternSign: easternSign,
                immutableRuntime: true
            )
        } catch {
            return .failed(error.localizedDescription)
        }

        for attempt in 0...retryPolicy.maximumRetryCount {
            if let delay = retryPolicy.delayNanoseconds(beforeRetry: attempt) {
                try? await Task.sleep(nanoseconds: delay)
            }

            do {
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    continue
                }
                if http.statusCode == 404 {
                    return .notReady
                }
                guard (200...299).contains(http.statusCode) else {
#if DEBUG || BETA
                    if let diagnostic = betaGenerationFailureMessage(from: data) {
                        return .failed(diagnostic)
                    }
#endif
                    if retryPolicy.shouldRetry(statusCode: http.statusCode) {
                        continue
                    }
                    return .failed(DailyRitualServiceError.unexpectedStatusCode(http.statusCode).localizedDescription)
                }

                let decoded = try decodeCanonicalRecord(from: data)
                guard decoded.content.isReadyForDisplay else {
                    return .notReady
                }
                let returnedDate = decoded.ritualDate ?? requestedDate
                guard let metadata = canonicalFreshnessMetadata(
                    returnedDate: returnedDate,
                    requestedDate: requestedDate,
                    origin: .network,
                    requestScope: requestScope,
                    batchID: decoded.batchID,
                    endpointStatus: http.statusCode,
                    storedProvenance: decoded.storedProvenance,
                    publicationStatus: decoded.publicationStatus
                ) else {
                    return .failed(DailyRitualServiceError.invalidResponse.localizedDescription)
                }
                cacheStore.saveRuntimeContent(
                    decoded.content.runtime,
                    metadata: decoded.content.metadata,
                    legacyResponse: decoded.legacyResponse,
                    for: key
                )
                return .ready(decoded.content, metadata)
            } catch {
                continue
            }
        }

        if let cached = cacheStore.loadRuntimeRecord(for: key) {
            let content = cached.legacyResponse.map(LegacyDailyRitualAdapter.content(from:))
                ?? DailyLensContent(
                    version: .editorialVoiceV21Amendment1,
                    runtime: cached.content,
                    provenance: .candidate,
                    metadata: cached.metadata ?? TodaysLensRuntimeMetadata(
                        ritualDate: requestedDate,
                        generationResult: "cache-restored",
                        validationResult: "previously-accepted",
                        retryState: "cached-fallback"
                    )
                )
            let returnedDate = cached.legacyResponse?.ritualDate ?? requestedDate
            guard let metadata = canonicalFreshnessMetadata(
                returnedDate: returnedDate,
                requestedDate: requestedDate,
                origin: .deviceCache,
                requestScope: requestScope
            ) else {
                return .notReady
            }
            return .ready(content, metadata)
        }

        return .notReady
    }

    func fetchDailyRitual(
        westernSign: String,
        easternSign: String,
        requestScope: DailyRitualRequestScope = .selfRead
    ) async -> FetchOutcome {
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

            let outcome = await fetchOnce(
                request: request,
                requestedDate: ritualDate,
                requestScope: requestScope
            )
            switch outcome {
            case .ready(let ritual, let metadata):
                saveCachedRitual(ritual, cacheKey: cacheKey)
                log("fetch succeeded with structured fields")
                return .ready(ritual, metadata)
            case .notReady:
                log("incomplete response detected")
                return .notReady
            case .failed:
                log("fetch failed")
            }
        }

        if let cached = loadCachedRitual(for: cacheKey) {
            log("cached read used after retries")
            guard let metadata = freshnessMetadata(
                for: cached,
                requestedDate: ritualDate,
                origin: .deviceCache,
                requestScope: requestScope
            ) else {
                return .notReady
            }
            return .ready(cached, metadata)
        }

        return .notReady
    }

    func preloadDailyRitual(westernSign: String, easternSign: String) async {
        _ = await fetchDailyRitual(westernSign: westernSign, easternSign: easternSign)
    }

    /// Read-only availability guard used before scheduling a notification that
    /// claims a Lens is ready. It never generates content.
    func hasAvailableTodaysLens(
        date: Date,
        westernSign: String,
        easternSign: String
    ) async -> Bool {
        do {
            let request = try buildRequest(
                westernSign: westernSign,
                easternSign: easternSign,
                ritualDate: Self.localDateString(date)
            )
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode),
                  let decoded = try? decodeCanonicalRecord(from: data) else {
                return false
            }
            return decoded.content.isReadyForDisplay
        } catch {
            return false
        }
    }

    private func fetchOnce(
        request: URLRequest,
        requestedDate: String,
        requestScope: DailyRitualRequestScope
    ) async -> FetchOutcome {
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
                        guard let metadata = freshnessMetadata(
                            for: ritual,
                            requestedDate: requestedDate,
                            origin: .network,
                            requestScope: requestScope
                        ) else {
                            log("invalid or future ritual_date")
                            return .failed(DailyRitualServiceError.invalidResponse.localizedDescription)
                        }
                        return .ready(ritual, metadata)
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

    private func buildRequest(
        westernSign: String,
        easternSign: String,
        ritualDate: String? = nil,
        immutableRuntime: Bool = false
    ) throws -> URLRequest {
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
        let todaysLensFunction = "get-daily-ritual"
        components.path = "/\(trimmedPath)/functions/v1/\(todaysLensFunction)"
            .replacingOccurrences(of: "//", with: "/")
        components.queryItems = [
            URLQueryItem(
                name: "ritual_date",
                value: ritualDate ?? Self.localDateString(Date())
            ),
            URLQueryItem(name: "western_sign", value: westernSign),
            URLQueryItem(name: "eastern_sign", value: easternSign),
            URLQueryItem(name: "environment", value: AppConfiguration.environment.rawValue)
        ]

        guard let url = components.url else {
            throw DailyRitualServiceError.invalidEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(
            AppConfiguration.environment.rawValue,
            forHTTPHeaderField: "x-zodian-content-environment"
        )

        if !anonKey.isEmpty {
            request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(anonKey, forHTTPHeaderField: "apikey")
        }

        return request
    }

    private func cacheKey(for ritualDate: String, westernSign: String, easternSign: String) -> String {
        [
            Self.cacheNamespace,
            AppConfiguration.environment.rawValue,
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

    func freshnessMetadata(
        for ritual: DailyRitualResponse,
        requestedDate: String,
        origin: DailyRitualFetchOrigin,
        requestScope: DailyRitualRequestScope
    ) -> DailyRitualFetchMetadata? {
        guard let returnedDate = ritual.ritualDate?.trimmingCharacters(in: .whitespacesAndNewlines),
              returnedDate.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil,
              returnedDate <= requestedDate else {
            return nil
        }

        return DailyRitualFetchMetadata(
            requestedDate: requestedDate,
            returnedDate: returnedDate,
            freshness: returnedDate == requestedDate ? .exact : .staleFallback,
            origin: origin,
            requestScope: requestScope
        )
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

    struct CanonicalDecodedRecord {
        let content: DailyLensContent
        let ritualDate: String?
        let legacyResponse: DailyRitualResponse?
        let batchID: String?
        let storedProvenance: String?
        let publicationStatus: String?
    }

    func decodeCanonicalRecord(from data: Data) throws -> CanonicalDecodedRecord {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let root = object as? [String: Any]
        else {
            throw DailyRitualServiceError.invalidResponse
        }

        let payload =
            (root["data"] as? [String: Any])
            ?? (root["ritual"] as? [String: Any])
            ?? (root["result"] as? [String: Any])
            ?? root

        if let read = payload["read"] as? String {
            let runtimeContract = exactNonblankString(payload["runtime_contract_version"])
            let title = exactNonblankString(payload["title"])
            let isReadOnly = runtimeContract == "todays-lens-read-only-v1"
            guard (isReadOnly && title == nil) || (!isReadOnly && title != nil) else {
                throw DailyRitualServiceError.invalidResponse
            }
            let runtime = TodaysLensRuntimeContent(title: title, read: read)
            guard runtime.isReadyForDisplay else {
                throw DailyRitualServiceError.invalidResponse
            }
            let storedProvenance = exactNonblankString(payload["provenance"])
            let publicationStatus = exactNonblankString(payload["publication_status"])
            let isNative = storedProvenance == "native_v2_1_amendment_1"
            let generationMetadata = payload["generation_metadata"] as? [String: Any]
            let canonicalAstrology = generationMetadata?["canonicalAstrology"] as? [String: Any]
            var runtimeMetadata = TodaysLensRuntimeMetadata(
                id: exactNonblankString(payload["id"]),
                batchID: exactNonblankString(payload["batch_id"]),
                ritualDate: exactNonblankString(payload["ritual_date"]),
                westernSign: exactNonblankString(payload["western_sign"]),
                easternSign: exactNonblankString(payload["eastern_sign"]),
                createdAt: exactNonblankString(payload["created_at"]),
                editorialVoiceVersion: exactNonblankString(payload["editorial_voice_version"])
                    ?? "unknown",
                runtimeContractVersion: exactNonblankString(payload["runtime_contract_version"])
                    ?? "unknown",
                providerModel: exactNonblankString(payload["provider_model"])
                    ?? "unknown",
                environment: exactNonblankString(payload["environment"]),
                publicationStatus: publicationStatus,
                selectedTheme: exactNonblankString(payload["selected_theme"])
                    ?? exactNonblankString(canonicalAstrology?["selectedTheme"]),
                generatorVersion: exactNonblankString(payload["generator_version"]),
                promptFingerprint: exactNonblankString(payload["prompt_fingerprint"])
                    ?? exactNonblankString(generationMetadata?["promptHash"]),
                generationResult: "ready",
                validationResult: "accepted",
                retryState: "none"
            )
#if DEBUG || BETA
            runtimeMetadata.betaDiagnostics = betaDiagnostics(from: payload["diagnostics"])
            print(
                "[DailyLens] resolver id=\(runtimeMetadata.id ?? "missing") " +
                "status=\(publicationStatus ?? "missing") " +
                "contract=\(runtimeMetadata.runtimeContractVersion) " +
                "date=\(runtimeMetadata.ritualDate ?? "missing")"
            )
#endif
            return CanonicalDecodedRecord(
                content: DailyLensContent(
                    version: isReadOnly
                        ? .skyLedReadOnlyV1
                        : (isNative ? .editorialVoiceV21Amendment1 : .canonicalTitleReadV1),
                    runtime: runtime,
                    provenance: .candidate,
                    metadata: runtimeMetadata
                ),
                ritualDate: payload["ritual_date"] as? String,
                legacyResponse: nil,
                batchID: exactNonblankString(payload["batch_id"]),
                storedProvenance: storedProvenance,
                publicationStatus: publicationStatus
            )
        }

        let legacy = try decodeRitual(from: data)
        return CanonicalDecodedRecord(
            content: LegacyDailyRitualAdapter.content(from: legacy),
            ritualDate: legacy.ritualDate,
            legacyResponse: legacy,
            batchID: nil,
            storedProvenance: "adapted_legacy",
            publicationStatus: nil
        )
    }

    private func canonicalFreshnessMetadata(
        returnedDate: String,
        requestedDate: String,
        origin: DailyRitualFetchOrigin,
        requestScope: DailyRitualRequestScope,
        batchID: String? = nil,
        endpointStatus: Int? = nil,
        storedProvenance: String? = nil,
        publicationStatus: String? = nil
    ) -> DailyRitualFetchMetadata? {
        let date = returnedDate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard date.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil,
              date <= requestedDate else {
            return nil
        }
        return DailyRitualFetchMetadata(
            requestedDate: requestedDate,
            returnedDate: date,
            freshness: date == requestedDate ? .exact : .staleFallback,
            origin: origin,
            requestScope: requestScope,
            batchID: batchID,
            endpointStatus: endpointStatus,
            storedProvenance: storedProvenance,
            publicationStatus: publicationStatus
        )
    }

    private func normalizedString(_ value: Any?) -> String? {
        guard let string = value as? String else { return nil }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

#if DEBUG || BETA
    private func betaGenerationFailureMessage(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let payload = object as? [String: Any],
            let stage = exactNonblankString(payload["stage"])
        else {
            return nil
        }
        let reasons: [String]
        if let values = payload["diagnostic"] as? [String] {
            reasons = values.compactMap { normalizedString($0) }
        } else if let reason = normalizedString(payload["diagnostic"]) {
            reasons = [reason]
        } else if
            let diagnostic = payload["diagnostic"] as? [String: Any],
            let values = diagnostic["errors"] as? [String]
        {
            reasons = values.compactMap { normalizedString($0) }
        } else {
            reasons = []
        }
        guard !reasons.isEmpty else { return nil }
        return [
            "Generation failed",
            "",
            "Stage:",
            stage,
            "",
            "Reason:",
            reasons.joined(separator: "\n"),
        ].joined(separator: "\n")
    }
#endif

    private func exactNonblankString(_ value: Any?) -> String? {
        guard let string = value as? String,
              !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return string
    }

#if DEBUG || BETA
    private func betaDiagnostics(from value: Any?) -> TodaysLensBetaDiagnostics? {
        guard let dictionary = value as? [String: Any],
              let identity = exactNonblankString(dictionary["identity"]),
              let packetID = exactNonblankString(dictionary["recognition_packet_id"]),
              let propositionIDs = dictionary["proposition_ids"] as? [String],
              let editorialStatus = dictionary["editorial_status"] as? [String: String],
              let approvalState = exactNonblankString(dictionary["approval_state"]),
              let runtimeVersion = exactNonblankString(dictionary["runtime_version"]),
              let writerVersion = exactNonblankString(dictionary["writer_version"]),
              let validatorVersion = exactNonblankString(dictionary["validator_version"]),
              let transformationVersion = exactNonblankString(dictionary["transformation_version"]),
              let generationTimestamp = exactNonblankString(dictionary["generation_timestamp"]),
              let cacheStatus = exactNonblankString(dictionary["cache_status"]) else {
            return nil
        }
        return TodaysLensBetaDiagnostics(
            identity: identity,
            recognitionPacketID: packetID,
            propositionIDs: propositionIDs,
            editorialStatus: editorialStatus,
            approvalState: approvalState,
            runtimeVersion: runtimeVersion,
            writerVersion: writerVersion,
            validatorVersion: validatorVersion,
            transformationVersion: transformationVersion,
            generationTimestamp: generationTimestamp,
            cacheStatus: cacheStatus
        )
    }
#endif

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
        let legacyText = exactNonblankString(payloadDictionary["ritual_text"])
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
