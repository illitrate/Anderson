//
//  AndersonApp.swift
//  Anderson
//
//  A Matrix-inspired RSS feed monitor with system widgets
//

import SwiftUI

@main
struct AndersonApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var preferences = AppPreferences.shared
    
    var body: some Scene {
        // Empty scene - we manage windows manually
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingWindow: NSWindow?
    var statusItem: NSStatusItem?
    var preferencesWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Create menu bar item
        setupMenuBar()
        
        // Create floating window
        createFloatingWindow()
        
        // Set up launch at login (we'll implement this later)
        setupLaunchAtLogin()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "matrix.fill", accessibilityDescription: "Anderson")
            // Fallback if matrix.fill doesn't exist
            if button.image == nil {
                button.title = "⚡︎"
            }
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Show Window", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    func createFloatingWindow() {
        // Get the saved monitor or use main screen
        let screen = getSavedScreen() ?? NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.frame
        
        // Create borderless window
        floatingWindow = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        
        guard let window = floatingWindow else { return }
        
        // Window configuration
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating // Always on top
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.hasShadow = false
        window.ignoresMouseEvents = false
        
        // Set content view
        let contentView = ContentView()
            .environmentObject(AppPreferences.shared)
        window.contentView = NSHostingView(rootView: contentView)
        
        // Position window
        window.setFrame(screenFrame, display: true)
        window.makeKeyAndOrderFront(nil)
        
        // Save window position when moved
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.saveWindowScreen()
        }
    }
    
    @objc func showWindow() {
        floatingWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func showPreferences() {
        if preferencesWindow == nil {
            let prefsView = PreferencesView()
                .environmentObject(AppPreferences.shared)
            
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            preferencesWindow?.title = "Anderson Preferences"
            preferencesWindow?.contentView = NSHostingView(rootView: prefsView)
            preferencesWindow?.center()
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func getSavedScreen() -> NSScreen? {
        let savedScreenName = UserDefaults.standard.string(forKey: "LastScreenName")
        return NSScreen.screens.first { $0.localizedName == savedScreenName }
    }
    
    func saveWindowScreen() {
        guard let window = floatingWindow,
              let screen = window.screen else { return }
        UserDefaults.standard.set(screen.localizedName, forKey: "LastScreenName")
    }
    
    func setupLaunchAtLogin() {
        // This will be implemented using SMLoginItemSetEnabled or ServiceManagement framework
        // For now, users can add manually via System Preferences
    }
}
