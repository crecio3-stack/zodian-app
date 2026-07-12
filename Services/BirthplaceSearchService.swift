import Foundation
import Combine
import MapKit

struct BirthplaceSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    fileprivate let completion: MKLocalSearchCompletion

    var displayText: String {
        if subtitle.isEmpty {
            return title
        }

        return "\(title), \(subtitle)"
    }
}

struct BirthplaceResolution {
    let raw: String
    let normalized: String?
    let timezoneIdentifier: String?
}

@MainActor
final class BirthplaceSearchService: NSObject, ObservableObject {
    @Published var query: String = "" {
        didSet {
            updateQuery()
        }
    }

    @Published private(set) var suggestions: [BirthplaceSuggestion] = []
    @Published private(set) var isResolving = false

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    func clearSuggestions() {
        suggestions = []
    }

    func resolve(_ suggestion: BirthplaceSuggestion) async -> BirthplaceResolution {
        isResolving = true
        defer { isResolving = false }

        do {
            let request = MKLocalSearch.Request(completion: suggestion.completion)
            let response = try await MKLocalSearch(request: request).start()
            let mapItem = response.mapItems.first

            let normalized = normalizedPlaceString(from: mapItem) ?? suggestion.displayText
            let timezoneIdentifier = mapItem?.timeZone?.identifier

            return BirthplaceResolution(
                raw: suggestion.displayText,
                normalized: normalized,
                timezoneIdentifier: timezoneIdentifier
            )
        } catch {
            return BirthplaceResolution(
                raw: suggestion.displayText,
                normalized: suggestion.displayText,
                timezoneIdentifier: nil
            )
        }
    }

    private func updateQuery() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            suggestions = []
            completer.queryFragment = ""
            return
        }

        completer.queryFragment = trimmed
    }

    private func normalizedPlaceString(from mapItem: MKMapItem?) -> String? {
        guard let mapItem else { return nil }
        let placemark = mapItem.placemark

        let placeParts = [
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ]
            .compactMap { normalizedAddressPart($0) }

        if !placeParts.isEmpty {
            return placeParts.joined(separator: ", ")
        }

        if let title = normalizedAddressPart(placemark.title) {
            return title
        }

        return normalizedAddressPart(mapItem.name)
    }

    private func normalizedAddressPart(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

extension BirthplaceSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
            .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .prefix(6)
            .map {
                BirthplaceSuggestion(
                    title: $0.title,
                    subtitle: $0.subtitle,
                    completion: $0
                )
            }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
