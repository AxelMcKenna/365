import SwiftUI

/// The main grid of dots representing all days in the current year.
struct DotGridView: View {
    let year: Int
    let todayDayOfYear: Int

    private let columns = 7

    var body: some View {
        GeometryReader { geometry in
            let totalDays = DateService.daysInYear(year)
            let spacing: CGFloat = 4
            let availableWidth = geometry.size.width - (CGFloat(columns - 1) * spacing)
            let dotSize = availableWidth / CGFloat(columns)

            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(dotSize), spacing: spacing), count: columns),
                    spacing: spacing
                ) {
                    ForEach(1...totalDays, id: \.self) { day in
                        DayDotView(
                            dayOfYear: day,
                            year: year,
                            state: stateForDay(day),
                            size: dotSize
                        )
                        .id("\(year)-\(day)")
                    }
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func stateForDay(_ day: Int) -> DayState {
        if day < todayDayOfYear {
            return .past
        } else if day == todayDayOfYear {
            return .today
        } else {
            return .future
        }
    }
}

#Preview {
    DotGridView(year: 2026, todayDayOfYear: 11)
        .padding()
}
