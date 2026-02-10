//
//  PreferencesView.swift
//  Anderson
//
//  Preferences window with tabbed interface
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences

    @SceneStorage("PreferencesSelectedTab") private var selectedTab: Tab = .general

    enum Tab: String, Hashable {
        case general, rss, keywords, display, widgets
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(Tab.general)
                .environmentObject(preferences)
            
            RSSFeedsPreferencesView()
                .tabItem {
                    Label("RSS Feeds", systemImage: "antenna.radiowaves.left.and.right")
                }
                .tag(Tab.rss)
                .environmentObject(preferences)
            
            KeywordsPreferencesView()
                .tabItem {
                    Label("Keywords", systemImage: "text.word.spacing")
                }
                .tag(Tab.keywords)
                .environmentObject(preferences)
            
            DisplayPreferencesView()
                .tabItem {
                    Label("Display", systemImage: "display")
                }
                .tag(Tab.display)
                .environmentObject(preferences)
            
            WidgetsPreferencesView()
                .tabItem {
                    Label("Widgets", systemImage: "square.grid.2x2")
                }
                .tag(Tab.widgets)
                .environmentObject(preferences)
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - General Preferences

struct GeneralPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    @State private var availableDisplays: [DisplayInfo] = []
    @State private var selectedDisplay: DisplayInfo?

    var body: some View {
        Form {
            Section(header: Text("Display").font(.headline)) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Display")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if availableDisplays.isEmpty {
                        Text("No displays detected")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(availableDisplays) { display in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: display.isMain ? "display.2" : "display")
                                            .foregroundColor(display.isMain ? .blue : .secondary)
                                        Text(display.name)
                                            .font(.body)
                                        if display.isMain {
                                            Text("(Primary)")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Text("\(Int(display.width)) × \(Int(display.height))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                
                                if selectedDisplay?.id == display.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(8)
                            .background(selectedDisplay?.id == display.id ? Color.green.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                            .onTapGesture {
                                selectDisplay(display)
                            }
                        }
                    }

                    Button(action: refreshDisplays) {
                        Label("Refresh Displays", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
            }

            Section(header: Text("Appearance").font(.headline)) {
                VStack(alignment: .leading) {
                    Text("Background Transparency: \(Int(preferences.backgroundTransparency * 100))%")
                    Slider(value: $preferences.backgroundTransparency, in: 0...1)
                }

                VStack(alignment: .leading) {
                    Text("Glow Intensity: \(String(format: "%.1f", preferences.glowIntensity))")
                    Slider(value: $preferences.glowIntensity, in: 0...2)
                }

                VStack(alignment: .leading) {
                    Text("Font Size: \(Int(preferences.fontSize))pt")
                    Slider(value: $preferences.fontSize, in: 10...20)
                }
            }
        }
        .padding()
        .onAppear {
            refreshDisplays()
        }
    }
 
    private func refreshDisplays() {
        availableDisplays = getAvailableDisplays()
        // Set initial selection from preferences or default to main screen
        if let savedID = preferences.selectedDisplayID,
           let saved = availableDisplays.first(where: { $0.id == savedID }) {
            selectedDisplay = saved
        } else if let main = availableDisplays.first(where: { $0.isMain }) {
            selectedDisplay = main
            preferences.selectedDisplayID = main.id
        }
    }

    private func selectDisplay(_ display: DisplayInfo) {
        selectedDisplay = display
        preferences.selectedDisplayID = display.id

        // Notify the app to move the window
        NotificationCenter.default.post(
            name: NSNotification.Name("MoveToDisplay"),
            object: nil,
            userInfo: ["displayID": display.id]
        )
    }

    private func getAvailableDisplays() -> [DisplayInfo] {
        return NSScreen.screens.enumerated().map { index, screen in
            DisplayInfo(
                id: screen.localizedName,
                name: screen.localizedName,
                width: screen.frame.width,
                height: screen.frame.height,
                isMain: screen == NSScreen.main
            )
        }
    }
}

struct DisplayInfo: Identifiable, Equatable {
    let id: String
    let name: String
    let width: CGFloat
    let height: CGFloat
    let isMain: Bool
}

// MARK: - RSS Feeds Preferences

struct RSSFeedsPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    @State private var newFeedURL = ""
    @State private var newFeedName = ""

    @State private var editingFeed: RSSFeedConfig? = nil
    @State private var editFeedURL = ""
    @State private var editFeedName = ""
    @State private var editFeedKeywordMode: KeywordMode = .globalOnly
    
    @State private var keywordEditingFeed: RSSFeedConfig? = nil
    
    private func normalizedHTTPURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if !trimmed.lowercased().hasPrefix("http://") && !trimmed.lowercased().hasPrefix("https://") {
            if let url = URL(string: "https://" + trimmed) { return url }
        }
        return URL(string: trimmed)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("RSS Feeds")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    print("Add Feed button clicked")
                    presentAddFeedWindow()
                }) {
                    Label("Add Feed", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            List {
                ForEach($preferences.rssFeeds) { $feed in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Toggle("", isOn: $feed.enabled)
                                .labelsHidden()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(feed.name)
                                    .font(.headline)
                                Text(feed.url)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                editingFeed = feed
                                editFeedName = feed.name
                                editFeedURL = feed.url
                                editFeedKeywordMode = feed.keywordMode
                                presentEditFeedWindow()
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.plain)
                            .help("Edit feed settings")
                            
                            Button(action: {
                                if !preferences.isPreferencesClosing {
                                    preferences.rssFeeds.removeAll { $0.id == feed.id }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .help("Delete feed")
                        }
                        
                        // Keyword mode info row
                        HStack(spacing: 8) {
                            Image(systemName: keywordModeIcon(for: feed.keywordMode))
                                .font(.caption)
                                .foregroundColor(keywordModeColor(for: feed.keywordMode))
                            
                            Text(keywordModeSummary(for: feed))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                keywordEditingFeed = feed
                                presentKeywordsWindow()
                            }) {
                                Text("Keywords…")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.leading, 28) // Align with feed name
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        editingFeed = feed
                        editFeedName = feed.name
                        editFeedURL = feed.url
                        editFeedKeywordMode = feed.keywordMode
                        presentEditFeedWindow()
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("Refresh Interval: \(Int(preferences.refreshInterval / 60)) minutes")
                Slider(value: $preferences.refreshInterval, in: 300...7200, step: 300)
            }
            .padding()
        }
    }

    // MARK: - Window Presentation Functions

    private func presentAddFeedWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Add RSS Feed"
        window.center()
        window.level = .popUpMenu  // Appear above floating windows
        window.isReleasedWhenClosed = false

        let hostingView = NSHostingView(rootView: AddFeedSheet(
            feedURL: $newFeedURL,
            feedName: $newFeedName,
            onAdd: {
                if preferences.isPreferencesClosing { return }
                if let url = normalizedHTTPURL(from: newFeedURL),
                   let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                    let feed = RSSFeedConfig(url: url.absoluteString, name: newFeedName)
                    preferences.rssFeeds.append(feed)
                    newFeedURL = ""
                    newFeedName = ""
                    window.close()
                } else {
                    print("Invalid feed URL entered: \(newFeedURL)")
                }
            },
            onCancel: {
                window.close()
            }
        ))

        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
    }

    private func presentEditFeedWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Edit RSS Feed"
        window.center()
        window.level = .popUpMenu  // Appear above floating windows
        window.isReleasedWhenClosed = false

        let hostingView = NSHostingView(rootView: EditFeedSheet(
            feedURL: $editFeedURL,
            feedName: $editFeedName,
            keywordMode: $editFeedKeywordMode,
            onSave: {
                if preferences.isPreferencesClosing { return }
                guard var current = editingFeed else { return }
                let trimmed = editFeedURL.trimmingCharacters(in: .whitespacesAndNewlines)
                var finalURLString: String? = nil
                if !trimmed.isEmpty {
                    if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
                        finalURLString = URL(string: trimmed)?.absoluteString
                    } else {
                        finalURLString = URL(string: "https://" + trimmed)?.absoluteString
                    }
                }
                if let urlString = finalURLString, let url = URL(string: urlString), let scheme = url.scheme?.lowercased(), ["http","https"].contains(scheme) {
                    current.name = editFeedName
                    current.url = url.absoluteString
                    current.keywordMode = editFeedKeywordMode
                    if let idx = preferences.rssFeeds.firstIndex(where: { $0.id == current.id }) {
                        preferences.rssFeeds[idx] = current
                    }
                    window.close()
                } else {
                    print("Invalid feed URL entered: \(editFeedURL)")
                }
            },
            onCancel: {
                window.close()
            }
        ))

        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
    }

    private func presentKeywordsWindow() {
        guard let feed = keywordEditingFeed,
              let index = preferences.rssFeeds.firstIndex(where: { $0.id == feed.id }) else { return }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 450),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Keywords for \(feed.name)"
        window.center()
        window.level = .popUpMenu  // Appear above floating windows
        window.isReleasedWhenClosed = false

        let hostingView = NSHostingView(rootView: FeedKeywordsSheet(
            feed: $preferences.rssFeeds[index],
            onDone: {
                window.close()
            }
        ))

        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
    }
    
    private func keywordModeIcon(for mode: KeywordMode) -> String {
        switch mode {
        case .globalOnly: return "globe"
        case .feedOnly: return "doc.text"
        case .combined: return "arrow.triangle.merge"
        }
    }
    
    private func keywordModeColor(for mode: KeywordMode) -> Color {
        switch mode {
        case .globalOnly: return .blue
        case .feedOnly: return .orange
        case .combined: return .purple
        }
    }
    
    private func keywordModeSummary(for feed: RSSFeedConfig) -> String {
        switch feed.keywordMode {
        case .globalOnly:
            return "Using global keywords"
        case .feedOnly:
            let count = feed.keywords.count
            if count == 0 {
                return "Feed-specific (no keywords set)"
            } else {
                return "Feed-specific (\(count) keyword\(count == 1 ? "" : "s"))"
            }
        case .combined:
            let count = feed.keywords.count
            if count == 0 {
                return "Combined (global only)"
            } else {
                return "Combined (global + \(count) feed)"
            }
        }
    }
}

