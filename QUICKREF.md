# Anderson - Quick Reference

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘,` | Open Preferences (window must be focused) |
| Click menu bar icon | Access app menu |
| Drag window | Move to different display |

## Menu Bar Commands

- **Show Window** - Bring window to front
- **Preferences...** - Open settings window
- **Quit** - Exit application

## Preferences Quick Reference

### General Tab

| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Background Transparency | 0-100% | 80% | Window opacity level |
| Glow Intensity | 0-2.0 | 1.0 | Text glow effect strength |
| Font Size | 10-20pt | 14pt | Base text size |

### RSS Feeds Tab

**Actions:**
- Add Feed: Click `+` button
- Remove Feed: Click trash icon
- Enable/Disable: Toggle switch next to feed
- Refresh Interval: 5-120 minutes (default: 30)

**Feed Format:**
- Supports RSS 2.0 and Atom feeds
- Requires valid XML feed URL

### Keywords Tab

**Wildcard Support:**
- `*` = Match any characters
  - Example: `tech*` matches "tech", "technology", "technical"
- `?` = Match single character
  - Example: `c?t` matches "cat", "cot", "cut"

**Matching:**
- Case insensitive by default
- Partial matches allowed
- Multiple keywords combine with OR logic

### Display Tab

| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Search Panel Speed | 0.5-10x | 2.0x | How fast articles scroll |
| Detail Panel Speed | 0.1-2x | 0.5x | Reading speed for matches |
| Keyword Pause Duration | 0.5-5s | 1.0s | Pause when keyword found |
| Janky Scroll Effect | On/Off | On | Irregular scroll animation |

### Widgets Tab

**Widget Rotation:**
- Duration: 3-30 seconds per widget
- Pinned widgets always visible
- Unpinned widgets rotate through

**Available Widgets:**
- ☑ Clock (pinned by default)
- ☑ System Uptime
- ☑ CPU Usage
- ☑ Memory Usage  
- ☑ Network Activity
- ☑ Storage Info

**Storage Widget:**
- Threshold: 1-50 GB
- Only shows drives with recent changes exceeding threshold
- Helps manage display of many external drives

## Panel Layout

```
┌─────────────────────────────────────────────────────────┐
│  WIDGETS  │    SEARCH PANEL     │    DETAIL PANEL      │
│  (15%)    │       (50%)         │       (35%)          │
│           │                     │                      │
│  [Clock]  │  Fast scrolling     │  Matched articles   │
│  [Pinned] │  RSS articles       │  with full content  │
│           │                     │                      │
│  Rotating │  Keyword matching   │  Slow readable      │
│  Widgets  │  happens here       │  scrolling          │
│           │                     │                      │
└─────────────────────────────────────────────────────────┘
```

## Visual Indicators

### Search Panel
- **Normal article:** Dim green border
- **Matched article:** Bright green border, pulsing glow
- **Keyword highlight:** Underlined, pulsing text
- **Match count:** Shows in brackets `[2 matches]`

### Detail Panel
- **Keyword tags:** Shown at top in brackets `[keyword]`
- **Article info:** Source, relative time
- **Content:** Scrolls automatically at readable pace
- **Images:** Displayed with green tint and reduced opacity

## Color Scheme

| Element | Color | Hex |
|---------|-------|-----|
| Primary Text | Bright Green | #00FF41 |
| Dim Text | Medium Green | #00CC33 |
| Dark Text/Lines | Dark Green | #006619 |
| Background | Green-tinted Black | #0A0F0A |
| Highlight | Pulsing Bright Green | Animated |

## System Widget Details

### Clock
- **Type:** Analog clock face
- **Update Rate:** 10Hz (smooth second hand)
- **Display:** Hour, minute, second hands + digital time

### Uptime
- **Format:** Days, hours, minutes
- **Update Rate:** 10 seconds
- **Source:** System kernel boot time

### CPU
- **Metric:** Overall CPU usage percentage
- **Update Rate:** 2 seconds
- **Display:** Percentage + progress bar

### Memory
- **Metrics:** Used/Total GB and percentage
- **Update Rate:** 3 seconds
- **Calculation:** Active + Inactive + Wired memory

### Network
- **Metrics:** Download/Upload speeds
- **Update Rate:** 1 second
- **Units:** Auto-scaling (B/s, KB/s, MB/s)

### Storage
- **Display:** Volume name + free space
- **Update Rate:** 30 seconds
- **Filter:** Only volumes with changes > threshold

## Performance Tips

### Reduce CPU Usage
1. Lower search panel scroll speed
2. Disable janky scroll effect
3. Increase RSS refresh interval (60+ minutes)
4. Disable unused widgets
5. Reduce number of enabled feeds

### Improve Readability
1. Increase font size (16-18pt)
2. Reduce background transparency (60-70%)
3. Lower glow intensity (0.5-0.8)
4. Slow down detail panel speed

### Optimize for Small Display
1. Use 1920x480 optimized layout
2. Pin only clock widget
3. Increase widget rotation speed (4-5s)
4. Use smaller font size (11-13pt)
5. Limit keyword highlights

## Common Use Cases

### News Monitoring
**Keywords:** `breaking`, `urgent`, `alert`, `developing`
**Feeds:** Major news outlets (BBC, CNN, Reuters)
**Settings:** Fast search scroll, 1s pause

### Tech News
**Keywords:** `AI`, `startup*`, `funding`, `launch*`, `release*`
**Feeds:** TechCrunch, Hacker News, Ars Technica
**Settings:** Medium scroll speed, highlight tech terms

### Financial Monitoring
**Keywords:** `stock*`, `market*`, `crypto*`, `bitcoin`, `fed*`
**Feeds:** Financial news, market updates
**Settings:** Slow detail scroll for reading

### General Awareness
**Keywords:** Your interests (e.g., `space`, `climate`, `science`)
**Feeds:** Mix of general and specialized feeds
**Settings:** Balanced speeds, multiple keywords

## RSS Feed Recommendations

### Technology
- Hacker News: `https://news.ycombinator.com/rss`
- TechCrunch: `https://techcrunch.com/feed/`
- Ars Technica: `https://feeds.arstechnica.com/arstechnica/index`
- The Verge: `https://www.theverge.com/rss/index.xml`

