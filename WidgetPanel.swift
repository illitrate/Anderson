//
//  WidgetPanel.swift
//  MatrixMonitor
//
//  Scrolling panel of system monitoring widgets
//

import SwiftUI

struct WidgetPanel: View {
    @EnvironmentObject var preferences: AppPreferences
    @State private var currentWidgetIndex = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Pinned widgets (always visible)
            ForEach(pinnedWidgetViews, id: \.id) { widget in
                widget.view
                    .frame(height: widgetHeight(pinned: true))
                    .padding(.vertical, 8)
                
                Divider()
                    .background(MatrixTheme.darkGreen.opacity(0.3))
            }
            
            // Rotating widget area
            if !rotatingWidgets.isEmpty {
                rotatingWidgetView
                    .frame(maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
            
            Spacer()
        }
        .onAppear {
            startRotation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var rotatingWidgetView: some View {
        Group {
            if currentWidgetIndex < rotatingWidgets.count {
                rotatingWidgets[currentWidgetIndex].view
                    .padding()
            }
        }
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
    
    private func widgetHeight(pinned: Bool) -> CGFloat {
        return pinned ? 120 : 180
    }
    
    private func startRotation() {
        timer?.invalidate()
        
        guard !rotatingWidgets.isEmpty else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: preferences.widgetRotationDuration, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentWidgetIndex = (currentWidgetIndex + 1) % rotatingWidgets.count
            }
        }
    }
}

#Preview {
    WidgetPanel()
        .environmentObject(AppPreferences.shared)
        .frame(width: 200, height: 480)
        .background(MatrixTheme.backgroundColor)
}
