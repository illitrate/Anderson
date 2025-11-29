//
//  WidgetPanel.swift
//  Anderson
//
//  Scrolling panel of system monitoring widgets
//

import SwiftUI

struct WidgetPanel: View {
    @EnvironmentObject var preferences: AppPreferences
    @State private var scrollOffset: CGFloat = 0
    @State private var timer: Timer?
    @Environment(\.openSettings) private var openSettings
    
    private let widgetHeight: CGFloat = 140
    private let widgetSpacing: CGFloat = 16
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Pinned widgets (always visible at top)
                if !pinnedWidgetViews.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(pinnedWidgetViews, id: \.id) { widget in
                            widget.view
                                .frame(maxWidth: 150)
                                .frame(height: 100)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                            
                            Divider()
                                .background(MatrixTheme.darkGreen.opacity(0.3))
                        }
                    }
                }
              
                   // Rotating widgets area - continuous scroll
                ZStack(alignment: .top) {
                    if !rotatingWidgets.isEmpty {
                        // Create a repeating sequence of widgets for infinite scroll effect
                        VStack(spacing: widgetSpacing) {
                            ForEach(infiniteWidgetSequence, id: \.index) { item in
                                item.widget.view
                                    .frame(maxWidth: 150)
                                    .frame(height: widgetHeight)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .offset(y: scrollOffset)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: CGFloat(infiniteWidgetSequence.count*30))
                .clipped()

                Spacer()

                // Control buttons at bottom
                VStack(spacing: 8) {
                    Divider()
                        .background(MatrixTheme.darkGreen.opacity(0.3))
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            openSettings()
                        }) {
                            Label("Preferences", systemImage: "gearshape")
                                .font(.caption)
                                .foregroundColor(MatrixTheme.primaryGreen)
                        }
                        .buttonStyle(.plain)
                        .help("Open Preferences (⌘,)")
                        
                        Spacer()
                        
                        Button(action: {
                            NSApp.terminate(nil)
                        }) {
                            Label("Quit", systemImage: "power")
                                .font(.caption)
                                .foregroundColor(MatrixTheme.primaryGreen)
                        }
                        .buttonStyle(.plain)
                        .help("Quit Anderson (⌘Q)")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
        }
        .onAppear {
            startContinuousScroll()
        }
        .onDisappear {
            stopScroll()
        }
        .onChange(of: rotatingWidgets.count) { _, _ in
            restartScroll()
        }
        .onChange(of: preferences.widgetRotationDuration) { _, _ in
            restartScroll()
        }
    }
    
    // Create an infinite sequence by repeating widgets
    private var infiniteWidgetSequence: [(index: Int, widget: (id: String, view: AnyView))] {
        guard !rotatingWidgets.isEmpty else { return [] }
        
        // Calculate how many copies we need to fill at least 3x the screen height for smooth looping
        let totalItemHeight = widgetHeight + widgetSpacing
        let copiesNeeded = max(3, Int(ceil(600.0 / (totalItemHeight * Double(rotatingWidgets.count)))) + 2)
        
        var sequence: [(index: Int, widget: (id: String, view: AnyView))] = []
        for copy in 0..<copiesNeeded {
            for (idx, widget) in rotatingWidgets.enumerated() {
                let uniqueIndex = copy * rotatingWidgets.count + idx
                sequence.append((index: uniqueIndex, widget: widget))
            }
        }
        return sequence
    }
    
    private var pinnedWidgetViews: [(id: String, view: AnyView)] {
        allWidgets.filter { preferences.pinnedWidgets.contains($0.id) }
    }
    
    private var rotatingWidgets: [(id: String, view: AnyView)] {
        allWidgets.filter { 
            preferences.enabledWidgets.contains($0.id) && 
            !preferences.pinnedWidgets.contains($0.id)
        }
    }
    
    private var allWidgets: [(id: String, view: AnyView)] {
        [
            ("clock", AnyView(AnalogClockWidget())),
            ("uptime", AnyView(UptimeWidget())),
            ("cpu", AnyView(CPUWidget())),
            ("memory", AnyView(MemoryWidget())),
            ("network", AnyView(NetworkWidget())),
            ("storage", AnyView(StorageWidget()))
        ]
    }
    
    private func startContinuousScroll() {
        guard !rotatingWidgets.isEmpty else { return }
        
        stopScroll()
        
        let totalItemHeight = widgetHeight + widgetSpacing
        let cycleHeight = totalItemHeight * CGFloat(rotatingWidgets.count)
        
        // Start timer for smooth scrolling
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // Calculate scroll speed based on rotation duration
            // Each widget should take widgetRotationDuration seconds to scroll through
            let pixelsPerSecond = totalItemHeight / preferences.widgetRotationDuration
            let pixelsPerFrame = pixelsPerSecond * 0.016 // 60fps
            
            scrollOffset -= pixelsPerFrame
            
            // Reset when we've scrolled through one complete cycle
            if abs(scrollOffset) >= cycleHeight {
                scrollOffset = scrollOffset.truncatingRemainder(dividingBy: cycleHeight)
            }
        }
    }
    
    private func stopScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func restartScroll() {
        scrollOffset = 0
        startContinuousScroll()
    }
}

#Preview {
    WidgetPanel()
        .environmentObject(AppPreferences.shared)
        .frame(width: 200, height: 680)
        .background(MatrixTheme.backgroundColor)
}