struct AddFeedSheet: View {
    @Binding var feedURL: String
    @Binding var feedName: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    private var normalizedURL: URL? {
        let trimmed = feedURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if !trimmed.lowercased().hasPrefix("http://") && !trimmed.lowercased().hasPrefix("https://") {
            if let url = URL(string: "https://" + trimmed) { return url }
        }
        return URL(string: trimmed)
    }

    private var isValid: Bool {
        if feedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        guard let url = normalizedURL, let scheme = url.scheme?.lowercased() else { return false }
        return ["http", "https"].contains(scheme)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add RSS Feed")
                .font(.title2)
                .bold()
            
            TextField("Feed Name", text: $feedName)
                .textFieldStyle(.roundedBorder)
            
            HStack(spacing: 8) {
                TextField("Feed URL", text: $feedURL)
                    .textFieldStyle(.roundedBorder)
                if let url = normalizedURL, let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if !feedURL.isEmpty && normalizedURL == nil {
                Text("Please enter a valid URL (http/https). Example: https://example.com/feed.xml")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Text("You can configure feed-specific keywords after adding the feed.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Add", action: onAdd)
                    .keyboardShortcut(.return)
                    .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 400, height: 220)
    }
}

struct EditFeedSheet: View {
    @Binding var feedURL: String
    @Binding var feedName: String
    @Binding var keywordMode: KeywordMode
    let onSave: () -> Void
    let onCancel: () -> Void

