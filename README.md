<p align="center">
  <img src="Resources/AppIcon Small.jpeg" alt="Anderson App Icon" width="128">
</p>

<h1 align="center">Anderson</h1>

<p align="center">
  A Matrix-inspired macOS utility that displays RSS feeds and system monitoring widgets in a floating, always-on-top terminal window.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-green?style=flat-square" alt="Platform: macOS">
  <img src="https://img.shields.io/badge/Swift-5.0-orange?style=flat-square" alt="Swift 5.0">
  <img src="https://img.shields.io/badge/UI-SwiftUI-blue?style=flat-square" alt="SwiftUI">
  <img src="https://img.shields.io/badge/dependencies-none-brightgreen?style=flat-square" alt="No Dependencies">
</p>

---

## About

Anderson is a menu bar-only macOS app with a green-on-black terminal aesthetic. It renders a borderless, always-on-top window with three panels — system widgets, a fast-scrolling article feed, and a detail view for keyword-matched articles. Designed for ultrawide and secondary displays (optimized for 1920x480), it works on any resolution.

No external dependencies. Pure SwiftUI + Combine, built on macOS standard libraries.

## Features

### RSS Feed Aggregation
- Supports RSS 2.0 and Atom feeds
- Add, remove, enable, and disable feeds individually
- Configurable refresh interval (5 to 120 minutes)
- Per-feed keyword modes: **Global Only**, **Feed Only**, or **Combined**

### Keyword Matching Engine
- Case-insensitive matching across article titles and content
- Wildcard support: `*` (any characters) and `?` (single character)
- Global and per-feed positive/negative keyword lists
- Negative keywords completely filter out unwanted articles
- Matched articles sorted by priority (number of keyword hits)

### System Monitoring Widgets
| Widget | Update Rate | Description |
|--------|------------|-------------|
| Analog Clock | 10 Hz | Traditional clock face with smooth second hand |
| CPU | 2 sec | Real-time CPU usage with progress bar |
| Memory | 3 sec | RAM usage display |
| Network | 1 sec | Upload/download speeds |
| Storage | 30 sec | Disk space for mounted volumes |
| Uptime | 60 sec | Days, hours, and minutes since boot |

- Pin widgets to keep them always visible
- Non-pinned widgets rotate with smooth fade transitions
- Configurable rotation duration (3 to 30 seconds)

### Three-Panel Layout
- **Widget Panel (15%)** — Rotating system monitors
- **Search Panel (60%)** — Fast-scrolling feed of all articles
- **Detail Panel (40%)** — Slow-scrolling view of keyword-matched articles with highlighted tags

### Display Customization
- Font size (10–20 pt, SF Mono)
- Glow intensity (0–2.0x)
- Background transparency (0–100%)
- Independent scroll speeds for each panel
- Keyword pause duration
- Optional "janky" retro scroll effect

### Window Management
- Floating, borderless, always-on-top
- Draggable to any position or monitor
- Remembers placement per display across launches
- Appears on all Spaces

## Requirements

- macOS 12.0 or later
- Xcode 14+ (to build from source)

## Building

```bash
# Clone the repository
git clone https://github.com/yourusername/Anderson.git
cd Anderson

# Build
xcodebuild -scheme Anderson -configuration Debug build

# Or open in Xcode
open Anderson.xcodeproj
# Then press Cmd+R to build and run
```

## Usage

Anderson runs as a menu bar app — there is no Dock icon. Look for the menu bar item to access preferences or quit.

### Getting Started

1. Launch Anderson
2. Open **Preferences** from the menu bar
3. Go to the **RSS Feeds** tab and add your feeds
4. Go to the **Keywords** tab and add terms to watch for
5. Matched articles will appear in the Detail Panel with keyword tags highlighted

### Preferences

The settings window has five tabs:

| Tab | Controls |
|-----|----------|
| **General** | Display selection, background transparency, glow intensity, font size |
| **RSS Feeds** | Add/edit/remove feeds, per-feed keyword modes, refresh interval |
| **Keywords** | Global positive and negative keyword lists with wildcard support |
| **Display** | Scroll speeds, keyword pause duration, janky scroll toggle |
| **Widgets** | Enable/disable widgets, pin widgets, rotation duration |

## Architecture

```
Anderson/
├── AndersonApp.swift              App entry, AppDelegate, window management
├── Core/
│   ├── ContentView.swift          Three-panel responsive layout
│   ├── MatrixTheme.swift          Colors, fonts, glow effects
│   └── AppPreferences.swift       Singleton settings with UserDefaults
├── Models/
│   └── Article.swift              Article model, KeywordMatcher
├── Services/
│   └── RSSFeedService.swift       RSS/Atom fetching and parsing
└── Views/
    ├── Panels/
    │   ├── SearchPanel.swift      All-articles scrolling view
    │   ├── DetailPanel.swift      Matched-articles detail view
    │   └── WidgetPanel.swift      Widget rotation container
    ├── Widgets/
    │   ├── AnalogClockWidget.swift
    │   └── SystemWidgets.swift    CPU, Memory, Network, Storage, Uptime
    └── Preferences/
        └── PreferencesView.swift  Five-tab settings UI
```

**Key patterns:**
- **MVVM** with Combine for reactive state
- `AppPreferences.shared` singleton as single source of truth
- `@EnvironmentObject` injection throughout the view hierarchy
- `ObservableObject` services with `@Published` properties
- Zero external dependencies — only macOS system frameworks

## Known Limitations

- Network widget uses simulated data (full monitoring requires additional system permissions)
- Storage widget change tracking is simplified (no persistent database)
- Article images receive a basic green tint rather than full Matrix-style processing
- Launch-at-login requires manual system configuration

## License

This project is provided as-is for personal use.
