import Foundation

/// Adds editorial breathing room to already-approved prose without rewriting it.
///
/// The formatter may replace whitespace between sentences with paragraph breaks.
/// It never changes sentence text, punctuation, or order.
enum EditorialParagraphFormatter {
    static func format(_ text: String) -> String {
        guard !text.contains("\n\n") else { return text }

        let sentences = sentenceStrings(in: text)
        guard sentences.count >= 3 else { return text }

        let groups = groupSizes(for: sentences.count)
        var offset = 0
        let paragraphs = groups.compactMap { size -> String? in
            guard size > 0, offset < sentences.count else { return nil }
            let end = min(offset + size, sentences.count)
            defer { offset = end }
            return sentences[offset..<end].joined(separator: " ")
        }

        return paragraphs.joined(separator: "\n\n")
    }

    static func thoughtBlocks(_ text: String) -> [String] {
        format(text)
            .components(separatedBy: "\n\n")
            .filter { !$0.isEmpty }
    }

    private static func sentenceStrings(in text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(
            in: text.startIndex..<text.endIndex,
            options: [.bySentences, .substringNotRequired]
        ) { _, range, _, _ in
            let sentence = String(text[range])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
        }
        return sentences
    }

    private static func groupSizes(for sentenceCount: Int) -> [Int] {
        switch sentenceCount {
        case ...2:
            return [sentenceCount]
        case 3:
            return [2, 1]
        case 4:
            return [2, 1, 1]
        case 5:
            return [2, 1, 2]
        case 6:
            return [2, 1, 2, 1]
        case 7:
            return [2, 2, 1, 2]
        default:
            var groups = [2, 2]
            var remaining = sentenceCount - 4
            while remaining > 2 {
                groups.append(2)
                remaining -= 2
            }
            if remaining > 0 { groups.append(remaining) }
            return groups
        }
    }
}
