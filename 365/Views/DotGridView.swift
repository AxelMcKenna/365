import SwiftUI
import SwiftData

/// The main grid of dots representing all days in the current year.
struct DotGridView: View {
    let year: Int
    let todayDayOfYear: Int

    @Query private var journalEntries: [JournalEntry]
    @StateObject private var markerStore: MarkerStore
    @State private var density: GridDensity = .overview
    @State private var hapticTrigger = 0
    @State private var lastHapticDay: Int?

    private let columns = 15
    private let baseSpacing: CGFloat = 6
    private let verticalPadding: CGFloat = 2
    private let zoomInThreshold: CGFloat = 1.2
    private let zoomOutThreshold: CGFloat = 0.9

    init(year: Int, todayDayOfYear: Int) {
        self.year = year
        self.todayDayOfYear = todayDayOfYear
        _journalEntries = Query(filter: JournalEntry.predicate(year: year))
        _markerStore = StateObject(wrappedValue: MarkerStore(year: year))
    }

    private var journaledDays: Set<Int> {
        Set(journalEntries.map(\.dayOfYear))
    }

    var body: some View {
        GeometryReader { geometry in
            let totalDays = DateService.daysInYear(year)
            let spacing: CGFloat = baseSpacing
            let rawAvailableWidth = geometry.size.width - (CGFloat(columns - 1) * spacing)
            let availableWidth = rawAvailableWidth.isFinite ? max(0, rawAvailableWidth) : 0
            let dotSize = max(1, availableWidth / CGFloat(columns))

            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(dotSize), spacing: spacing), count: columns),
                spacing: spacing
            ) {
                ForEach(1...totalDays, id: \.self) { day in
                    let state = stateForDay(day)
                    let isMarked = state == .future && markerStore.isMarked(dayOfYear: day)
                    let isMonthStart = isFirstDayOfMonth(year: year, dayOfYear: day)
                    let isWeekStart = isMonday(year: year, dayOfYear: day)
                    NavigationLink(value: DayDestination(year: year, dayOfYear: day, isFuture: state == .future)) {
                        DayDotView(
                            dayOfYear: day,
                            year: year,
                            state: state,
                            size: dotSize,
                            hasJournalEntry: journaledDays.contains(day),
                            isMarked: isMarked,
                            isMonthStart: isMonthStart,
                            isWeekStart: isWeekStart
                        )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        guard state == .future else { return }
                        markerStore.toggle(dayOfYear: day)
                    })
                    .id("\(year)-\(day)")
                }
            }
            .scaleEffect(densityScale, anchor: .center)
            .animation(.easeInOut(duration: 0.2), value: density)
            .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { value in
                let cellSize = dotSize + spacing
                let adjustedY = value.location.y - verticalPadding
                guard value.location.x >= 0, adjustedY >= 0 else { return }

                let column = Int(value.location.x / cellSize)
                let row = Int(adjustedY / cellSize)
                guard column >= 0, column < columns, row >= 0 else { return }

                let day = (row * columns) + column + 1
                guard day >= 1, day <= totalDays else { return }

                let xInCell = value.location.x.truncatingRemainder(dividingBy: cellSize)
                let yInCell = adjustedY.truncatingRemainder(dividingBy: cellSize)
                let radius = dotSize * 0.5
                let dx = xInCell - radius
                let dy = yInCell - radius
                guard (dx * dx + dy * dy) <= (radius * radius) else { return }
                guard day != lastHapticDay else { return }

                lastHapticDay = day
                hapticTrigger += 1
            }.onEnded { _ in
                lastHapticDay = nil
            })
            .simultaneousGesture(MagnificationGesture().onEnded { value in
                switch density {
                case .overview:
                    if value > zoomInThreshold {
                        density = .detail
                    }
                case .detail:
                    if value < zoomOutThreshold {
                        density = .overview
                    }
                }
            })
            .padding(.horizontal, 0)
            .padding(.vertical, verticalPadding)
            .sensoryFeedback(.selection, trigger: hapticTrigger)
        }
        .onAppear {
            markerStore.pruneExpired(todayDayOfYear: todayDayOfYear)
        }
        .onChange(of: todayDayOfYear) { _, newValue in
            markerStore.pruneExpired(todayDayOfYear: newValue)
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

    private func isFirstDayOfMonth(year: Int, dayOfYear: Int) -> Bool {
        guard let date = DateService.date(forYear: year, dayOfYear: dayOfYear) else {
            return false
        }
        return Calendar.current.component(.day, from: date) == 1
    }

    private func isMonday(year: Int, dayOfYear: Int) -> Bool {
        guard let date = DateService.date(forYear: year, dayOfYear: dayOfYear) else {
            return false
        }
        return Calendar.current.component(.weekday, from: date) == 2
    }

    private var densityScale: CGFloat {
        switch density {
        case .overview:
            return 1.0
        case .detail:
            return 1.35
        }
    }
}

private enum GridDensity {
    case overview
    case detail
}

struct DayDestination: Hashable {
    let year: Int
    let dayOfYear: Int
    let isFuture: Bool
}

#Preview {
    NavigationStack {
        DotGridView(year: 2026, todayDayOfYear: 11)
            .padding()
    }
    .modelContainer(for: JournalEntry.self, inMemory: true)
}