### News
- BBC: `http://feeds.bbci.co.uk/news/rss.xml`
- Reuters: `https://www.reutersagency.com/feed/`
- NPR: `https://feeds.npr.org/1001/rss.xml`

### Science
- Scientific American: `http://rss.sciam.com/ScientificAmerican-Global`
- NASA: `https://www.nasa.gov/rss/dyn/breaking_news.rss`
- New Scientist: `https://www.newscientist.com/feed/home`

### Finance
- Bloomberg: `https://www.bloomberg.com/feed/podcast/etf-report`
- Financial Times: `https://www.ft.com/?format=rss`

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| Window disappeared | Click "Show Window" in menu bar |
| Feeds not loading | Check feed URL, verify network connection |
| Text unreadable | Increase font size, reduce transparency |
| High CPU | Lower scroll speeds, disable janky effect |
| Keywords not matching | Check case, verify wildcard syntax |
| Widgets not rotating | Verify widgets are enabled but not pinned |
| Too many storage widgets | Increase disk space threshold |

## Keyboard Focus Tips

The window must have focus for `⌘,` to work:
1. Click anywhere in the window
2. Press `⌘,` to open preferences

Or use menu bar:
1. Click menu bar icon (⚡︎)
2. Select "Preferences..."

## Monitor Placement

**To move to different display:**
1. Click and drag window titlebar area
2. Move to desired monitor
3. Release - window snaps to monitor dimensions
4. Position remembered on next launch

**For 1920x480 display:**
- Window automatically fills display
- Layout optimized for ultra-wide aspect ratio
- All panels sized proportionally

## Best Practices

1. **Start Simple:** Add 2-3 feeds and 3-5 keywords initially
2. **Iterate:** Adjust speeds and keywords based on your usage
3. **Monitor Performance:** Watch CPU usage, adjust if needed
4. **Curate Feeds:** Remove low-signal feeds, add high-quality sources
5. **Refine Keywords:** Update keywords as your interests evolve

## Advanced Tips

- **Multiple keyword strategies:** Use broad terms (`tech*`) for discovery, specific terms for filtering
- **Source diversity:** Mix general and specialized feeds for balanced coverage
- **Time optimization:** Set refresh during low-activity periods
- **Widget pinning:** Pin frequently-checked widgets (clock, CPU)
- **Transparency tuning:** Lower for readability, higher for aesthetic

---

For detailed setup instructions, see SETUP.md
For full documentation, see README.md

**Anderson** - Terminal aesthetics meet modern monitoring 🟢⚡︎
