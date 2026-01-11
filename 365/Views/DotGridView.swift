import SwiftUI
import SwiftData
import Inject

/// The main grid of dots representing all days in the current year.
struct DotGridView: View {
    @ObserveInjection var inject
    let year: Int
    let todayDayOfYear: Int

    @Query private var journalEntries: [JournalEntry]
    @StateObject private var markerStore: MarkerStore

    private let columns = 15

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
            let spacing: CGFloat = 12
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
                    NavigationLink(value: DayDestination(year: year, dayOfYear: day, isFuture: state == .future)) {
                        DayDotView(
                            dayOfYear: day,
                            year: year,
                            state: state,
                            size: dotSize,
                            hasJournalEntry: journaledDays.contains(day),
                            isMarked: isMarked
                        )
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                        guard state == .future else { return }
                        markerStore.toggle(dayOfYear: day)
                    })
                    .id("\(year)-\(day)")
                }
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 2)
        }
        .onAppear {
            markerStore.pruneExpired(todayDayOfYear: todayDayOfYear)
        }
        .onChange(of: todayDayOfYear) { _, newValue in
            markerStore.pruneExpired(todayDayOfYear: newValue)
        }
        .enableInjection()
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
