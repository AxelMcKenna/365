import SwiftUI

/// Typography constants for the 365 app.
/// Uses monospaced system fonts for a typewriter-like aesthetic.
enum Typography {

    /// Large title font with monospaced design (for the year).
    static let largeTitle: Font = .system(.largeTitle, design: .monospaced).weight(.medium)

    /// Body font with monospaced digits (for day counts).
    static let monoBody: Font = .system(.body, design: .monospaced).monospacedDigit()

    /// Caption font with monospaced digits.
    static let monoCaption: Font = .system(.caption, design: .monospaced).monospacedDigit()
}
