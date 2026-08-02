import Foundation

/// Canonical runtime and wire contract for Today’s Lens.
///
/// Values are stored exactly as decoded. In particular, `read` is never
/// trimmed, reflowed, or whitespace-normalized because authored paragraph
/// breaks are presentation data.
struct TodaysLensRuntimeContent: Codable, Equatable {
    let title: String?
    let read: String

    init(title: String?, read: String) {
        self.title = title
        self.read = read
    }

    var isReadyForDisplay: Bool {
        read.dailyLensNonblank != nil
    }
}

/// Production presentation contract for the reduced Today’s Lens surface.
/// Renderers consume only this canonical title/read projection.
typealias TodayLensContent = DailyLensContent

/// Versioned content contract consumed by Today’s Lens presentation surfaces.
/// The six-field control remains available as provenance, but candidate copy is
/// never expanded into fields it did not produce.
enum DailyLensContentVersion: String, Codable, Equatable {
    case canonicalTitleReadV1 = "todays-lens-title-read-v1"
    case skyLedReadOnlyV1 = "todays-lens-read-only-v1"
    case editorialVoiceV21Amendment1 = "zodian-editorial-voice-v2.1-amendment-1"
    case productionControlV1 = "production-control-v1"
    case productionCandidateV1 = "pcv1"
    case productionCandidateFrozenWriterV1 = "pcv1-frozen-approved-input-v1"
    /// Development candidate contract. It is inert unless an explicit
    /// Development candidate provider supplies this separately versioned copy.
    case zodianEditorialVoiceDevelopmentCandidateV1 = "todays-lens-zodian-editorial-voice-development-candidate-v1"
#if DEBUG
    /// Local fixture provenance only. This is compiled out of Beta and Release.
    case todaysLensZodianEditorialVoiceV1 = "todays-lens-zodian-editorial-voice-v1"
    /// Finalized 20-case Recognition Pass benchmark for local review only.
    case todaysLensEditorialVoiceV2RecognitionCandidate =
        "todays-lens-editorial-voice-v2-recognition-benchmark-candidates-v1"
    /// Local production-candidate review provenance only. This is compiled out
    /// of Beta and Release and cannot select a production transport.
    case todaysLensEditorialVoiceV21Amendment1ProductionCandidate = "todays-lens-editorial-voice-v2.1-amendment-1-production-candidate-v1"
#endif
}

struct TodaysLensRuntimeMetadata: Codable, Equatable {
    static let editorialVoiceVersion = "zodian-editorial-voice-v2.1-amendment-1"
    static let runtimeContractVersion = "todays-lens-title-read-v1"
    static let providerModel = "gpt-5.6-terra"

    let id: String?
    let batchID: String?
    let ritualDate: String?
    let westernSign: String?
    let easternSign: String?
    let createdAt: String?
    let editorialVoiceVersion: String
    let runtimeContractVersion: String
    let providerModel: String
    let environment: String?
    let publicationStatus: String?
    let selectedTheme: String?
    let generatorVersion: String?
    let promptFingerprint: String?
    let generationResult: String
    let validationResult: String
    let retryState: String
#if DEBUG || BETA
    var betaDiagnostics: TodaysLensBetaDiagnostics?
#endif

    init(
        id: String? = nil,
        batchID: String? = nil,
        ritualDate: String? = nil,
        westernSign: String? = nil,
        easternSign: String? = nil,
        createdAt: String? = nil,
        editorialVoiceVersion: String = Self.editorialVoiceVersion,
        runtimeContractVersion: String = Self.runtimeContractVersion,
        providerModel: String = Self.providerModel,
        environment: String? = nil,
        publicationStatus: String? = nil,
        selectedTheme: String? = nil,
        generatorVersion: String? = nil,
        promptFingerprint: String? = nil,
        generationResult: String = "ready",
        validationResult: String = "accepted",
        retryState: String = "none"
    ) {
        self.id = id
        self.batchID = batchID
        self.ritualDate = ritualDate
        self.westernSign = westernSign
        self.easternSign = easternSign
        self.createdAt = createdAt
        self.editorialVoiceVersion = editorialVoiceVersion
        self.runtimeContractVersion = runtimeContractVersion
        self.providerModel = providerModel
        self.environment = environment
        self.publicationStatus = publicationStatus
        self.selectedTheme = selectedTheme
        self.generatorVersion = generatorVersion
        self.promptFingerprint = promptFingerprint
        self.generationResult = generationResult
        self.validationResult = validationResult
        self.retryState = retryState
#if DEBUG || BETA
        self.betaDiagnostics = nil
#endif
    }
}

