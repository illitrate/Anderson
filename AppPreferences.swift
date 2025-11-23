//
//  AppPreferences.swift
//  Anderson
//
//  Manages all user preferences and settings
//

import SwiftUI
import Combine

class AppPreferences: ObservableObject {
    static let shared = AppPreferences()
    
    // General Settings
    @Published var backgroundTransparency: Double {
        didSet { UserDefaults.standard.set(backgroundTransparency, forKey: "backgroundTransparency") }
    }
    
    @Published var glowIntensity: Double {
        didSet { UserDefaults.standard.set(glowIntensity, forKey: "glowIntensity") }
    }
    
    @Published var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "fontSize") }
    }
    
    // Display Settings
    @Published var searchPanelScrollSpeed: Double {
        didSet { UserDefaults.standard.set(searchPanelScrollSpeed, forKey: "searchPanelScrollSpeed") }
    }
    
    @Published var detailPanelScrollSpeed: Double {
        didSet { UserDefaults.standard.set(detailPanelScrollSpeed, forKey: "detailPanelScrollSpeed") }
    }
    
    @Published var keywordPauseDuration: Double {
        didSet { UserDefaults.standard.set(keywordPauseDuration, forKey: "keywordPauseDuration") }
    }
    
    @Published var jankyScrollEnabled: Bool {
        didSet { UserDefaults.standard.set(jankyScrollEnabled, forKey: "jankyScrollEnabled") }
    }
    
    // RSS Settings
    @Published var rssFeeds: [RSSFeedConfig] {
        didSet { saveRSSFeeds() }
    }
    
    @Published var refreshInterval: Double {
        didSet { UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval") }
    }
    
    // Keyword Settings
    @Published var keywords: [String] {
        didSet { saveKeywords() }
    }
    
    // Widget Settings
    @Published var widgetRotationDuration: Double {
        didSet { UserDefaults.standard.set(widgetRotationDuration, forKey: "widgetRotationDuration") }
    }
    
    @Published var pinnedWidgets: Set<String> {
        didSet { savePinnedWidgets() }
    }
    
    @Published var diskSpaceChangeThreshold: Double {
        didSet { UserDefaults.standard.set(diskSpaceChangeThreshold, forKey: "diskSpaceChangeThreshold") }
    }
    
    @Published var enabledWidgets: Set<String> {
        didSet { saveEnabledWidgets() }
    }
    
    private init() {
        // Load General Settings
        self.backgroundTransparency = UserDefaults.standard.object(forKey: "backgroundTransparency") as? Double ?? 0.8
        self.glowIntensity = UserDefaults.standard.object(forKey: "glowIntensity") as? Double ?? 1.0
        self.fontSize = UserDefaults.standard.object(forKey: "fontSize") as? Double ?? 14.0
        
        // Load Display Settings
        self.searchPanelScrollSpeed = UserDefaults.standard.object(forKey: "searchPanelScrollSpeed") as? Double ?? 2.0
        self.detailPanelScrollSpeed = UserDefaults.standard.object(forKey: "detailPanelScrollSpeed") as? Double ?? 0.5
        self.keywordPauseDuration = UserDefaults.standard.object(forKey: "keywordPauseDuration") as? Double ?? 1.0
        self.jankyScrollEnabled = UserDefaults.standard.object(forKey: "jankyScrollEnabled") as? Bool ?? true
        
        // Load RSS Settings
        self.rssFeeds = Self.loadRSSFeeds()
        self.refreshInterval = UserDefaults.standard.object(forKey: "refreshInterval") as? Double ?? 1800 // 30 minutes
        
        // Load Keywords
        self.keywords = UserDefaults.standard.stringArray(forKey: "keywords") ?? []
        
        // Load Widget Settings
        self.widgetRotationDuration = UserDefaults.standard.object(forKey: "widgetRotationDuration") as? Double ?? 8.0
        self.pinnedWidgets = Self.loadPinnedWidgets()
        self.diskSpaceChangeThreshold = UserDefaults.standard.object(forKey: "diskSpaceChangeThreshold") as? Double ?? 5.0 // 5GB
        self.enabledWidgets = Self.loadEnabledWidgets()
        
        // Set default enabled widgets if empty
        if self.enabledWidgets.isEmpty {
            self.enabledWidgets = ["clock", "uptime", "cpu", "memory", "network", "storage"]
        }
        
        // Set default pinned widgets if empty
        if self.pinnedWidgets.isEmpty {
            self.pinnedWidgets = ["clock"]
        }
    }
    
    // MARK: - RSS Feed Persistence
    
    private func saveRSSFeeds() {
        if let encoded = try? JSONEncoder().encode(rssFeeds) {
            UserDefaults.standard.set(encoded, forKey: "rssFeeds")
        }
    }
    
    private static func loadRSSFeeds() -> [RSSFeedConfig] {
        guard let data = UserDefaults.standard.data(forKey: "rssFeeds"),
              let feeds = try? JSONDecoder().decode([RSSFeedConfig].self, from: data) else {
            return []
        }
        return feeds
    }
    
    // MARK: - Keyword Persistence
    
    private func saveKeywords() {
        UserDefaults.standard.set(keywords, forKey: "keywords")
    }
    
    // MARK: - Widget Persistence
    
    private func savePinnedWidgets() {
        UserDefaults.standard.set(Array(pinnedWidgets), forKey: "pinnedWidgets")
    }
    
    private static func loadPinnedWidgets() -> Set<String> {
        guard let array = UserDefaults.standard.array(forKey: "pinnedWidgets") as? [String] else {
            return []
        }
        return Set(array)
    }
    
    private func saveEnabledWidgets() {
        UserDefaults.standard.set(Array(enabledWidgets), forKey: "enabledWidgets")
    }
    
    private static func loadEnabledWidgets() -> Set<String> {
        guard let array = UserDefaults.standard.array(forKey: "enabledWidgets") as? [String] else {
            return []
        }
        return Set(array)
    }
}

// MARK: - Supporting Types

struct RSSFeedConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var url: String
    var name: String
    var enabled: Bool
    
    init(url: String, name: String, enabled: Bool = true) {
        self.id = UUID()
        self.url = url
        self.name = name
        self.enabled = enabled
    }
}
