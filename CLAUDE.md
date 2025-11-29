# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Anderson** is a Matrix-inspired macOS utility application built with SwiftUI. It displays RSS feeds and system monitoring widgets in a floating, always-on-top window with a green-on-black terminal aesthetic. Optimized for 1920x480 external displays.

## Build Commands

### Building and Running
```bash
# Build the project
xcodebuild -scheme Anderson -configuration Debug build

# Run tests
xcodebuild -scheme Anderson -destination 'platform=macOS' test

# Build for release
xcodebuild -scheme Anderson -configuration Release build

# Clean build folder
xcodebuild clean -scheme Anderson
```

### Development in Xcode
- Open `Anderson.xcodeproj` in Xcode
- Minimum deployment target: macOS 12.0
- Press `⌘R` to build and run
- Press `⌘B` to build only
- Press `⌘U` to run tests

## Architecture

### Core Application Flow

**AndersonApp.swift** (App Entry)
- Creates menu bar-only app (no dock icon via `LSUIElement`)
- `AppDelegate` manages floating borderless window
- Window is always-on-top (`.floating` level), draggable, and remembers monitor placement
- Uses `@NSApplicationDelegateAdaptor` to integrate AppDelegate with SwiftUI lifecycle

**ContentView.swift** (Main Layout)
- Three-panel layout: WidgetPanel (15%) | SearchPanel (60%) | DetailPanel (40%)
- Panels separated by thin green dividers
- Dynamically calculates panel widths based on screen size
- Starts `RSSFeedService` on appear

### Data Architecture

**AppPreferences.swift** (Settings Management)
- Singleton (`AppPreferences.shared`) managing all user preferences
- Uses `@Published` properties that auto-persist to `UserDefaults`
- All views use `@EnvironmentObject` to access shared preferences
- Handles RSS feed configs, keywords, negative keywords, display settings, widget settings

**RSSFeedConfig Structure**:
- Supports three keyword modes: `globalOnly`, `feedOnly`, `combined`
- Each feed can have its own positive/negative keywords
- Feeds can be enabled/disabled individually

**Article.swift** (Data Model)
- Represents RSS articles with title, content, snippet, source, URL, publish date
- `KeywordMatcher` provides keyword matching with wildcard support (`*` and `?`)
- Articles track `matchedKeywords` and `priority` (count of matches)
- Negative keywords filter out unwanted articles

**RSSFeedService.swift** (Data Service)
- `ObservableObject` that fetches and parses RSS feeds
- Implements `XMLParserDelegate` for RSS/Atom parsing
- Publishes `allArticles` and `matchedArticles` arrays
- Automatically refetches based on `refreshInterval` preference
- Reprocesses articles when keywords change
- Respects per-feed keyword modes when matching

### View Components

**SearchPanel** - Fast-scrolling feed view showing all articles
**DetailPanel** - Slow-scrolling view showing only matched articles with keyword tags
**WidgetPanel** - Rotates through system widgets (clock, CPU, memory, network, storage, uptime)

**MatrixTheme.swift** provides:
- Color palette (`matrixGreen`, `darkGreen`, `backgroundColor`)
- Glow effects and pulsing animations
- Text styling with SF Mono font
- Keyword highlighting utilities

### Widget System

**WidgetPanel** manages widget rotation:
- Pinned widgets always visible (e.g., clock)
- Non-pinned widgets rotate every `widgetRotationDuration` seconds
- Smooth fade transitions between widgets

**Available Widgets**:
- `AnalogClockWidget` - Traditional clock face with smooth second hand (10Hz updates)
- `UptimeWidget` - System uptime (days/hours/minutes)
- `CPUWidget` - Real-time CPU usage with progress bar
- `MemoryWidget` - RAM usage display
- `NetworkWidget` - Upload/download speeds
- `StorageWidget` - Disk space for mounted volumes

Widgets use system APIs (`sysctl`, `host_statistics`, `Process.processInfo`) for metrics.

## Key Technical Details

### Window Management
- Window is borderless, transparent, and always-on-top
- Uses `collectionBehavior: [.canJoinAllSpaces, .fullScreenAuxiliary]`
- Position saved to UserDefaults by screen name (`LastScreenName`)
- Window frames set via DispatchQueue.main.async to avoid layout recursion

### RSS Feed Processing
1. `RSSFeedService` fetches enabled feeds via URLSession
2. XMLParser parses RSS 2.0 and Atom formats
3. Articles matched against appropriate keywords (global, feed-specific, or combined)
4. Negative keywords filter out unwanted articles completely
5. Matched articles sorted by priority (keyword match count)
6. Latest 100 articles kept in `allArticles`, latest 50 in `matchedArticles`

### Keyword Matching
- Case-insensitive regex-based matching
- Wildcards: `*` (any characters), `?` (single character)
- Matches checked in title + content
- Each feed can use different keyword sets based on `keywordMode`
- Negative keywords exclude articles from all results

