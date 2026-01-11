import Foundation
import SwiftData

@available(iOS 18, *)
@Model
final class JournalEntry {
    #Unique([\JournalEntry.year, \JournalEntry.dayOfYear])

    var year: Int
    var dayOfYear: Int
    var text: String
    var updatedAt: Date

    init(year: Int, dayOfYear: Int, text: String = "", updatedAt: Date = .now) {
        self.year = year
        self.dayOfYear = dayOfYear
        self.text = text
        self.updatedAt = updatedAt
    }
}

extension JournalEntry {
    static func predicate(year: Int, dayOfYear: Int) -> Predicate<JournalEntry> {
        #Predicate<JournalEntry> { entry in
            entry.year == year && entry.dayOfYear == dayOfYear
        }
    }

    static func predicate(year: Int) -> Predicate<JournalEntry> {
        #Predicate<JournalEntry> { entry in
            entry.year == year
        }
    }
}
