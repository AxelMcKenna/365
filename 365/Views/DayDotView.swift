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

    var body: some View {
        ZStack {
            // The dot itself
            Circle()
                .fill(fillColor)
                .frame(width: dotSize, height: dotSize)

            // Today highlight ring
            if state == .today {
                Circle()
                    .stroke(Color.accentColor, lineWidth: 2)
                    .frame(width: size * 0.9, height: size * 0.9)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Computed Properties

    private var dotSize: CGFloat {
        switch state {
        case .past, .today:
            return size * 0.6
        case .future:
            return size * 0.35
        }
    }

    private var fillColor: Color {
        switch state {
        case .past, .today:
            return .primary
        case .future:
            return .primary.opacity(0.2)
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
            return "\(dateString), future"
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        DayDotView(dayOfYear: 1, year: 2026, state: .past, size: 40)
        DayDotView(dayOfYear: 2, year: 2026, state: .today, size: 40)
        DayDotView(dayOfYear: 3, year: 2026, state: .future, size: 40)
    }
    .padding()
}
