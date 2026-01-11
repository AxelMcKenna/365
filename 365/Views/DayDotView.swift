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
                    .stroke(AppColors.todayAccent, lineWidth: 1.5)
                    .frame(width: size * 0.9, height: size * 0.9)
                    .offset(x: offsetX, y: offsetY)
            }

            // Future marker ring
            if state == .future && isMarked {
                Circle()
                    .stroke(AppColors.textSecondary, lineWidth: 0.75)
                    .frame(width: size * 0.7, height: size * 0.7)
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
        let baseSize: CGFloat = 0.38
        return size * baseSize
    }

    private var offsetX: CGFloat {
        0
    }

    private var offsetY: CGFloat {
        0
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
