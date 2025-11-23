//
//  MatrixTheme.swift
//  MatrixMonitor
//
//  Defines the Matrix-inspired visual theme
//

import SwiftUI

struct MatrixTheme {
    // Colors
    static let primaryGreen = Color(red: 0, green: 1, blue: 0.25) // #00FF41
    static let dimGreen = Color(red: 0, green: 0.8, blue: 0.2)
    static let darkGreen = Color(red: 0, green: 0.4, blue: 0.1)
    static let backgroundColor = Color(red: 0.04, green: 0.06, blue: 0.04) // Slightly green-tinted black
    
    // Fonts
    static let monoFont = "SFMono-Regular"
    static let monoBoldFont = "SFMono-Bold"
    
    static func font(size: CGFloat, bold: Bool = false) -> Font {
        return .custom(bold ? monoBoldFont : monoFont, size: size)
    }
    
    // Glow effect
    static func glowEffect(intensity: CGFloat = 1.0, radius: CGFloat = 4) -> some View {
        return EmptyView().modifier(GlowModifier(intensity: intensity, radius: radius))
    }
}

// Glow modifier for text
struct GlowModifier: ViewModifier {
    let intensity: CGFloat
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: MatrixTheme.primaryGreen.opacity(0.8 * intensity), radius: radius, x: 0, y: 0)
            .shadow(color: MatrixTheme.primaryGreen.opacity(0.6 * intensity), radius: radius * 1.5, x: 0, y: 0)
    }
}

// Text with glow effect
struct GlowingText: View {
    let text: String
    let size: CGFloat
    let bold: Bool
    let intensity: CGFloat
    
    init(_ text: String, size: CGFloat = 14, bold: Bool = false, glowIntensity: CGFloat = 1.0) {
        self.text = text
        self.size = size
        self.bold = bold
        self.intensity = glowIntensity
    }
    
    var body: some View {
        Text(text)
            .font(MatrixTheme.font(size: size, bold: bold))
            .foregroundColor(MatrixTheme.primaryGreen)
            .modifier(GlowModifier(intensity: intensity, radius: 4))
    }
}

// Pulsing glow animation for highlighted keywords
struct PulsingGlowModifier: ViewModifier {
    @State private var pulseAnimation = false
    let intensity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: MatrixTheme.primaryGreen.opacity(pulseAnimation ? 1.0 : 0.6),
                radius: pulseAnimation ? 8 : 4,
                x: 0,
                y: 0
            )
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
    }
}

// Highlighted keyword text with pulsing glow and underline
struct HighlightedKeywordText: View {
    let text: String
    let size: CGFloat
    
    var body: some View {
        Text(text)
            .font(MatrixTheme.font(size: size, bold: true))
            .foregroundColor(MatrixTheme.primaryGreen)
            .underline(color: MatrixTheme.primaryGreen)
            .modifier(PulsingGlowModifier(intensity: 1.5))
    }
}

// Background view with transparency
struct MatrixBackground: View {
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        MatrixTheme.backgroundColor
            .opacity(1.0 - preferences.backgroundTransparency)
    }
}
