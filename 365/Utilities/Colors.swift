import SwiftUI

/// Monochrome palette with charcoal background and white accents.
enum AppColors {

    // MARK: - Background Colors

    /// Main dark green background color
    static let background = Color(red: 0.06, green: 0.14, blue: 0.10)

    /// Slightly lighter dark green for subtle contrast
    static let backgroundDark = Color(red: 0.10, green: 0.20, blue: 0.14)

    // MARK: - Accent Colors

    /// Primary accent color (cream)
    static let primaryAccent = Color(red: 0.98, green: 0.95, blue: 0.88)

    /// Secondary accent color (cream)
    static let deepPrimaryAccent = Color(red: 0.98, green: 0.95, blue: 0.88)

    // MARK: - Text Colors

    /// Cream for primary text
    static let textPrimary = Color(red: 0.98, green: 0.95, blue: 0.88)

    /// Softer cream for secondary text
    static let textSecondary = Color(red: 0.98, green: 0.95, blue: 0.88).opacity(0.7)

    // MARK: - Dot Colors

    /// Past day dots (cream)
    static let dotPast = Color(red: 0.98, green: 0.95, blue: 0.88)

    /// Future day dots (subtle cream)
    static let dotFuture = Color(red: 0.98, green: 0.95, blue: 0.88).opacity(0.25)

    /// Today highlight ring
    static let todayAccent = Color(red: 0.98, green: 0.95, blue: 0.88)
}
