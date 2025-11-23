# Project Setup Guide

## File Organization in Xcode

When you create the Xcode project, organize the files into groups for better maintainability:

```
MatrixMonitor/
├── App/
│   ├── MatrixMonitorApp.swift
│   ├── Info.plist
│   └── Assets.xcassets
│
├── Core/
│   ├── ContentView.swift
│   ├── MatrixTheme.swift
│   └── AppPreferences.swift
│
├── Models/
│   └── Article.swift
│
├── Services/
│   └── RSSFeedService.swift
│
├── Views/
│   ├── Panels/
│   │   ├── SearchPanel.swift
│   │   ├── DetailPanel.swift
│   │   └── WidgetPanel.swift
│   │
│   ├── Widgets/
│   │   ├── AnalogClockWidget.swift
│   │   └── SystemWidgets.swift
│   │
│   └── Preferences/
│       └── PreferencesView.swift
│
└── Resources/
    └── README.md
```

## Step-by-Step Xcode Setup

### 1. Create New Project

1. **Open Xcode**
2. **File → New → Project...**
3. Select **App** (under macOS section)
4. Click **Next**

### 2. Configure Project Settings

**Product Name:** MatrixMonitor
**Team:** (Select your team or leave as None for local development)
**Organization Identifier:** com.yourname (or your preference)
**Interface:** SwiftUI
**Language:** Swift
**Storage:** None
**Include Tests:** Uncheck both

Click **Next** and choose a location to save.

### 3. Add Files to Project

#### Method 1: Drag and Drop
1. In Finder, locate all the .swift files
2. Drag them into the Xcode project navigator
3. Ensure "Copy items if needed" is checked
4. Click **Finish**

#### Method 2: Create Files in Xcode
For each file:
1. Right-click on the group where you want to add it
2. Select **New File...**
3. Choose **Swift File**
4. Name it appropriately
5. Copy and paste the code from the provided files

### 4. Configure Info.plist

**In Xcode 14+:**
1. Select your project in the navigator
2. Select the MatrixMonitor target
3. Go to the **Info** tab
4. Click the **+** button to add new keys:
   - **Application is agent (UIElement)**: YES
   - **Privacy - AppleEvents Sending Usage Description**: "Matrix Monitor needs access to system information for monitoring widgets."

**Or replace Info.plist:**
- Locate Info.plist in your project
- Replace its contents with the provided Info.plist file

### 5. Set Deployment Target

1. Select project in navigator
2. Select MatrixMonitor target
3. General tab
4. Set **Minimum Deployment** to macOS 12.0 or later

### 6. Configure Signing

1. In the **Signing & Capabilities** tab
2. Check **Automatically manage signing**
3. Select your Team (or sign in to Xcode with Apple ID)

### 7. Build Settings (Optional but Recommended)

1. Select project → Build Settings
2. Search for "Optimization Level"
3. Set Debug to "No Optimization [-Onone]"
4. Set Release to "Optimize for Speed [-O]"

## Running the App

### First Build

1. **Select target:** MatrixMonitor (My Mac)
2. **Build:** ⌘B or Product → Build
3. **Fix any build errors** (usually import or typing issues)
4. **Run:** ⌘R or Product → Run

### Expected Behavior on First Launch

1. Menu bar icon (⚡︎) appears in top-right
2. Floating window appears on primary display
3. Window shows "WAITING FOR MATCHES..." in Detail Panel
4. Widget panel shows clock (pinned) and rotates other widgets
5. Search panel is empty (no RSS feeds configured yet)

## Initial Configuration

### Add Sample RSS Feeds

1. Click menu bar icon
2. Select "Preferences..."
3. Go to "RSS Feeds" tab
4. Click "Add Feed" for each:

**Technology News:**
- Name: Hacker News
- URL: https://news.ycombinator.com/rss

**General News:**
- Name: BBC News
- URL: http://feeds.bbci.co.uk/news/rss.xml

**Tech News:**
- Name: TechCrunch
- URL: https://techcrunch.com/feed/

### Add Sample Keywords

Go to "Keywords" tab and add:
- AI
- technology
- climate
- space
- crypto*
- election*

### Adjust Visual Settings

Go to "General" tab:
- Background Transparency: 80%
- Glow Intensity: 1.0
- Font Size: 14pt

## Common Build Issues and Solutions

### Issue: "Cannot find type 'RSSFeedConfig' in scope"
**Solution:** Make sure AppPreferences.swift is added to the project and the RSSFeedConfig struct is defined at the bottom of that file.

### Issue: "Use of unresolved identifier 'MatrixTheme'"
**Solution:** Ensure MatrixTheme.swift is added to the project and imported if necessary.

### Issue: Window not appearing
**Solution:** 
- Check Console for errors (⌘⇧Y to show debug area)
- Verify LSUIElement is set to YES in Info.plist
- Check if window is appearing on another display

### Issue: "Sandbox: rsync deny file-read-data"
**Solution:** 
- Go to Signing & Capabilities
- Disable App Sandbox (for development)
- Or add necessary entitlements for network access

### Issue: Memory warnings or crashes
**Solution:**
- Reduce number of articles stored (lower limits in RSSFeedService)
- Increase RSS refresh interval
- Disable unused widgets

## Development Tips

### Debugging

**View Debug Hierarchy:**
- Debug → View Debugging → Capture View Hierarchy
- Useful for checking layout issues

**Print Statements:**
```swift
print("Debug: Article matched - \(article.title)")
```

**Breakpoints:**
- Click line number in Xcode to add breakpoint
- Helpful for tracing code execution

### Hot Reload (Preview)

SwiftUI Previews work for individual components:
```swift
#Preview {
    AnalogClockWidget()
        .frame(width: 200, height: 200)
        .background(MatrixTheme.backgroundColor)
}
```

### Testing on Different Screen Sizes

1. Run app
2. Move to different displays
3. Window should auto-resize
4. Test at various resolutions

### Performance Monitoring

**Instruments:**
1. Product → Profile (⌘I)
2. Choose "Time Profiler"
3. Record while app is running
4. Analyze CPU usage

## Packaging for Distribution

### Create Release Build

1. Product → Archive
2. Distribute App
3. Select distribution method:
   - **Developer ID:** For distribution outside App Store
   - **Mac App Store:** For App Store submission
   - **Copy App:** For local distribution

### Export as .app

1. After building in Release mode
2. Go to Products folder:
   - Right-click MatrixMonitor.app
   - Show in Finder
3. Copy .app to Applications

## Backup and Version Control

### Recommended .gitignore

```
# Xcode
*.xcuserstate
xcuserdata/
*.xcworkspace/xcuserdata/
DerivedData/
.DS_Store

# Build
build/
*.app
*.dSYM.zip
*.dSYM

# CocoaPods (if used)
Pods/
```

### Git Setup

```bash
git init
git add .
git commit -m "Initial Matrix Monitor implementation"
```

## Next Steps

Once everything is working:

1. **Customize:** Adjust colors, speeds, layouts to your preference
2. **Extend:** Add new widgets or data sources
3. **Optimize:** Profile and improve performance
4. **Share:** Package and share with others

## Support and Resources

**Apple Documentation:**
- SwiftUI: https://developer.apple.com/xcode/swiftui/
- macOS Development: https://developer.apple.com/macos/

**SwiftUI Tutorials:**
- Apple's SwiftUI Tutorials
- Hacking with Swift
- SwiftUI by Example

**RSS Feed Parsing:**
- XMLParser documentation
- RSS 2.0 Specification

---

Happy coding! If you encounter issues, refer to the README.md or Apple's developer documentation.