    private var normalizedURL: URL? {
        let trimmed = feedURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if !trimmed.lowercased().hasPrefix("http://") && !trimmed.lowercased().hasPrefix("https://") {
            if let url = URL(string: "https://" + trimmed) { return url }
        }
        return URL(string: trimmed)
    }

    private var isValid: Bool {
        if feedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        guard let url = normalizedURL, let scheme = url.scheme?.lowercased() else { return false }
        return ["http", "https"].contains(scheme)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit RSS Feed")
                .font(.title2)
                .bold()

            TextField("Feed Name", text: $feedName)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 8) {
                TextField("Feed URL", text: $feedURL)
                    .textFieldStyle(.roundedBorder)
                if let url = normalizedURL, let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            if !feedURL.isEmpty && normalizedURL == nil {
                Text("Please enter a valid URL (http/https). Example: https://example.com/feed.xml")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            // Keyword mode picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Keyword Mode")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("", selection: $keywordMode) {
                    ForEach(KeywordMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(keywordMode.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.escape)

                Spacer()

                Button("Save", action: onSave)
                    .keyboardShortcut(.return)
                    .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 400, height: 280)
    }
}

// MARK: - Feed Keywords Sheet

struct FeedKeywordsSheet: View {
    @Binding var feed: RSSFeedConfig
    let onDone: () -> Void
    
