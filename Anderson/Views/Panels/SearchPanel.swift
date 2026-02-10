//
//  SearchPanel.swift
//  Anderson
//
//  Fast scrolling panel showing RSS feed search results
//

import SwiftUI

struct SearchPanel: View {
    @EnvironmentObject var feedService: RSSFeedService
    @EnvironmentObject var preferences: AppPreferences
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollTimer: Timer?
    @State private var pausedArticleId: UUID?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(feedService.allArticles) { article in
                        ArticleRowView(article: article, isSearchPanel: true)
                            .id(article.id)
                            .onAppear {
                                checkForKeywordMatch(article)
                            }
                    }
                }
                .offset(y: scrollOffset)
            }
            .onAppear {
                startScrolling(height: geometry.size.height)
            }
            .onDisappear {
                scrollTimer?.invalidate()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func checkForKeywordMatch(_ article: Article) {
        if !article.matchedKeywords.isEmpty && pausedArticleId != article.id {
            // Pause scrolling when keyword is found
            pausedArticleId = article.id
            scrollTimer?.invalidate()

            // Note: Articles are already added to matchedArticles by RSSFeedService
            // No need to add them again here (prevents race conditions)

            // Resume scrolling after pause duration
            DispatchQueue.main.asyncAfter(deadline: .now() + preferences.keywordPauseDuration) {
                pausedArticleId = nil
                startScrolling(height: 0) // Will recalculate in next cycle
            }
        }
    }
    
    private func startScrolling(height: CGFloat) {
        scrollTimer?.invalidate()
        
        let baseInterval = 1.0 / (preferences.searchPanelScrollSpeed * 60.0) // 60fps target
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: baseInterval, repeats: true) { _ in
            guard pausedArticleId == nil else { return }
            
            // Add jankiness if enabled
            let jankyFactor = preferences.jankyScrollEnabled ? Double.random(in: 0.5...1.5) : 1.0
            let scrollAmount = preferences.searchPanelScrollSpeed * jankyFactor
            
            withAnimation(.linear(duration: baseInterval)) {
                scrollOffset -= scrollAmount
            }
            
            // Reset scroll when reaching bottom
            if abs(scrollOffset) > 10000 {
                scrollOffset = 0
            }
        }
    }
}

// MARK: - Article Row View

struct ArticleRowView: View {
    let article: Article
    let isSearchPanel: Bool
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            if article.matchedKeywords.isEmpty {
                Text(article.title)
                    .font(MatrixTheme.font(size: fontSize(16), bold: true))
                    .foregroundColor(MatrixTheme.primaryGreen)
                    .modifier(GlowModifier(intensity: preferences.glowIntensity, radius: 3))
            } else {
                highlightedTitleView
            }
            
            // Snippet
            if isSearchPanel {
                Text(article.snippet)
                    .font(MatrixTheme.font(size: fontSize(12)))
                    .foregroundColor(MatrixTheme.dimGreen)
                    .lineLimit(2)
            }
            
            // Source
            HStack {
                Text(article.source)
                    .font(MatrixTheme.font(size: fontSize(10)))
                    .foregroundColor(MatrixTheme.darkGreen)
                
                Spacer()
                
                if !article.matchedKeywords.isEmpty {
                    Text("[\(article.matchedKeywords.count) matches]")
                        .font(MatrixTheme.font(size: fontSize(10), bold: true))
                        .foregroundColor(MatrixTheme.primaryGreen)
                        .modifier(PulsingGlowModifier(intensity: 1.0))
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    article.matchedKeywords.isEmpty ? 
                        MatrixTheme.darkGreen.opacity(0.3) : 
                        MatrixTheme.primaryGreen.opacity(0.6),
                    lineWidth: article.matchedKeywords.isEmpty ? 1 : 2
                )
        )
    }
    
    private var highlightedTitleView: some View {
        let components = KeywordMatcher.highlightKeywords(
            in: article.title,
            keywords: article.matchedKeywords
        )
        
        return HStack(spacing: 0) {
            ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                if component.isKeyword {
                    Text(component.text)
                        .font(MatrixTheme.font(size: fontSize(16), bold: true))
                        .foregroundColor(MatrixTheme.primaryGreen)
                        .underline(color: MatrixTheme.primaryGreen)
                        .modifier(PulsingGlowModifier(intensity: 1.5))
                } else {
                    Text(component.text)
                        .font(MatrixTheme.font(size: fontSize(16), bold: true))
                        .foregroundColor(MatrixTheme.primaryGreen)
                        .modifier(GlowModifier(intensity: preferences.glowIntensity, radius: 3))
                }
            }
        }
    }
    
    private func fontSize(_ base: CGFloat) -> CGFloat {
        return base * CGFloat(preferences.fontSize / 14.0)
    }
}

#Preview {
    SearchPanel()
        .environmentObject(RSSFeedService())
        .environmentObject(AppPreferences.shared)
        .frame(width: 800, height: 480)
        .background(MatrixTheme.backgroundColor)
}
