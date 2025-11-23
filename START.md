# Getting Started with Matrix Monitor

## 🎯 What You Have

A complete, ready-to-build macOS application with:
- **12 Swift source files** implementing all functionality
- **4 documentation files** covering setup, usage, and reference
- **1 configuration file** (Info.plist) for app settings
- **~2,500 lines** of production-ready Swift code

## 🚀 Quick Start (5 Minutes)

### Step 1: Create Xcode Project
1. Open Xcode
2. File → New → Project
3. Choose **macOS → App**
4. Name it **MatrixMonitor**
5. Interface: **SwiftUI**, Language: **Swift**

### Step 2: Add Files
Drag all `.swift` files into your Xcode project, or:
1. Right-click project → New File
2. Choose Swift File
3. Copy/paste content from each file

### Step 3: Configure Info.plist
Add this to Info.plist:
```xml
<key>LSUIElement</key>
<true/>
```

### Step 4: Build & Run
Press **⌘R** or Product → Run

## 📁 File Descriptions

### Core Files (Must Have)
- `MatrixMonitorApp.swift` - App entry, menu bar, window management
- `ContentView.swift` - Main three-panel layout
- `MatrixTheme.swift` - All visual styling and effects

### Data & Logic
- `AppPreferences.swift` - User settings and persistence
- `Article.swift` - Article model and keyword matching
- `RSSFeedService.swift` - RSS feed fetching/parsing

### UI Panels
- `SearchPanel.swift` - Fast-scrolling article list
- `DetailPanel.swift` - Matched articles with details
- `WidgetPanel.swift` - System widget container

### Widgets
- `AnalogClockWidget.swift` - Traditional clock face
- `SystemWidgets.swift` - CPU, memory, network, storage, uptime

### Settings
- `PreferencesView.swift` - Complete settings interface

### Documentation
- `README.md` - Full user documentation
- `SETUP.md` - Detailed setup instructions
- `QUICKREF.md` - Quick reference guide
- `PROJECT_SUMMARY.md` - Technical overview

## 🎨 What It Looks Like

```
┌───────────────────────────────────────────────────────────────┐
│ ⚡ Matrix Monitor                                      [Menu] │
├──────────┬────────────────────────┬──────────────────────────┤
│  CLOCK   │  SEARCHING FEEDS...    │  MATCHED ARTICLES       │
│  [12:34] │  ▼ Fast scrolling      │  • Keyword: [AI]        │
│          │  • Article 1           │  • Headline here        │
│  UPTIME  │  • Article 2           │  • Content scrolling... │
│  2d 14h  │  • [MATCH!] Article    │  • Source: TechNews     │
│          │  • Article 4           │                         │
│  Rotate  │  • Article 5           │  ▼ Slow readable scroll │
│  [CPU]   │  ▼ Continues...        │                         │
└──────────┴────────────────────────┴──────────────────────────┘
```

All in glowing green (#00FF41) on transparent dark background!

## ⚙️ First-Time Setup

### 1. Launch the App
- Menu bar icon (⚡) appears
- Window displays on primary monitor
- All panels show "waiting" state

### 2. Add RSS Feeds
Menu Bar → Preferences → RSS Feeds Tab
- Click "Add Feed"
- Try: `https://news.ycombinator.com/rss`
- Add 3-5 feeds to start

### 3. Add Keywords
Keywords Tab
- Add: `AI`, `technology`, `space`, etc.
- Use wildcards: `tech*`, `climat*`
- Case insensitive matching

### 4. Adjust Display
Display Tab
- Search Speed: 2.0x (default)
- Detail Speed: 0.5x (default)
- Enable Janky Scroll: ✓

### 5. Configure Widgets
Widgets Tab
- Clock: ✓ Pinned
- Others: ✓ Enabled, rotating
- Rotation: 8 seconds

### 6. Move to Display
- Drag window to your 1920x480 monitor
- Window auto-resizes
- Position remembered

## 🎛️ Customization Examples

### For Reading Focus
- Background: 70% transparent
- Font Size: 16pt
- Glow: 0.8
- Search Speed: 1.5x
- Detail Speed: 0.3x

### For Quick Scanning
- Background: 85% transparent
- Font Size: 14pt
- Glow: 1.2
- Search Speed: 5x
- Detail Speed: 0.8x

### For Aesthetics
- Background: 90% transparent
- Font Size: 12pt
- Glow: 1.5
- Janky Scroll: ✓
- Multiple keywords

## 🐛 Troubleshooting

**Window not showing?**
→ Click "Show Window" in menu bar

**No articles appearing?**
→ Check RSS feed URLs are valid
→ Wait 30 seconds for first fetch

**Keywords not matching?**
→ Verify spelling (case doesn't matter)
→ Try wildcards: `*tech*`

**High CPU usage?**
→ Lower scroll speeds
→ Disable janky effect
→ Reduce enabled feeds

**Can't open preferences?**
→ Click window first, then ⌘,
→ Or use menu bar → Preferences

## 📚 Documentation Index

1. **START HERE** → This file (START.md)
2. **Setup Guide** → SETUP.md (detailed Xcode instructions)
3. **User Guide** → README.md (complete documentation)
4. **Quick Reference** → QUICKREF.md (keyboard shortcuts, tips)
5. **Technical Info** → PROJECT_SUMMARY.md (architecture, specs)

## 🎯 Next Steps

1. ✅ Build and run the app
2. ✅ Add your favorite RSS feeds
3. ✅ Set up keywords for your interests
4. ✅ Adjust visual preferences
5. ✅ Move to your 1920x480 display
6. ✅ Enjoy your Matrix dashboard!

## 💡 Pro Tips

- **Start simple**: 3 feeds, 5 keywords
- **Iterate**: Adjust speeds based on reading comfort
- **Pin favorites**: Pin widgets you check often
- **Experiment**: Try different transparency levels
- **Curate**: Remove noisy feeds, keep signal

## 🤝 Support

Need help?
1. Check QUICKREF.md for common issues
2. Review SETUP.md for detailed setup
3. See README.md for full documentation

## ⚡ The Matrix Experience

Your window will display:
- **Green glowing text** (authentic Matrix aesthetic)
- **Fast-scrolling articles** (Neo's search program)
- **Keyword highlights** (pulsing, underlined)
- **System monitoring** (terminal-style widgets)
- **Smooth animations** (with optional jankiness)

All running on your external monitor, always on top, perfectly transparent.

## 🎬 Inspired By

The iconic scene in *The Matrix* (1999) where Neo runs a search program on his Unix terminal, looking for news articles containing specific keywords.

Now you have that power on your desk. 🟢⚡

---

**Ready? Open Xcode and let's build this!** 

Start with SETUP.md for step-by-step instructions.
