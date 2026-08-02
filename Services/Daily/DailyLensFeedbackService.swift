import Combine
import Foundation
import UIKit

enum DailyLensFeedbackResponse: String, Codable, Equatable, Sendable {
    case up
    case down
}

enum DailyLensFeedbackReason: String, CaseIterable, Codable, Equatable, Sendable {
    case tooGeneric = "too_generic"
    case didNotMatchMyDay = "did_not_match_my_day"
    case didNotSoundLikeMe = "did_not_sound_like_me"
    case somethingElse = "something_else"

    var title: String {
        switch self {
        case .tooGeneric: return "Too generic"
        case .didNotMatchMyDay: return "Didn’t match my day"
        case .didNotSoundLikeMe: return "Didn’t sound like me"
        case .somethingElse: return "Something else"
        }
    }
}

nonisolated struct DailyLensFeedbackAuthentication: Sendable {
    let userID: String
    let installationID: String
    let accessToken: String
}

struct DailyLensFeedbackContext: Equatable, Sendable {
    enum Source: Equatable, Sendable {
        case publishedBatch
        case exactBetaOverride
    }

    let lensID: String
    let batchID: String
    let contentDate: String
    let westernSign: String
    let chineseSign: String
    let selectedTheme: String?
    let generatorVersion: String?
    let promptFingerprint: String?
    let source: Source

    var key: String { "\(lensID):\(batchID)" }

    init?(content: DailyLensContent) {
        let metadata = content.metadata
        guard let lensID = Self.nonblank(metadata.id),
              let batchID = Self.nonblank(metadata.batchID),
              let contentDate = Self.nonblank(metadata.ritualDate),
              let westernSign = Self.nonblank(metadata.westernSign),
              let chineseSign = Self.nonblank(metadata.easternSign) else {
            return nil
        }
        self.lensID = lensID
        self.batchID = batchID
        self.contentDate = contentDate
        self.westernSign = westernSign
        self.chineseSign = chineseSign
        selectedTheme = metadata.selectedTheme
        generatorVersion = metadata.generatorVersion
        promptFingerprint = metadata.promptFingerprint
        source = metadata.publicationStatus == "EXACT_BETA_OVERRIDE"
            ? .exactBetaOverride
            : .publishedBatch
    }

    private static func nonblank(_ value: String?) -> String? {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }
}

struct DailyLensFeedbackRecord: Decodable {
    let response: DailyLensFeedbackResponse
    let negativeReason: DailyLensFeedbackReason?

    enum CodingKeys: String, CodingKey {
        case response
        case negativeReason = "negative_reason"
    }
}

actor DailyLensFeedbackService {
    static let shared = DailyLensFeedbackService()

    enum Failure: Error {
        case configuration
        case invalidResponse
    }

    func existingResponse(
        for context: DailyLensFeedbackContext,
        authentication: DailyLensFeedbackAuthentication
    ) async throws -> DailyLensFeedbackRecord? {
        var components = try endpointComponents()
        let sourceField = context.source == .exactBetaOverride
            ? "beta_override_row_id"
            : "published_lens_id"
        components.queryItems = [
            URLQueryItem(name: "select", value: "response,negative_reason"),
            URLQueryItem(name: sourceField, value: "eq.\(context.lensID)"),
            URLQueryItem(name: "limit", value: "1"),
        ]
        guard let url = components.url else { throw Failure.configuration }
        var request = authorizedRequest(url: url, authentication: authentication)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw Failure.invalidResponse
        }
        return try JSONDecoder().decode([DailyLensFeedbackRecord].self, from: data).first
    }

    func upsert(
        _ value: DailyLensFeedbackResponse,
        negativeReason: DailyLensFeedbackReason?,
        context: DailyLensFeedbackContext,
        authentication: DailyLensFeedbackAuthentication
    ) async throws {
        var components = try endpointComponents()
        let isBetaOverride = context.source == .exactBetaOverride
        components.queryItems = [
            URLQueryItem(
                name: "on_conflict",
                value: isBetaOverride ? "user_id,beta_override_row_id" : "user_id,published_lens_id"
            ),
        ]
        guard let url = components.url else { throw Failure.configuration }
        var request = authorizedRequest(url: url, authentication: authentication)
        request.httpMethod = "POST"
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var payload: [String: Any] = [
            "user_id": authentication.userID,
            "installation_id": authentication.installationID,
            "content_date": context.contentDate,
            "western_sign": context.westernSign,
            "chinese_sign": context.chineseSign,
            "response": value.rawValue,
            "negative_reason": value == .down ? negativeReason?.rawValue as Any : NSNull(),
            "app_version": AppConfiguration.appVersion,
            "app_build": AppConfiguration.buildNumber,
        ]
        if isBetaOverride {
            payload["beta_override_row_id"] = context.lensID
            payload["beta_override_publication_id"] = context.batchID
        } else {
            payload["published_lens_id"] = context.lensID
            payload["batch_id"] = context.batchID
        }
        payload["selected_theme"] = context.selectedTheme
        payload["generator_version"] = context.generatorVersion
        payload["prompt_fingerprint"] = context.promptFingerprint
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw Failure.invalidResponse
        }
    }

    private func endpointComponents() throws -> URLComponents {
        guard let configuration = AppConfiguration.supabaseConfiguration,
              let components = URLComponents(
                url: configuration.url.appendingPathComponent("rest/v1/daily_lens_feedback"),
                resolvingAgainstBaseURL: false
              ) else {
            throw Failure.configuration
        }
        return components
    }

    private func authorizedRequest(
        url: URL,
        authentication: DailyLensFeedbackAuthentication
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authentication.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(AppConfiguration.supabaseAnonKey, forHTTPHeaderField: "apikey")
        return request
    }
}

