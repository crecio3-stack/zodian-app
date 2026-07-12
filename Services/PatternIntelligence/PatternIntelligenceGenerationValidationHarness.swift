import Foundation

#if DEBUG
enum PatternIntelligenceGenerationValidationHarness {
    struct Report: Equatable {
        let passed: Bool
        let checks: [Check]
        let appleFoundationModelsAvailability: PatternIntelligenceGenerationAvailability

        var failures: [Check] {
            checks.filter { !$0.passed }
        }
    }

    struct Check: Equatable {
        let name: String
        let passed: Bool
        let detail: String
    }

    static func run() async -> Report {
        let fixture = Fixture()
        let fallbackProvider = MockProvider(
            kind: .fallback,
            availability: .available,
            output: "Your saved Lenses are beginning to point toward growth.",
            isFallback: true
        )
        let service = PatternIntelligenceGenerationService(
            backendProvider: MockProvider(kind: .backendAI, availability: .unavailable(reason: "backend unavailable")),
            appleProvider: MockProvider(kind: .appleFoundationModels, availability: .unavailable(reason: "apple unavailable")),
            fallbackProvider: fallbackProvider
        )

        let backendResult = await service.generate(fixture.earlyRequest, preferredProvider: .backendAI)
        let appleResult = await service.generate(fixture.shiftRequest, preferredProvider: .appleFoundationModels)
        let fallbackResult = await service.generate(fixture.questionRequest, preferredProvider: .fallback)
        let realAppleAvailability = PatternIntelligenceGenerationService.shared.availability(for: .appleFoundationModels)

        let generated = [backendResult, appleResult, fallbackResult]
        let checks = [
            check(
                "backendAI unavailable falls back",
                backendResult.provider == .fallback && backendResult.isFallback,
                "provider=\(backendResult.provider.rawValue), isFallback=\(backendResult.isFallback)"
            ),
            check(
                "appleFoundationModels unavailable falls back",
                appleResult.provider == .fallback && appleResult.isFallback,
                "provider=\(appleResult.provider.rawValue), isFallback=\(appleResult.isFallback)"
            ),
            check(
                "fallback provider returns deterministic copy",
                fallbackResult == fallbackProvider.expectedSummary,
                "text=\(fallbackResult.text)"
            ),
            check(
                "generated outputs are short and display-safe",
                generated.allSatisfy(isDisplaySafe),
                generated.map(\.text).joined(separator: " | ")
            ),
            check(
                "generated outputs do not leak raw saved Lens metadata",
                generated.allSatisfy { output in
                    fixture.rawMetadataSentinels.allSatisfy { !output.text.localizedCaseInsensitiveContains($0) }
                },
                "checked \(fixture.rawMetadataSentinels.count) sentinel values"
            ),
            check(
                "Apple Foundation Models availability is inspectable",
                availabilityIsInspectable(realAppleAvailability),
                "\(realAppleAvailability)"
            )
        ]

        return Report(
            passed: checks.allSatisfy(\.passed),
            checks: checks,
            appleFoundationModelsAvailability: realAppleAvailability
        )
    }

    static func runAndPrint() async {
        let report = await run()
        let status = report.passed ? "PASS" : "FAIL"
        print("[PatternIntelligenceGenerationValidation] RESULT: \(status) (\(report.checks.count - report.failures.count)/\(report.checks.count))")
        print("[PatternIntelligenceGenerationValidation] Apple Foundation Models availability: \(report.appleFoundationModelsAvailability)")

        for check in report.checks {
            let checkStatus = check.passed ? "PASS" : "FAIL"
            print("[PatternIntelligenceGenerationValidation] \(checkStatus): \(check.name) - \(check.detail)")
        }
    }

    private static func check(_ name: String, _ passed: Bool, _ detail: String) -> Check {
        Check(name: name, passed: passed, detail: detail)
    }

    private static func isDisplaySafe(_ output: PatternIntelligenceGeneratedSummary) -> Bool {
        let text = output.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !text.isEmpty
            && text.count <= 180
            && !text.contains("\n")
            && !text.contains("\t")
            && output.privacyNote.count <= 180
    }