#if DEBUG || BETA
struct TodaysLensBetaDiagnostics: Codable, Equatable {
    let identity: String
    let recognitionPacketID: String
    let propositionIDs: [String]
    let editorialStatus: [String: String]
    let approvalState: String
    let runtimeVersion: String
    let writerVersion: String
    let validatorVersion: String
    let transformationVersion: String
    let generationTimestamp: String
    let cacheStatus: String

    enum CodingKeys: String, CodingKey {
        case identity
        case recognitionPacketID = "recognition_packet_id"
        case propositionIDs = "proposition_ids"
        case editorialStatus = "editorial_status"
        case approvalState = "approval_state"
        case runtimeVersion = "runtime_version"
        case writerVersion = "writer_version"
        case validatorVersion = "validator_version"
        case transformationVersion = "transformation_version"
        case generationTimestamp = "generation_timestamp"
        case cacheStatus = "cache_status"
    }
}
#endif

struct DailyLensCandidateV1: Codable, Equatable {
    enum Status: String, Codable, Equatable {
        case accepted
        case blocked
        case writerRejected = "writer_rejected"
        case validatorRejected = "validator_rejected"
        case transportFailed = "transport_failed"
        case repetitionHold = "repetition_hold"
        case running
        case notFound = "not_found"
    }

    let version: DailyLensContentVersion
    let status: Status
    let title: String?
    let read: String?
    let reasonCode: String?

    enum CodingKeys: String, CodingKey {
        case version
        case status
        case title
        case read
        case reasonCode = "reason_code"
    }

    var acceptedContent: DailyLensContent? {
        guard version != .productionControlV1,
              status == .accepted,
              let read,
              read.dailyLensNonblank != nil else {
            return nil
        }

        return DailyLensContent(
            version: version,
            title: title,
            read: read,
            provenance: .candidate
        )
    }
}

struct DailyLensContent: Equatable {
    enum Provenance: Equatable {
        case productionControl(DailyRitualResponse)
        case candidate
    }

    let version: DailyLensContentVersion
    let runtime: TodaysLensRuntimeContent
    let provenance: Provenance
    let metadata: TodaysLensRuntimeMetadata

    var title: String? { runtime.title }
    var read: String { runtime.read }

    init(
        version: DailyLensContentVersion,
        title: String?,
        read: String,
        provenance: Provenance,
        metadata: TodaysLensRuntimeMetadata = TodaysLensRuntimeMetadata()
    ) {
        self.version = version
        self.runtime = TodaysLensRuntimeContent(title: title, read: read)
        self.provenance = provenance
        self.metadata = metadata
    }

    init(
        version: DailyLensContentVersion,
        runtime: TodaysLensRuntimeContent,
        provenance: Provenance,
        metadata: TodaysLensRuntimeMetadata = TodaysLensRuntimeMetadata()
    ) {
        self.version = version
        self.runtime = runtime
        self.provenance = provenance
        self.metadata = metadata
    }

    init(control: DailyRitualResponse) {
        self = LegacyDailyRitualAdapter.content(from: control)
    }

    var isReadyForDisplay: Bool {
        runtime.isReadyForDisplay
    }

    var control: DailyRitualResponse? {
        guard case .productionControl(let control) = provenance else { return nil }
        return control
    }

    var isProductionControl: Bool {
        control != nil
    }

    var isCandidate: Bool {
        !isProductionControl
    }

}

/// The only place where the historical six-field response is projected into
/// the canonical runtime contract. Presentation code never branches on the
/// legacy schema.
enum LegacyDailyRitualAdapter {
    static func runtimeContent(from response: DailyRitualResponse) -> TodaysLensRuntimeContent {
        TodaysLensRuntimeContent(
            title: response.title,
            read: response.ritualText
        )
    }

    static func content(from response: DailyRitualResponse) -> DailyLensContent {
        DailyLensContent(
            version: .productionControlV1,
            runtime: runtimeContent(from: response),
            provenance: .productionControl(response),
            metadata: TodaysLensRuntimeMetadata(
                id: response.id,
                ritualDate: response.ritualDate,
                westernSign: response.westernSign,
                easternSign: response.easternSign,
                createdAt: response.createdAt,
                editorialVoiceVersion: "legacy-six-field",
                generationResult: "legacy-cache-adapted",
                validationResult: "compatibility",
                retryState: "not-applicable"
            )
        )
    }
}

struct DailyLensSharePayload: Equatable {
    let version: DailyLensContentVersion
    let signLine: String
    let title: String?
    let read: String

    init(content: DailyLensContent, signLine: String) {
        version = content.version
        self.signLine = signLine
        title = content.title
        read = content.read
    }

    var text: String {
        let heading = ["Zodian Daily Lens", signLine].joined(separator: "\n")
        return [heading, title?.dailyLensNonblank, read]
            .compactMap { $0 }
            .joined(separator: "\n\n")
    }
}

private extension String {
    var dailyLensNonblank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