    @State private var newKeyword = ""
    @State private var newNegativeKeyword = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Keywords for \(feed.name)")
                        .font(.title2)
                        .bold()
                    
                    // Keyword mode picker
                    HStack(spacing: 8) {
                        Text("Mode:")
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $feed.keywordMode) {
                            ForEach(KeywordMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 300)
                    }
                }
                
                Spacer()
                
                Button("Done", action: onDone)
                    .keyboardShortcut(.return)
            }
            .padding()
            
            Divider()
            
            // Mode description
            HStack {
                Image(systemName: modeIcon)
                    .foregroundColor(modeColor)
                Text(feed.keywordMode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(modeColor.opacity(0.1))
            
            if feed.keywordMode == .globalOnly {
                // Show message that feed-specific keywords won't be used
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundColor(.blue.opacity(0.5))
                    Text("This feed uses global keywords only")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Change the mode above to add feed-specific keywords")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Show keyword editors
                HStack(spacing: 0) {
                    // Positive Keywords
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Positive Keywords")
                                .font(.headline)
                        }
                        
                        HStack {
                            TextField("Add keyword...", text: $newKeyword)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { addKeyword() }
                            
                            Button(action: addKeyword) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(newKeyword.isEmpty)
                            .buttonStyle(.plain)
                        }
                        
                        List {
                            ForEach(feed.keywords, id: \.self) { keyword in
                                HStack {
                                    Text(keyword)
                                    Spacer()
                                    Button(action: {
                                        feed.keywords.removeAll { $0 == keyword }
                                    }) {
                                        Image(systemName: "xmark.circle")
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .listStyle(.bordered)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    // Negative Keywords
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Negative Keywords")
                                .font(.headline)
                        }
                        
                        HStack {
                            TextField("Add keyword...", text: $newNegativeKeyword)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { addNegativeKeyword() }
                            
                            Button(action: addNegativeKeyword) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(newNegativeKeyword.isEmpty)
                            .buttonStyle(.plain)
                        }
                        
                        List {
                            ForEach(feed.negativeKeywords, id: \.self) { keyword in
                                HStack {
                                    Text(keyword)
                                    Spacer()
                                    Button(action: {
                                        feed.negativeKeywords.removeAll { $0 == keyword }
                                    }) {
                                        Image(systemName: "xmark.circle")
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .listStyle(.bordered)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Help text
            Divider()
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                Text("Wildcards supported: * (any characters) and ? (single character)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
        }
        .frame(width: 600, height: 450)
    }
    
    private var modeIcon: String {
        switch feed.keywordMode {
        case .globalOnly: return "globe"
        case .feedOnly: return "doc.text"
        case .combined: return "arrow.triangle.merge"
        }
    }
    
    private var modeColor: Color {
        switch feed.keywordMode {
        case .globalOnly: return .blue
        case .feedOnly: return .orange
        case .combined: return .purple
        }
    }
    
    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !feed.keywords.contains(trimmed) {
            feed.keywords.append(trimmed)
            newKeyword = ""
        }
    }
    
    private func addNegativeKeyword() {
        let trimmed = newNegativeKeyword.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !feed.negativeKeywords.contains(trimmed) {
            feed.negativeKeywords.append(trimmed)
            newNegativeKeyword = ""
        }
    }
}

// MARK: - Keywords Preferences (Global)

struct KeywordsPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    @State private var newKeyword = ""
    @State private var newNegativeKeyword = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header explaining global keywords
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.blue)
                Text("Global Keywords")
                    .font(.headline)
                Spacer()
                Text("Applied to feeds using Global or Combined mode")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            
            // Positive Keywords Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Positive Keywords")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("Show articles matching these • Wildcards: * and ?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                HStack {
                    TextField("Add positive keyword...", text: $newKeyword)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addKeyword()
                        }
                    
                    Button(action: addKeyword) {
                        Label("Add", systemImage: "plus")
                    }
                    .disabled(newKeyword.isEmpty)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(preferences.keywords, id: \.self) { keyword in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(keyword)
                                .font(.body)
                            
                            Spacer()
                            
                            Button(action: {
                                preferences.keywords.removeAll { $0 == keyword }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 120)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Negative Keywords Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Negative Keywords")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("Hide articles matching these • Wildcards: * and ?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                HStack {
                    TextField("Add negative keyword...", text: $newNegativeKeyword)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addNegativeKeyword()
                        }
                    
                    Button(action: addNegativeKeyword) {
                        Label("Add", systemImage: "plus")
                    }
                    .disabled(newNegativeKeyword.isEmpty)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(preferences.negativeKeywords, id: \.self) { keyword in
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            
                            Text(keyword)
                                .font(.body)
                            
                            Spacer()
                            
                            Button(action: {
                                preferences.negativeKeywords.removeAll { $0 == keyword }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 120)
            }
            
            Spacer()
        }
    }
    
    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !preferences.keywords.contains(trimmed) {
            preferences.keywords.append(trimmed)
            newKeyword = ""
        }
    }
    
    private func addNegativeKeyword() {
        let trimmed = newNegativeKeyword.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !preferences.negativeKeywords.contains(trimmed) {
            preferences.negativeKeywords.append(trimmed)
            newNegativeKeyword = ""
        }
    }
}

// MARK: - Display Preferences

struct DisplayPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        Form {
            Section(header: Text("Scroll Settings").font(.headline)) {
                VStack(alignment: .leading) {
                    Text("Search Panel Speed: \(String(format: "%.1fx", preferences.searchPanelScrollSpeed))")
                    Slider(value: $preferences.searchPanelScrollSpeed, in: 0.5...10)
                }
                
                VStack(alignment: .leading) {
                    Text("Detail Panel Speed: \(String(format: "%.1fx", preferences.detailPanelScrollSpeed))")
                    Slider(value: $preferences.detailPanelScrollSpeed, in: 0.1...2)
                }
                
                VStack(alignment: .leading) {
                    Text("Keyword Pause Duration: \(String(format: "%.1fs", preferences.keywordPauseDuration))")
                    Slider(value: $preferences.keywordPauseDuration, in: 0.5...5)
                }
                
                Toggle("Enable Janky Scroll Effect", isOn: $preferences.jankyScrollEnabled)
            }
        }
        .padding()
    }
}

// MARK: - Widgets Preferences

struct WidgetsPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    
    let availableWidgets = [
        ("clock", "Clock"),
        ("uptime", "System Uptime"),
        ("cpu", "CPU Usage"),
        ("memory", "Memory Usage"),
        ("network", "Network Activity"),
        ("storage", "Storage Info")
    ]
    
    var body: some View {
            Form {
                VStack {
                Section(header: Text("Widget Settings").font(.headline)) {
                    VStack(alignment: .leading) {
                        Text("Widget Scroll Speed: \(Int(preferences.widgetRotationDuration))s per widget")
                        Slider(value: $preferences.widgetRotationDuration, in: 3...30, step: 1)
                        Text("Time for each widget to scroll through the panel")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Disk Space Change Threshold: \(String(format: "%.1f GB", preferences.diskSpaceChangeThreshold))")
                        Slider(value: $preferences.diskSpaceChangeThreshold, in: 1...50)
                    }
                }
                
                Section(header: Text("Enabled Widgets").font(.headline)) {
                    ForEach(availableWidgets, id: \.0) { widget in
                        HStack {
                            Toggle(widget.1, isOn: Binding(
                                get: { preferences.enabledWidgets.contains(widget.0) },
                                set: { enabled in
                                    if enabled {
                                        preferences.enabledWidgets.insert(widget.0)
                                    } else {
                                        preferences.enabledWidgets.remove(widget.0)
                                        // Also unpin if disabling
                                        preferences.pinnedWidgets.remove(widget.0)
                                    }
                                }
                            ))
                            
                            Spacer()
                            
                            if preferences.enabledWidgets.contains(widget.0) {
                                Toggle("Pinned", isOn: Binding(
                                    get: { preferences.pinnedWidgets.contains(widget.0) },
                                    set: { pinned in
                                        if pinned {
                                            preferences.pinnedWidgets.insert(widget.0)
                                        } else {
                                            preferences.pinnedWidgets.remove(widget.0)
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PreferencesView()
        .environmentObject(AppPreferences.shared)
}
