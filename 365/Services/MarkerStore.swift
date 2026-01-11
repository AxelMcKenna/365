import Foundation
import SwiftUI

struct FutureDayMarker: Codable, Equatable {
    let year: Int
    let dayOfYear: Int
    let createdAt: Date
}

final class MarkerStore: ObservableObject {
    @Published private(set) var markers: [FutureDayMarker] = []

    private let storageKey = "futureDayMarkers"
    private let year: Int

    init(year: Int) {
        self.year = year
        load()
        normalizeAndPersistIfNeeded()
    }

    func isMarked(dayOfYear: Int) -> Bool {
        markers.contains { $0.dayOfYear == dayOfYear }
    }

    func toggle(dayOfYear: Int) {
        if let index = markers.firstIndex(where: { $0.dayOfYear == dayOfYear }) {
            markers.remove(at: index)
            persist()
            return
        }

        let newMarker = FutureDayMarker(year: year, dayOfYear: dayOfYear, createdAt: Date())
        markers.append(newMarker)
        markers = normalized(markers, limit: 3)
        persist()
    }

    func pruneExpired(todayDayOfYear: Int) {
        let filtered = markers.filter { $0.dayOfYear > todayDayOfYear }
        if filtered != markers {
            markers = filtered
            persist()
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            markers = []
            return
        }

        if let decoded = try? JSONDecoder().decode([FutureDayMarker].self, from: data) {
            markers = decoded
        } else {
            markers = []
        }
    }

    private func normalizeAndPersistIfNeeded() {
        let normalizedMarkers = normalized(markers, limit: 3)
        if normalizedMarkers != markers {
            markers = normalizedMarkers
            persist()
        }
    }

    private func normalized(_ source: [FutureDayMarker], limit: Int) -> [FutureDayMarker] {
        let maxDay = DateService.daysInYear(year)
        var seenDays = Set<Int>()
        let filtered = source
            .filter { $0.year == year && (1...maxDay).contains($0.dayOfYear) }
            .sorted { $0.createdAt < $1.createdAt }
            .filter { marker in
                if seenDays.contains(marker.dayOfYear) {
                    return false
                }
                seenDays.insert(marker.dayOfYear)
                return true
            }

        if filtered.count <= limit {
            return filtered
        }

        return Array(filtered.suffix(limit))
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(markers) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
