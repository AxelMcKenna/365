import SwiftUI

/// Represents the state of a single day dot.
enum DayState {
    case past
    case today
    case future
}

/// A single dot representing one day in the year.
struct DayDotView: View {
    let dayOfYear: Int
    let year: Int
    let state: DayState
    let size: CGFloat
    let hasJournalEntry: Bool
    let isMarked: Bool
    let isMonthStart: Bool
    let isWeekStart: Bool

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
                    .frame(width: size * 0.9 * ringScale, height: size * 0.9 * ringScale)
                    .offset(x: offsetX, y: offsetY)
            }

            // Future marker ring
            if state == .future && isMarked {
                Circle()
                    .stroke(AppColors.textSecondary, lineWidth: 0.75)
                    .frame(width: size * 0.7 * ringScale, height: size * 0.7 * ringScale)
                    .offset(x: offsetX, y: offsetY)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Computed Properties

    private var dotSize: CGFloat {
        let baseSize: CGFloat = 0.304
        let monthScale: CGFloat = isMonthStart ? 1.5 : 1.0
        return size * baseSize * monthScale * weekScale
    }

    private var ringScale: CGFloat {
        let emphasisScale = (isMonthStart ? 1.5 : 1.0) * weekScale
        return emphasisScale * 0.85
    }

    private var weekScale: CGFloat {
        isWeekStart ? 1.3 : 1.0
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

#Preview {
    HStack(spacing: 20) {
        DayDotView(dayOfYear: 1, year: 2026, state: .past, size: 40, hasJournalEntry: false, isMarked: false, isMonthStart: true, isWeekStart: false)
        DayDotView(dayOfYear: 2, year: 2026, state: .today, size: 40, hasJournalEntry: true, isMarked: false, isMonthStart: false, isWeekStart: true)
        DayDotView(dayOfYear: 3, year: 2026, state: .future, size: 40, hasJournalEntry: false, isMarked: true, isMonthStart: false, isWeekStart: false)
    }
    .padding()
}
