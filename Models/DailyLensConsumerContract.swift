import Foundation

/// Versioned content contract consumed by Today’s Lens presentation surfaces.
/// The six-field control remains available as provenance, but candidate copy is
/// never expanded into fields it did not produce.
enum DailyLensContentVersion: String, Codable, Equatable {
    case productionControlV1 = "production-control-v1"
    case productionCandidateV1 = "pcv1"
    case productionCandidateFrozenWriterV1 = "pcv1-frozen-approved-input-v1"
}

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
              let title = title?.dailyLensNonblank,
              let read = read?.dailyLensNonblank else {
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
    let title: String
    let read: String
    let provenance: Provenance

    init(
        version: DailyLensContentVersion,
        title: String,
        read: String,
        provenance: Provenance
    ) {
        self.version = version
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.read = read.trimmingCharacters(in: .whitespacesAndNewlines)
        self.provenance = provenance
    }

    init(control: DailyRitualResponse) {
        self.init(
            version: .productionControlV1,
            title: control.title,
            read: control.ritualText,
            provenance: .productionControl(control)
        )
    }

    var isReadyForDisplay: Bool {
        title.dailyLensNonblank != nil && read.dailyLensNonblank != nil
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

struct DailyLensSharePayload: Equatable {
    let version: DailyLensContentVersion
    let signLine: String
    let title: String
    let read: String

    init(content: DailyLensContent, signLine: String) {
        version = content.version
        self.signLine = signLine
        title = content.title
        read = content.read
    }

    var text: String {
        """
        Zodian Today’s Lens
        \(signLine)

        \(title)

        \(read)
        """
    }
}

private extension String {
    var dailyLensNonblank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
