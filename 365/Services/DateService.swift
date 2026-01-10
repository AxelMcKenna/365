import Foundation

/// DateService provides all calendar-based calculations for the 365 app.
/// All calculations respect the user's current timezone and locale.
enum DateService {

    private static var calendar: Calendar {
        Calendar.current
    }

    // MARK: - Year Calculations

    /// Returns the current year.
    static var currentYear: Int {
        calendar.component(.year, from: Date())
    }

    /// Determines if a given year is a leap year.
    static func isLeapYear(_ year: Int) -> Bool {
        let components = DateComponents(year: year, month: 2, day: 29)
        guard let date = calendar.date(from: components) else { return false }
        return calendar.component(.month, from: date) == 2
    }

    /// Returns the number of days in a given year (365 or 366).
    static func daysInYear(_ year: Int) -> Int {
        isLeapYear(year) ? 366 : 365
    }

    // MARK: - Day of Year Calculations

    /// Returns the day of year (1-based) for a given date.
    static func dayOfYear(for date: Date) -> Int {
        calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    /// Returns today's day of year (1-based).
    static var todayDayOfYear: Int {
        dayOfYear(for: Date())
    }

    /// Returns the date for a given day of year in a specific year.
    static func date(forYear year: Int, dayOfYear: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.day = dayOfYear
        return calendar.date(from: components)
    }

    // MARK: - Formatting

    /// Formats a date as a readable string (e.g., "January 12").
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
}