### State Management Pattern
- `AppPreferences.shared` is the single source of truth
- Injected via `.environmentObject()` throughout view hierarchy
- RSS feed service observes preferences with Combine (`.sink()`)
- All preference changes auto-persist to UserDefaults

## Common Development Tasks

### Adding a New Widget
1. Create widget view in `Views/Widgets/SystemWidgets.swift`
2. Add widget name to `enabledWidgets` default set in AppPreferences.swift:112
3. Add case to widget rotation logic in WidgetPanel.swift
4. Widget should use `MatrixTheme` styling for consistency

### Modifying RSS Feed Logic
- RSS parsing happens in `RSSFeedService.parseFeed()`
- XMLParser delegate methods in RSSFeedService:226-274
- Keyword matching uses `KeywordMatcher.matchKeywords()` in Article.swift
- Feed keyword mode logic in `getKeywordsForFeed()` at RSSFeedService:152

### Adjusting Panel Layout
- Panel width calculations in ContentView.swift:64-76
- Adjust percentages to change panel proportions
- All panels use `GeometryReader` for responsive sizing

### Debugging RSS Feeds
- Service prints debug logs prefixed with emoji (🔄, 📡, 📰, 🔑, 🔍, ✅, 📊)
- Check console for feed fetch status and keyword matching results
- Example: "🔑 Using keywords for TechCrunch: Mode: combined"

## File Organization

```
Anderson/
├── Anderson/
│   ├── AndersonApp.swift          - App entry and window management
│   ├── Item.swift                 - Unused boilerplate (can be removed)
│   ├── Core/
│   │   ├── ContentView.swift      - Main three-panel layout
│   │   ├── MatrixTheme.swift      - Visual styling and effects
│   │   └── AppPreferences.swift   - Settings singleton
│   ├── Models/
│   │   └── Article.swift          - Article model and keyword matching
│   ├── Services/
│   │   └── RSSFeedService.swift   - RSS fetching and parsing
│   ├── Views/
│   │   ├── Panels/
│   │   │   ├── SearchPanel.swift  - Fast scrolling article list
│   │   │   ├── DetailPanel.swift  - Matched articles display
│   │   │   └── WidgetPanel.swift  - Widget rotation container
│   │   ├── Widgets/
│   │   │   ├── AnalogClockWidget.swift
│   │   │   └── SystemWidgets.swift
│   │   └── Preferences/
│   │       └── PreferencesView.swift - Settings UI (5 tabs)
│   └── Resources/
│       └── *.md                   - Documentation files
├── AndersonTests/                 - Unit tests
└── AndersonUITests/               - UI tests
```

## Important Implementation Notes

### RSS Feed Keyword Modes
The app supports three keyword modes per feed (AppPreferences.swift:173-185):
- **Global Only**: Use only global keywords from preferences
- **Feed Only**: Use only keywords defined for this specific feed
- **Combined**: Merge global and feed-specific keywords

When modifying keyword logic, ensure `getKeywordsForFeed()` and `getKeywordsForSource()` handle all three modes correctly.

### Negative Keywords
Negative keywords completely filter out articles (RSSFeedService.swift:126-127). Articles matching any negative keyword are excluded from both `allArticles` and `matchedArticles`. This is intentional design to reduce noise.

### Layout Recursion Prevention
Window frame setting is deferred to `DispatchQueue.main.async` (AndersonApp.swift:90-98) to prevent layout recursion warnings at app launch. Do not set window frames synchronously in `applicationDidFinishLaunching`.

### Timer Memory Management
All timers use `[weak self]` capture to prevent retain cycles (RSSFeedService.swift:63, WidgetPanel.swift). Widget timers must be invalidated in `onDisappear` to prevent leaks.

## Testing

### Unit Test Structure
- Tests located in `AndersonTests/AndersonTests.swift`
- UI tests in `AndersonUITests/`
- Key areas to test: keyword matching, article deduplication, priority sorting, date parsing

### Manual Testing Checklist
1. Add RSS feeds via Preferences → RSS Feeds tab
2. Add keywords via Preferences → Keywords tab
3. Verify articles appear in SearchPanel
4. Verify matched articles appear in DetailPanel with keyword tags
5. Test negative keywords filter out unwanted articles
6. Drag window to different monitors and verify position saved
7. Test widget rotation and pinning
8. Adjust all preference sliders and verify visual changes

## Known Limitations

- Network widget uses placeholder data (requires system permissions for real monitoring)
- Storage widget "recent changes" is simplified (would need persistent database)
- Images in DetailPanel have basic green tint only (full Matrix-style processing would require Core Image filters)
- Launch at login requires manual system configuration (no ServiceManagement integration)

## Performance Considerations

- RSS feeds refresh every 30 minutes by default (configurable 5-120 min)
- Clock widget updates 10x/sec for smooth second hand
- CPU widget updates every 2 sec
- Memory widget updates every 3 sec
- Scroll speeds are multipliers (1.0x = baseline, higher = faster)
- Limit articles to 100 (all) / 50 (matched) to prevent memory bloat
