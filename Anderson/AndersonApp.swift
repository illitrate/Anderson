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
        Settings {
            SettingsWindowAccessor()
            PreferencesView()
                .environmentObject(AppPreferences.shared)
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                SettingsLink {
                    Text("Preferences…")
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
    }
}

// Helper view to access and configure the settings window
struct SettingsWindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.level = .modalPanel
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            window.level = .modalPanel
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Create floating window
        createFloatingWindow()
        
        // Listen for display change notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MoveToDisplay"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let displayID = notification.userInfo?["displayID"] as? String {
                self?.moveWindowToDisplay(displayID)
            }
        }
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
        
        // Set content view (defer to next runloop to avoid layout recursion/invalid frames)
        let contentView = ContentView()
            .environmentObject(AppPreferences.shared)
        DispatchQueue.main.async { [weak window] in
            window?.contentView = NSHostingView(rootView: contentView)
        }
        
        // Position and show window on next runloop to avoid layout recursion at launch
        DispatchQueue.main.async { [weak window] in
            window?.setFrame(screenFrame, display: true)
            window?.orderFrontRegardless()
        }
        
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
    
    func getSavedScreen() -> NSScreen? {
        // First try to get screen from preferences
        if let savedID = AppPreferences.shared.selectedDisplayID {
            if let screen = NSScreen.screens.first(where: { $0.localizedName == savedID }) {
                return screen
            }
        }
        // Fallback to old method for backwards compatibility
        let savedScreenName = UserDefaults.standard.string(forKey: "LastScreenName")
        return NSScreen.screens.first { $0.localizedName == savedScreenName }
    }

    func saveWindowScreen() {
        guard let window = floatingWindow,
              let screen = window.screen else { return }
        UserDefaults.standard.set(screen.localizedName, forKey: "LastScreenName")
        AppPreferences.shared.selectedDisplayID = screen.localizedName
    }

    func moveWindowToDisplay(_ displayID: String) {
        guard let window = floatingWindow,
              let targetScreen = NSScreen.screens.first(where: { $0.localizedName == displayID }) else {
            return
        }

        let screenFrame = targetScreen.frame
         // Animate the window moving and resizing
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(screenFrame, display: true)
        } completionHandler: {
            // Save the new screen
            self.saveWindowScreen()
        }
    }
}
