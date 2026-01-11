import SwiftUI

/// Monochrome palette with charcoal background and white accents.
enum AppColors {

    // MARK: - Background Colors

    /// Main charcoal background color
    static let background = Color(red: 0.12, green: 0.12, blue: 0.12)

    /// Slightly lighter charcoal for subtle contrast
    static let backgroundDark = Color(red: 0.16, green: 0.16, blue: 0.16)

    // MARK: - Accent Colors

    /// Primary accent color (white)
    static let primaryAccent = Color.white

    /// Secondary accent color (white)
    static let deepPrimaryAccent = Color.white

    // MARK: - Text Colors

    /// White for primary text
    static let textPrimary = Color.white

    /// Softer white for secondary text
    static let textSecondary = Color.white.opacity(0.7)

    // MARK: - Dot Colors

    /// Past day dots (white)
    static let dotPast = Color.white

    /// Future day dots (subtle white)
    static let dotFuture = Color.white.opacity(0.25)

    /// Today highlight ring
    static let todayAccent = Color.white
}