    private static func availabilityIsInspectable(_ availability: PatternIntelligenceGenerationAvailability) -> Bool {
        switch availability {
        case .available:
            return true
        case .unavailable(let reason):
            return !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

private struct MockProvider: PatternIntelligenceGenerationProvider {
    let kind: PatternIntelligenceGenerationProviderKind
    let availability: PatternIntelligenceGenerationAvailability
    let output: String
    let isFallback: Bool

    init(
        kind: PatternIntelligenceGenerationProviderKind,
        availability: PatternIntelligenceGenerationAvailability,
        output: String = "",
        isFallback: Bool = false
    ) {
        self.kind = kind
        self.availability = availability
        self.output = output
        self.isFallback = isFallback
    }

    var expectedSummary: PatternIntelligenceGeneratedSummary {
        PatternIntelligenceGeneratedSummary(
            text: output,
            provider: kind,
            isFallback: isFallback,
            privacyNote: "DEBUG validation provider. No model request is made."
        )
    }

    func generate(_ request: PatternIntelligenceGenerationRequest) async throws -> PatternIntelligenceGeneratedSummary {
        guard case .available = availability else {
            throw PatternIntelligenceGenerationError.unavailable("\(kind.rawValue) unavailable")
        }

        return expectedSummary
    }
}

private struct Fixture {
    let rawMetadataSentinels = [
        "RAW_THEME_SENTINEL_921",
        "RAW_SUMMARY_SENTINEL_482",
        "RAW_DATE_SENTINEL_337",
        "RAW_ARCHETYPE_SENTINEL_104",
        "RAW_SIGNAL_SENTINEL_775"
    ]

    var earlyRequest: PatternIntelligenceGenerationRequest {
        request(task: .earlyPatternSummary)
    }

    var shiftRequest: PatternIntelligenceGenerationRequest {
        request(task: .patternShiftSummary)
    }

    var questionRequest: PatternIntelligenceGenerationRequest {
        request(task: .suggestedQuestionAnswerDraft(question: "Why does this keep showing up?"))
    }

    private func request(task: PatternIntelligenceGenerationTask) -> PatternIntelligenceGenerationRequest {
        PatternIntelligenceGenerationRequest(
            task: task,
            preview: preview,
            savedReads: savedReads
        )
    }

    private var preview: PatternIntelligencePreview {
        PatternIntelligencePreview(
            state: .ready,
            savedCount: 6,
            sentence: "We're starting to connect the dots.",
            supportingLine: "Growth is becoming easier to see.",
            statusLabel: "Growing",
            topSignal: "Growth",
            topSignals: ["Growth", "Trust Instincts"],
            discoveries: [
                PatternIntelligenceSignalDiscovery(
                    label: "Growth",
                    recurrenceCount: 3,
                    sampleSize: 6,
                    isApproximate: false
                )
            ],
            earlyInsight: "Growth is starting to surface.",
            patternShift: "Confidence is becoming more present.",
            suggestedQuestions: ["Why does this keep showing up?"],
            memoryCallback: "This theme appeared earlier, then returned in another saved Lens.",
            earlyPatternNarrative: "Across your saved Lenses, growth keeps returning.",
            patternShiftNarrative: "Recent saved Lenses are making confidence easier to see.",
            askReadinessCopy: nil,
            signature: PatternIntelligenceVisualSignature(
                seed: 42,
                rotationOffset: 0.1,
                verticalBias: 0.0,
                nodeDrift: 0.2,
                pulseStrength: 0.4
            ),
            scores: PatternIntelligenceSignalScores(
                confidence: 0.65,
                reflection: 0.58,
                connection: 0.44,
                growth: 0.82,
                momentum: 0.51
            )
        )
    }

    private var savedReads: [SavedDailyReading] {
        [
            SavedDailyReading(
                dateKey: "RAW_DATE_SENTINEL_337",
                archetypeId: "RAW_ARCHETYPE_SENTINEL_104",
                theme: "RAW_THEME_SENTINEL_921",
                summary: "RAW_SUMMARY_SENTINEL_482",
                mood: "debug",
                themeKey: "RAW_THEME_SENTINEL_921",
                patternPrimarySignal: "RAW_SIGNAL_SENTINEL_775",
                love: "debug",
                work: "debug",
                growth: "debug",
                caution: "debug",
                opportunity: "debug"
            )
        ]
    }
}
#endif
