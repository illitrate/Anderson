//
//  DetailPanel.swift
//  MatrixMonitor
//
//  Panel for displaying matched articles in detail with slow scroll
//

import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject var feedService: RSSFeedService
    @EnvironmentObject var preferences: AppPreferences
    @State private var currentArticleIndex = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var articleTimer: Timer?
    @State private var scrollTimer: Timer?
    
    var body: some View {
        ZStack {
            if feedService.matchedArticles.isEmpty {
                // Placeholder when no matched articles
                VStack {
                    Spacer()
                    GlowingText("WAITING FOR MATCHES...", size: 18, bold: true)
                        .opacity(0.5)
                    Spacer()
                }
            } else {
                currentArticleView
            }
        }
        .padding(12)
        .onAppear {
            startArticleRotation()
        }
        .onDisappear {
            articleTimer?.invalidate()
            scrollTimer?.invalidate()
        }
    }
    
    @ViewBuilder
    private var currentArticleView: some View {
        if currentArticleIndex < feedService.matchedArticles.count {
            let article = feedService.matchedArticles[currentArticleIndex]
            
            VStack(alignment: .leading, spacing: 12) {
                // Header with title (fixed at top)
                VStack(alignment: .leading, spacing: 8) {
                    // Matched keywords
                    if !article.matchedKeywords.isEmpty {
                        HStack {
                            ForEach(article.matchedKeywords, id: \.self) { keyword in
                                Text("[\(keyword)]")
                                    .font(MatrixTheme.font(size: fontSize(10), bold: true))
                                    .foregroundColor(MatrixTheme.primaryGreen)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(MatrixTheme.primaryGreen, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    
                    // Title
                    Text(article.title)
                        .font(MatrixTheme.font(size: fontSize(18), bold: true))
                        .foregroundColor(MatrixTheme.primaryGreen)
                        .modifier(GlowModifier(intensity: preferences.glowIntensity, radius: 4))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Source and date
                    HStack {
                        Text(article.source)
                            .font(MatrixTheme.font(size: fontSize(11)))
                            .foregroundColor(MatrixTheme.dimGreen)
                        
                        Spacer()
                        
                        Text(article.publishDate, style: .relative)
                            .font(MatrixTheme.font(size: fontSize(11)))
                            .foregroundColor(MatrixTheme.darkGreen)
                    }
                    
                    Divider()
                        .background(MatrixTheme.darkGreen.opacity(0.5))
                }
                
                // Scrolling content area
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Image if available
                            if let imageURL = article.imageURL {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        MatrixImageView(image: image)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 120)
                                    case .failure, .empty:
                                        EmptyView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            // Content
                            Text(article.content)
                                .font(MatrixTheme.font(size: fontSize(13)))
                                .foregroundColor(MatrixTheme.dimGreen)
                                .lineSpacing(4)
                        }
                        .offset(y: scrollOffset)
                    }
                    .onAppear {
                        scrollOffset = 0
                        startScrolling(contentHeight: geometry.size.height)
                    }
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        }
    }
    
    private func fontSize(_ base: CGFloat) -> CGFloat {
        return base * CGFloat(preferences.fontSize / 14.0)
    }
    
    private func startArticleRotation() {
        articleTimer?.invalidate()
        
        // Calculate time needed to scroll through article
        // This is approximate - we'll use a fixed duration per article
        let durationPerArticle: TimeInterval = 30.0 // 30 seconds per article
        
        articleTimer = Timer.scheduledTimer(withTimeInterval: durationPerArticle, repeats: true) { _ in
            guard !feedService.matchedArticles.isEmpty else { return }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                currentArticleIndex = (currentArticleIndex + 1) % feedService.matchedArticles.count
            }
            
            scrollOffset = 0
        }
    }
    
    private func startScrolling(contentHeight: CGFloat) {
        scrollTimer?.invalidate()
        
        let scrollInterval = 1.0 / 30.0 // 30 fps
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { _ in
            withAnimation(.linear(duration: scrollInterval)) {
                scrollOffset -= preferences.detailPanelScrollSpeed
            }
        }
    }
}

// MARK: - Matrix-style Image View

struct MatrixImageView: View {
    let image: Image
    
    var body: some View {
        // For now, just display the image with green tint
        // In a full implementation, we'd process it to be pixelated and monochrome
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .colorMultiply(MatrixTheme.primaryGreen)
            .opacity(0.7)
    }
}

#Preview {
    DetailPanel()
        .environmentObject(RSSFeedService())
        .environmentObject(AppPreferences.shared)
        .frame(width: 600, height: 480)
        .background(MatrixTheme.backgroundColor)
}
