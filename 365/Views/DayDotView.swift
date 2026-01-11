import SwiftUI
import Inject

/// Represents the state of a single day dot.
enum DayState {
    case past
    case today
    case future
}

/// A single dot representing one day in the year.
struct DayDotView: View {
    @ObserveInjection var inject
    let dayOfYear: Int
    let year: Int
    let state: DayState
    let size: CGFloat
    let hasJournalEntry: Bool
    let isMarked: Bool

    var body: some View {
        ZStack {
            // The dot itself
            Circle()
                .fill(fillColor)
                .frame(width: dotSize, height: dotSize)
                .offset(x: offsetX, y: offsetY)

            // Journal entry indicator (small inner dot)
            if hasJournalEntry {
                Circle()
                    .fill(AppColors.textPrimary)
                    .frame(width: dotSize * 0.3, height: dotSize * 0.3)
                    .offset(x: offsetX, y: offsetY)
            }

            // Today highlight ring
            if state == .today {
                Circle()
                    .stroke(AppColors.todayAccent, lineWidth: 3)
                    .frame(width: size * 0.95, height: size * 0.95)
                    .offset(x: offsetX, y: offsetY)
            }

            // Future marker ring
            if state == .future && isMarked {
                Circle()
                    .stroke(AppColors.textSecondary, lineWidth: 1)
                    .frame(width: size * 0.75, height: size * 0.75)
                    .offset(x: offsetX, y: offsetY)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .enableInjection()
    }

    // MARK: - Computed Properties

    private var dotSize: CGFloat {
        // Base size with slight random variation for organic feel
        let baseSize: CGFloat = 0.55
        var generator = SeededRandomGenerator(seed: dayOfYear)
        let variation = CGFloat.random(in: -0.08...0.08, using: &generator)
        return size * (baseSize + variation)
    }

    private var offsetX: CGFloat {
        // Slight horizontal offset for hand-stamped feel
        var generator = SeededRandomGenerator(seed: dayOfYear * 2)
        return CGFloat.random(in: -1.5...1.5, using: &generator)
    }

    private var offsetY: CGFloat {
        // Slight vertical offset for hand-stamped feel
        var generator = SeededRandomGenerator(seed: dayOfYear * 3)
        return CGFloat.random(in: -1.5...1.5, using: &generator)
    }

    private var fillColor: Color {
        switch state {
        case .past, .today:
            return AppColors.dotPast
        case .future:
            return AppColors.dotFuture
        }
    }

    private var accessibilityLabel: String {
        guard let date = DateService.date(forYear: year, dayOfYear: dayOfYear) else {
            return "Day \(dayOfYear)"
        }
        let dateString = DateService.formattedDate(date)
        switch state {
        case .past:
            return "\(dateString), passed"
        case .today:
            return "\(dateString), today"
        case .future:
            return isMarked ? "\(dateString), marked" : "\(dateString), future"
        }
    }
}

// MARK: - Seeded Random Generator

/// A random number generator with a seed for consistent randomness
struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        state = UInt64(seed)
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

#Preview {
    HStack(spacing: 20) {
        DayDotView(dayOfYear: 1, year: 2026, state: .past, size: 40, hasJournalEntry: false, isMarked: false)
        DayDotView(dayOfYear: 2, year: 2026, state: .today, size: 40, hasJournalEntry: true, isMarked: false)
        DayDotView(dayOfYear: 3, year: 2026, state: .future, size: 40, hasJournalEntry: false, isMarked: true)
    }
    .padding()
}
