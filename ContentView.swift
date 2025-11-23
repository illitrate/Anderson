//
//  ContentView.swift
//  Anderson
//
//  Main view with three-panel layout
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var preferences: AppPreferences
    @StateObject private var feedService = RSSFeedService()
    @State private var showPreferences = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                MatrixBackground()
                    .ignoresSafeArea()
                
                // Main content
                HStack(spacing: 0) {
                    // Widget Panel (Left)
                    WidgetPanel()
                        .frame(width: widgetPanelWidth(for: geometry.size))
                        .environmentObject(preferences)
                    
                    // Divider
                    Rectangle()
                        .fill(MatrixTheme.darkGreen.opacity(0.3))
                        .frame(width: 1)
                    
                    // Search Panel (Center)
                    SearchPanel()
                        .frame(width: searchPanelWidth(for: geometry.size))
                        .environmentObject(feedService)
                        .environmentObject(preferences)
                    
                    // Divider
                    Rectangle()
                        .fill(MatrixTheme.darkGreen.opacity(0.3))
                        .frame(width: 1)
                    
                    // Detail Panel (Right)
                    DetailPanel()
                        .frame(width: detailPanelWidth(for: geometry.size))
                        .environmentObject(feedService)
                        .environmentObject(preferences)
                }
            }
        }
        .onAppear {
            // Start RSS feed service
            feedService.start()
        }
        // Add keyboard shortcut for preferences
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowPreferences"))) { _ in
            showPreferences = true
        }
    }
    
    // Calculate panel widths based on screen size
    private func widgetPanelWidth(for size: CGSize) -> CGFloat {
        return min(200, size.width * 0.15)
    }
    
    private func searchPanelWidth(for size: CGSize) -> CGFloat {
        let remaining = size.width - widgetPanelWidth(for: size) - 2 // Subtract dividers
        return remaining * 0.60
    }
    
    private func detailPanelWidth(for size: CGSize) -> CGFloat {
        let remaining = size.width - widgetPanelWidth(for: size) - 2 // Subtract dividers
        return remaining * 0.40
    }
}

// Custom NSHostingView to handle keyboard shortcuts
class MatrixHostingView: NSHostingView<ContentView> {
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "," {
            NotificationCenter.default.post(name: NSNotification.Name("ShowPreferences"), object: nil)
            return
        }
        super.keyDown(with: event)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppPreferences.shared)
        .frame(width: 1920, height: 480)
}
