# 365

A minimal iOS app that visualizes the passage of the current year using a grid of dots — one dot per day.

## Concept

**365** does one thing beautifully: it shows you where you are in the year.

- Each dot represents one day
- Past days and today are automatically filled
- Future days remain unfilled and de-emphasized
- No user input, no interaction — just pure visualization

## Features

- **Auto-fills** all dots up to and including today
- **Auto-updates** when the day changes (midnight)
- **7-column grid** creates a weekly rhythm
- **Today highlighted** with an accent ring
- **Leap year aware** (365 or 366 dots)
- **Fully accessible** with VoiceOver support
- **Light & dark mode** support
- **Minimal, monospaced design** inspired by typewriter aesthetics

## Requirements

- iOS 18.0+
- Xcode 15.0+
- SwiftUI
- SwiftData (uses `#Unique`, available in iOS 18+)

## Project Structure

```
365/
├── 365.xcodeproj/
└── 365/
    ├── App.swift                 # Main entry point (@main)
    ├── Services/
    │   └── DateService.swift     # Calendar calculations & date utilities
    ├── Views/
    │   ├── YearView.swift        # Main view with header & auto-update logic
    │   ├── DotGridView.swift     # Responsive 7-column LazyVGrid
    │   └── DayDotView.swift      # Individual day dot component
    ├── Utilities/
    │   └── Typography.swift      # Monospaced font definitions
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
- "January 14, future"

### Design Philosophy
- Minimal and calm
- System colors only (accent color for today)
- Monospaced typography throughout
- Responsive grid adapts to all iPhone sizes
- No persistence needed (all state derived from current date)

## What's Excluded

By design, this app does **not** include:
- User authentication
- Cloud sync
- Multiple years / year picker
- Settings or preferences
- Notes or journaling
- Export/import
- Streaks or gamification
- Interactive dot toggling

If a feature doesn't directly support "seeing the year pass day by day," it's not here.

## License

See [LICENSE](LICENSE) for details.
