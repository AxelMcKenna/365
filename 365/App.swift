import SwiftUI
import SwiftData

/// The main entry point for the 365 app.
/// Displays the current year as a grid of dots, one per day.
@main
struct App365: App {
    var body: some Scene {
        WindowGroup {
            YearView()
        }
        .modelContainer(for: JournalEntry.self)
    }
}
