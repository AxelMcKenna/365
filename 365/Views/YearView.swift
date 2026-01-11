import SwiftUI

/// The main view displaying the current year as a grid of dots.
/// Automatically updates when the date changes (at midnight).
struct YearView: View {
    @State private var currentDate = Date()

    var body: some View {
        TimelineView(.everyMinute) { context in
            let year = DateService.currentYear
            let todayDayOfYear = DateService.todayDayOfYear
            let totalDays = DateService.daysInYear(year)

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Text(String(year))
                        .font(Typography.largeTitle)
                        .foregroundStyle(.primary)

                    Text("\(todayDayOfYear) / \(totalDays)")
                        .font(Typography.monoCaption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Dot Grid
                DotGridView(year: year, todayDayOfYear: todayDayOfYear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            // Force refresh on significant time changes (midnight, timezone changes)
            currentDate = Date()
        }
    }
}

#Preview {
    YearView()
}
