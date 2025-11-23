//
//  PreferencesView.swift
//  MatrixMonitor
//
//  Preferences window with tabbed interface
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        TabView {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .environmentObject(preferences)
            
            RSSFeedsPreferencesView()
                .tabItem {
                    Label("RSS Feeds", systemImage: "antenna.radiowaves.left.and.right")
                }
                .environmentObject(preferences)
            
            KeywordsPreferencesView()
                .tabItem {
                    Label("Keywords", systemImage: "magnifyingglass")
                }
                .environmentObject(preferences)
            
            DisplayPreferencesView()
                .tabItem {
                    Label("Display", systemImage: "display")
                }
                .environmentObject(preferences)
            
            WidgetsPreferencesView()
                .tabItem {
                    Label("Widgets", systemImage: "square.grid.2x2")
                }
                .environmentObject(preferences)
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - General Preferences

struct GeneralPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        Form {
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
    }
}

// MARK: - RSS Feeds Preferences

struct RSSFeedsPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    @State private var newFeedURL = ""
    @State private var newFeedName = ""
    @State private var showAddSheet = false
    
    var body: some View {
        VStack {
            HStack {
                Text("RSS Feeds")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showAddSheet = true }) {
                    Label("Add Feed", systemImage: "plus")
                }
            }
            .padding()
            
            List {
                ForEach($preferences.rssFeeds) { $feed in
                    HStack {
                        Toggle("", isOn: $feed.enabled)
                            .labelsHidden()
                        
                        VStack(alignment: .leading) {
                            Text(feed.name)
                                .font(.headline)
                            Text(feed.url)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            preferences.rssFeeds.removeAll { $0.id == feed.id }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("Refresh Interval: \(Int(preferences.refreshInterval / 60)) minutes")
                Slider(value: $preferences.refreshInterval, in: 300...7200, step: 300)
            }
            .padding()
        }
        .sheet(isPresented: $showAddSheet) {
            AddFeedSheet(
                feedURL: $newFeedURL,
                feedName: $newFeedName,
                onAdd: {
                    let feed = RSSFeedConfig(url: newFeedURL, name: newFeedName)
                    preferences.rssFeeds.append(feed)
                    newFeedURL = ""
                    newFeedName = ""
                    showAddSheet = false
                },
                onCancel: {
                    showAddSheet = false
                }
            )
        }
    }
}

struct AddFeedSheet: View {
    @Binding var feedURL: String
    @Binding var feedName: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add RSS Feed")
                .font(.title2)
                .bold()
            
            TextField("Feed Name", text: $feedName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Feed URL", text: $feedURL)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Add", action: onAdd)
                    .keyboardShortcut(.return)
                    .disabled(feedURL.isEmpty || feedName.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

// MARK: - Keywords Preferences

struct KeywordsPreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    @State private var newKeyword = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Keywords")
                    .font(.headline)
                
                Spacer()
                
                Text("Case insensitive • Wildcards: * and ?")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            HStack {
                TextField("Add keyword...", text: $newKeyword)
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
        }
    }
    
    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !preferences.keywords.contains(trimmed) {
            preferences.keywords.append(trimmed)
            newKeyword = ""
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
            Section(header: Text("Widget Settings").font(.headline)) {
                VStack(alignment: .leading) {
                    Text("Widget Rotation Duration: \(Int(preferences.widgetRotationDuration))s")
                    Slider(value: $preferences.widgetRotationDuration, in: 3...30, step: 1)
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
}

#Preview {
    PreferencesView()
        .environmentObject(AppPreferences.shared)
}
