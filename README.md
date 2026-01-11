# 365

A minimal iOS app that visualizes the passage of the current year using a grid of dots — one dot per day.

## Concept

**365** does one thing beautifully: it shows you where you are in the year.

- Each dot represents one day
- Past days and today are automatically filled
- Future days remain unfilled and de-emphasized
- Minimal interaction keeps the focus on time and rhythm

## Features

- **Auto-fills** all dots up to and including today
- **Auto-updates** when the day changes (midnight)
- **15-column grid** creates a steady visual cadence
- **Today highlighted** with an accent ring
- **Month and week rhythm** via subtle dot-size changes
- **Future day markers** (up to three) via long-press on future dots
- **Journaling** for past/today days
- **Pinch-to-zoom** toggles density between overview and detail
- **Leap year aware** (365 or 366 dots)
- **Fully accessible** with VoiceOver support
- **Light & dark mode** support
- **Premium, minimal styling** with art-deco typography

## Requirements

- iOS 18.0+
- Xcode 15.0+
- SwiftUI
- SwiftData

## Project Structure

```
365/
├── 365.xcodeproj/
└── 365/
    ├── App.swift                 # Main entry point (@main)
    ├── Services/
    │   ├── DateService.swift     # Calendar calculations & date utilities
    │   └── MarkerStore.swift     # Future day marker persistence
    ├── Models/
    │   └── JournalEntry.swift    # SwiftData model
    ├── Views/
    │   ├── YearView.swift        # Main view with header & auto-update logic
    │   ├── DotGridView.swift     # Responsive 15-column LazyVGrid
    │   ├── DayDotView.swift      # Individual day dot component
    │   └── JournalView.swift     # Journal editor for a day
    ├── Utilities/
    │   ├── Typography.swift      # Art-deco font definitions
    │   └── Colors.swift          # Monochrome palette
    └── Assets.xcassets/
```

## How to Run

1. Open the project in Xcode:
   ```bash
   open 365.xcodeproj
   ```

2. Select an iPhone simulator from the device dropdown (e.g., iPhone 15)

3. Press `Cmd + R` to build and run

The app launches directly into the year view.

## Implementation Details

### Date Handling
- Uses `Calendar.current` for all date calculations
- Respects user's timezone and locale
- Correctly handles leap years via `Calendar.ordinality`

### Auto-Update
The UI updates automatically when the date changes using:
- `TimelineView(.everyMinute)` for periodic updates
- `UIApplication.significantTimeChangeNotification` for midnight/timezone changes

### Accessibility
Every dot includes meaningful accessibility labels:
- "January 12, passed"
- "January 13, today"
- "January 14, future" / "January 14, marked"

### Design Philosophy
- Minimal and calm
- Monochrome palette with restrained accents
- Art-deco typography
- Responsive grid adapts to all iPhone sizes
- Persistence only for journaling and future markers

## What's Excluded

By design, this app does **not** include:
- User authentication
- Cloud sync
- Multiple years / year picker
- Settings or preferences
- Export/import
- Streaks or gamification
- Interactive dot toggling

If a feature doesn't directly support "seeing the year pass day by day," it's not here.

## License

See [LICENSE](LICENSE) for details.