@MainActor
final class DailyLensFeedbackController: ObservableObject {
    @Published private(set) var selected: DailyLensFeedbackResponse?
    @Published private(set) var negativeReason: DailyLensFeedbackReason?
    @Published private(set) var confirmationMessage: String?
    @Published private(set) var isLoading = false
    @Published private(set) var hasRetryableSubmissionError = false

    private var loadedKey: String?
    private var persisted: DailyLensFeedbackResponse?
    private var persistedNegativeReason: DailyLensFeedbackReason?
    private var pending: DailyLensFeedbackResponse?
    private var failedSubmission: FeedbackSubmission?
    private var shouldConfirmDismissedNegativeReason = false

    private struct FeedbackSubmission {
        let response: DailyLensFeedbackResponse
        let negativeReason: DailyLensFeedbackReason?
        let confirmation: String?
    }

    func restore(
        context: DailyLensFeedbackContext,
        ownership: AccountOwnershipController
    ) async {
        guard loadedKey != context.key else { return }
        loadedKey = context.key
        selected = nil
        persisted = nil
        negativeReason = nil
        persistedNegativeReason = nil
        confirmationMessage = nil
        hasRetryableSubmissionError = false
        failedSubmission = nil
        shouldConfirmDismissedNegativeReason = false
        isLoading = true
        defer { isLoading = false }
        do {
            let authentication = try await ownership.feedbackAuthenticationContext()
            let record = try await DailyLensFeedbackService.shared.existingResponse(
                for: context,
                authentication: authentication
            )
            guard loadedKey == context.key else { return }
            selected = record?.response
            persisted = record?.response
            negativeReason = record?.negativeReason
            persistedNegativeReason = record?.negativeReason
        } catch {
            // An unavailable restore must not surface a Retry action. Retry is
            // reserved for a feedback submission the user explicitly made.
        }
    }

    func submit(
        _ response: DailyLensFeedbackResponse,
        negativeReason newNegativeReason: DailyLensFeedbackReason? = nil,
        confirmation: String? = nil,
        context: DailyLensFeedbackContext,
        ownership: AccountOwnershipController
    ) {
        let resolvedReason = response == .down
            ? (newNegativeReason ?? (persisted == .down ? persistedNegativeReason : nil))
            : nil
        guard pending != response || persisted != response || persistedNegativeReason != resolvedReason else {
            selected = response
            return
        }
        let submission = FeedbackSubmission(
            response: response,
            negativeReason: resolvedReason,
            confirmation: confirmation
        )
        begin(submission, context: context, ownership: ownership)
    }

    func retry(context: DailyLensFeedbackContext, ownership: AccountOwnershipController) {
        guard let failedSubmission else { return }
        begin(failedSubmission, context: context, ownership: ownership)
    }

    func negativeReasonSheetDismissedWithoutSelection() {
        guard selected == .down, negativeReason == nil else { return }
        shouldConfirmDismissedNegativeReason = true
        guard pending == nil, !hasRetryableSubmissionError, persisted == .down else { return }
        showConfirmation("Thanks for the feedback.")
    }

    private func begin(
        _ submission: FeedbackSubmission,
        context: DailyLensFeedbackContext,
        ownership: AccountOwnershipController
    ) {
        let previous = persisted
        let response = submission.response
        let resolvedReason = submission.negativeReason
        selected = response
        negativeReason = resolvedReason
        pending = response
        confirmationMessage = nil
        hasRetryableSubmissionError = false
        failedSubmission = nil

        Task {
            do {
                let authentication = try await ownership.feedbackAuthenticationContext()
                try await DailyLensFeedbackService.shared.upsert(
                    response,
                    negativeReason: resolvedReason,
                    context: context,
                    authentication: authentication
                )
                guard loadedKey == context.key else { return }
                pending = nil
                persisted = response
                persistedNegativeReason = resolvedReason
                if let confirmation = submission.confirmation {
                    showConfirmation(confirmation)
                } else if response == .down,
                          resolvedReason == nil,
                          shouldConfirmDismissedNegativeReason {
                    showConfirmation("Thanks for the feedback.")
                }
                AnalyticsService.shared.track(
                    previous == nil
                        ? .dailyLensFeedbackSubmitted(context: context, response: response)
                        : .dailyLensFeedbackChanged(context: context, response: response)
                )
                if let resolvedReason {
                    AnalyticsService.shared.track(
                        .dailyLensFeedbackReasonSelected(context: context, reason: resolvedReason)
                    )
                }
            } catch {
                guard loadedKey == context.key else { return }
                pending = nil
                hasRetryableSubmissionError = true
                failedSubmission = submission
            }
        }
    }

    func dismissConfirmation(_ message: String) {
        guard confirmationMessage == message else { return }
        confirmationMessage = nil
    }

    private func showConfirmation(_ message: String) {
        confirmationMessage = message
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
