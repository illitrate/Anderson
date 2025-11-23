# Matrix Monitor

A Matrix-inspired macOS utility for monitoring RSS feeds and system information with a distinctive green-on-black terminal aesthetic.

## Overview

Matrix Monitor is a floating, borderless window application designed for external monitors (optimized for 1920x480 resolution). It displays:

- **Fast-scrolling RSS feed articles** with keyword matching
- **Detailed view of matched articles** with slow, readable scrolling
- **System monitoring widgets** including clock, uptime, CPU, memory, network, and storage

## Features

### RSS Feed Monitoring
- Monitor multiple RSS feeds simultaneously
- Keyword-based filtering with wildcard support (* and ?)
- Articles matching keywords are highlighted and moved to detailed view
- Priority sorting based on number of keyword matches

### Visual Style
- Matrix-inspired green text on transparent dark background
- Glowing text effects with customizable intensity
- Pulsing highlights for matched keywords
- Janky scroll animation to simulate data streaming
- Monospaced SF Mono font

### System Widgets
- **Analog Clock**: Traditional clock face with hour, minute, and second hands
- **System Uptime**: Days, hours, and minutes since boot
- **CPU Usage**: Real-time CPU usage percentage with progress bar
- **Memory Usage**: RAM usage with visual indicator
- **Network Activity**: Upload and download speeds
- **Storage Info**: Disk space for volumes with recent changes

### Window Behavior
- Always-on-top floating window
- Transparent background (adjustable 0-100%)
- Remembers monitor placement between launches
- Draggable to any monitor
- No dock icon (menu bar only)

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Select "App" under macOS
4. Configure:
   - Product Name: `MatrixMonitor`
   - Interface: SwiftUI
   - Language: Swift
   - Organization Identifier: (your choice)

### 2. Add Source Files

Copy all the provided Swift files into your Xcode project:

- `MatrixMonitorApp.swift` - Main app entry point
- `ContentView.swift` - Main layout
- `MatrixTheme.swift` - Visual styling and colors
- `AppPreferences.swift` - Settings management
- `Article.swift` - Article and keyword matching
- `RSSFeedService.swift` - RSS feed fetching and parsing
- `SearchPanel.swift` - Fast scrolling feed panel
- `DetailPanel.swift` - Matched articles panel
- `WidgetPanel.swift` - Widget rotation container
- `AnalogClockWidget.swift` - Clock widget
- `SystemWidgets.swift` - All system monitoring widgets
- `PreferencesView.swift` - Settings interface

### 3. Configure Info.plist

Add these keys to your Info.plist:

```xml
<key>LSUIElement</key>
<true/>
<key>NSAppleEventsUsageDescription</key>
<string>Matrix Monitor needs access to system information for monitoring widgets.</string>
```

The `LSUIElement` key ensures the app runs without a dock icon.

### 4. Build and Run

1. Select your Mac as the target
2. Product → Build (⌘B)
3. Product → Run (⌘R)

## Usage

### First Launch

1. The app will appear in your menu bar (⚡︎ symbol)
2. The floating window will appear on your primary display
3. Click and drag to move it to your desired monitor
4. The window will resize to fit the monitor dimensions

### Adding RSS Feeds

1. Click the menu bar icon
2. Select "Preferences..."
3. Go to the "RSS Feeds" tab
4. Click "Add Feed"
5. Enter feed name and URL
6. Click "Add"

**Suggested RSS Feeds to try:**
- Technology: `https://news.ycombinator.com/rss`
- News: `http://rss.cnn.com/rss/cnn_topstories.rss`
- BBC: `http://feeds.bbci.co.uk/news/rss.xml`
- TechCrunch: `https://techcrunch.com/feed/`
- Ars Technica: `https://feeds.arstechnica.com/arstechnica/index`

### Adding Keywords

1. Open Preferences
2. Go to "Keywords" tab
3. Type a keyword and press Enter or click "Add"
4. Supported wildcards:
   - `*` matches any characters (e.g., `tech*` matches "technology", "technical")
   - `?` matches single character

**Example Keywords:**
- `artificial intelligence`
- `climate*`
- `election*`
- `crypto*`
- `space exploration`

### Customizing Appearance

**General Tab:**
- Background Transparency: Adjust opacity (0% = solid, 100% = fully transparent)
- Glow Intensity: Control text glow effect
- Font Size: Adjust text size (10-20pt)

**Display Tab:**
- Search Panel Speed: How fast articles scroll (0.5x - 10x)
- Detail Panel Speed: Reading speed for matched articles
- Keyword Pause Duration: How long to pause when keyword is found
- Janky Scroll Effect: Toggle irregular scrolling animation

**Widgets Tab:**
- Widget Rotation Duration: Seconds each widget displays
- Disk Space Threshold: Only show drives with changes > this amount
- Enable/Disable specific widgets
- Pin widgets to always be visible

### Keyboard Shortcuts

- `⌘,` - Open Preferences (when window is focused)
- Click window then press `⌘,` to open preferences
- Click menu bar icon for quick access

### Menu Bar Options

- **Show Window** - Brings window to front if hidden
- **Preferences...** - Opens settings window
- **Quit** - Exits the application

## Technical Details

### System Requirements

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later for building

### Display Optimization

The app is optimized for 1920x480 displays but will work on any resolution. Layout automatically adjusts:

- Widget Panel: ~15% of width (max 200px)
- Search Panel: ~60% of remaining width
- Detail Panel: ~40% of remaining width

### Performance Considerations

- RSS feeds refresh every 30 minutes by default (configurable 5-120 min)
- System widgets update at different intervals:
  - Clock: 10 times per second (smooth second hand)
  - CPU: Every 2 seconds
  - Memory: Every 3 seconds
  - Network: Every 1 second
  - Storage: Every 30 seconds
  - Uptime: Every 10 seconds

### Storage Management

- Keeps last 100 articles in memory
- Keeps last 50 matched articles
- No persistent storage (resets on restart)

## Troubleshooting

### Window Not Appearing
- Check if it's on another display
- Click "Show Window" in menu bar
- Restart the app

### RSS Feeds Not Loading
- Verify feed URL is correct
- Check network connection
- Ensure feed is enabled in preferences
- Some feeds may have rate limiting

### High CPU Usage
- Reduce search panel scroll speed
- Disable janky scroll effect
- Increase RSS refresh interval
- Disable unused widgets

### Text Too Small/Large
- Adjust font size in General preferences
- Optimize for your display resolution

## Known Limitations

1. **Network Monitoring**: Currently shows placeholder data. Full implementation requires additional system permissions.

2. **Storage Widget**: Shows all mounted volumes. The "recent changes" tracking requires persistent storage implementation.

3. **Image Processing**: Images in Detail Panel show with green tint but are not fully pixelated/monochrome. Full Matrix-style image processing would require Core Image filters.

4. **Launch at Login**: Must be configured manually through System Preferences → Users & Groups → Login Items.

## Future Enhancements

Potential features for future versions:

- [ ] Custom data sources beyond RSS (APIs, webhooks)
- [ ] Article history and search
- [ ] Export matched articles
- [ ] Multiple keyword groups with different highlights
- [ ] Customizable panel layouts
- [ ] Additional visual themes
- [ ] Sound effects for keyword matches
- [ ] Notification support for important keywords
- [ ] Integration with Shortcuts app
- [ ] AppleScript support

## Credits

Inspired by the search interface from *The Matrix* (1999).

Built with SwiftUI and love for retro terminal aesthetics.

## License

This is a personal project. Modify and use as you wish.

---

**Enjoy your Matrix-style monitoring dashboard!** 🟢⚡︎
