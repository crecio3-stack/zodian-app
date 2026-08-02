//
//  ConnectFilter.swift
//  Zodian
//
//  Created by Ian Recio on 4/11/26.
//


import Foundation
import SwiftUI

enum ConnectFilter: String, CaseIterable, Identifiable, Codable {
    case compatible
    case similar
    case newEnergy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compatible: return "Ease"
        case .similar: return "Depth"
        case .newEnergy: return "Spark"
        }
    }

    var subtitle: String {
        switch self {
        case .compatible: return "People who feel easy to understand"
        case .similar: return "People who notice what sits underneath"
        case .newEnergy: return "People who bring a new part of you into focus"
        }
    }

    var detail: String {
        switch self {
        case .compatible: return "A softer lens on what feels natural"
        case .similar: return "A slower lens on what feels familiar"
        case .newEnergy: return "A sharper lens on contrast and change"
        }
    }
}

enum SwipeAction: String, Codable {
    case like
    case pass
}

enum MatchStyle: String, Codable {
    case harmonious
    case mirrored
    case magnetic
    case growth
    case intense

    var label: String {
        switch self {
        case .harmonious: return "Observe First"
        case .mirrored: return "Depth"
        case .magnetic: return "Spark"
        case .growth: return "Reach"
        case .intense: return "Charge"
        }
    }

    var introLabel: String {
        switch self {
        case .harmonious: return "Observe First"
        case .mirrored: return "Depth"
        case .magnetic: return "Spark"
        case .growth: return "Reach"
        case .intense: return "Charge"
        }
    }
}

struct MatchReason: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
}

struct ConnectProfileSignal: Equatable, Hashable {
    static let promptPool = [
        "How I move",
        "What stands out",
        "What I want"
    ]

    private static let promptAliases = [
        "I do best when": "How I move",
        "People notice first": "What stands out",
        "One thing about me": "What I want",
        "I’m working on": "What I want",
        "I’m drawn to": "What I want"
    ]

    let prompt: String
    let response: String

    init(prompt: String, response: String) {
        self.prompt = Self.cleanPrompt(prompt)
        self.response = response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(_ prompt: String, _ response: String) {
        self.init(prompt: prompt, response: response)
    }

    var displayText: String {
        "\(prompt) → \(response)"
    }

    var storageLine: String {
        "\(prompt)\t\(response)"
    }

    static func storageString(from signals: [ConnectProfileSignal]) -> String {
        signals
            .filter { !$0.prompt.isEmpty && !$0.response.isEmpty }
            .map(\.storageLine)
            .joined(separator: "\n")
    }

    static func parseRaw(_ raw: String) -> [ConnectProfileSignal] {
        raw
            .split(separator: "\n")
            .enumerated()
            .compactMap { index, line in
                let trimmedLine = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedLine.isEmpty else { return nil }

                if let tabIndex = trimmedLine.firstIndex(of: "\t") {
                    let prompt = String(trimmedLine[..<tabIndex])
                    let response = String(trimmedLine[trimmedLine.index(after: tabIndex)...])
                    return makeSignal(prompt: prompt, response: response, fallbackIndex: index)
                }

                if let arrowRange = trimmedLine.range(of: "→") {
                    let prompt = String(trimmedLine[..<arrowRange.lowerBound])
                    let response = String(trimmedLine[arrowRange.upperBound...])
                    return makeSignal(prompt: prompt, response: response, fallbackIndex: index)
                }

                return makeSignal(
                    prompt: promptPool[index % promptPool.count],
                    response: trimmedLine,
                    fallbackIndex: index
                )
            }
    }

    private static func makeSignal(
        prompt: String,
        response: String,
        fallbackIndex: Int
    ) -> ConnectProfileSignal? {
        let cleanResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanResponse.isEmpty else { return nil }

        let cleanPrompt = cleanPrompt(prompt)
        return ConnectProfileSignal(
            prompt: cleanPrompt.isEmpty ? promptPool[fallbackIndex % promptPool.count] : cleanPrompt,
            response: cleanResponse
        )
    }

    private static func cleanPrompt(_ prompt: String) -> String {
        let cleaned = prompt
            .replacingOccurrences(of: "→", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return promptAliases[cleaned] ?? cleaned
    }
}

struct CompatibilityBreakdown: Equatable {
    let totalScore: Int
    let westernScore: Int
    let chineseScore: Int
    let archetypeScore: Int
    let style: MatchStyle
    let reasons: [MatchReason]
    let frictionNote: String
}

struct DeckProfile: Identifiable, Equatable {
    let id: UUID
    let name: String
    let age: Int
    let archetypeId: String
    let archetypeTitle: String
    let combinedSigns: String
    let westernSign: WesternZodiac
    let chineseSign: ChineseZodiac
    let essence: String
    let connectionPrompt: String
    let compatibilityScore: Int
    let matchStyle: MatchStyle
    let matchReasons: [MatchReason]
    let frictionNote: String
    let imageName: String
    let imageAnchor: UnitPoint
    let intent: String
    let signals: [ConnectProfileSignal]

    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        archetypeId: String,
        archetypeTitle: String,
        combinedSigns: String,
        westernSign: WesternZodiac,
        chineseSign: ChineseZodiac,
        essence: String,
        connectionPrompt: String,
        compatibilityScore: Int,
        matchStyle: MatchStyle,
        matchReasons: [MatchReason],
        frictionNote: String,
        imageName: String,
        imageAnchor: UnitPoint,
        intent: String,
        signals: [ConnectProfileSignal] = []
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.archetypeId = archetypeId
        self.archetypeTitle = archetypeTitle
        self.combinedSigns = combinedSigns
        self.westernSign = westernSign
        self.chineseSign = chineseSign
        self.essence = essence
        self.connectionPrompt = connectionPrompt
        self.compatibilityScore = compatibilityScore
        self.matchStyle = matchStyle
        self.matchReasons = matchReasons
        self.frictionNote = frictionNote
        self.imageName = imageName
        self.imageAnchor = imageAnchor
        self.intent = intent
        self.signals = signals
    }
}
