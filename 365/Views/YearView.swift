import SwiftUI
import Inject

/// The main view displaying the current year as a grid of dots.
/// Automatically updates when the date changes (at midnight).
struct YearView: View {
    @ObserveInjection var inject
    @State private var currentDate = Date()

    var body: some View {
        NavigationStack {
            TimelineView(.everyMinute) { context in
                let year = DateService.currentYear
                let todayDayOfYear = DateService.todayDayOfYear

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 4) {
                        Text(String(year))
                            .font(Typography.largeTitle)
                            .foregroundStyle(AppColors.textPrimary)
                            .tracking(1)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 48)

                    // Dot Grid
                    DotGridView(year: year, todayDayOfYear: todayDayOfYear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .id(year)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
            }
            .navigationDestination(for: DayDestination.self) { destination in
                JournalView(
                    year: destination.year,
                    dayOfYear: destination.dayOfYear,
                    isFuture: destination.isFuture
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            // Force refresh on significant time changes (midnight, timezone changes)
            currentDate = Date()
        }
        .enableInjection()
    }
}

#Preview {
    YearView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
