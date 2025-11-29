//
//  DetailPanel.swift
//  Anderson
//
//  Panel for displaying matched articles in continuous scrolling detail view
//

import SwiftUI

struct DetailPanel: View {
    @EnvironmentObject var feedService: RSSFeedService
    @EnvironmentObject var preferences: AppPreferences
    
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollTimer: Timer?
    @State private var displayArticles: [Article] = [] // Articles in current display order
    @State private var articleRotationCount = 0 // Track how many times we've rotated
    
    // Fixed heights for predictable scrolling
    private let headerHeight: CGFloat = 60
    private let contentHeight: CGFloat = 300
    private let articleSpacing: CGFloat = 8
    
    // Height of an expanded article (header + content)
    private var expandedHeight: CGFloat {
        headerHeight + contentHeight
    }
    
    // Height of a collapsed article (header only)
    private var collapsedHeight: CGFloat {
        headerHeight
    }
    
    var body: some View {
        ZStack {
            if displayArticles.isEmpty {
                // Placeholder when no matched articles
                VStack {
                    Spacer()
                    GlowingText("WAITING FOR MATCHES...", size: 18, bold: true)
                        .opacity(0.5)
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    // Debug info showing article count
                    HStack {
                        Text("Matched Articles: \(feedService.matchedArticles.count)")
                            .font(MatrixTheme.font(size: 10))
                            .foregroundColor(MatrixTheme.dimGreen)
                            .padding(4)
                        Spacer()
                    }
                    .background(MatrixTheme.backgroundColor.opacity(0.8))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .top) {
                            // Continuous scrolling list of articles
                            VStack(spacing: articleSpacing) {
                                ForEach(Array(displayArticles.enumerated()), id: \.element.id) { index, article in
                                    articleView(for: article, displayIndex: index, geometry: geometry)
                                }
                            }
                            .offset(y: scrollOffset)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .onAppear {
                            initializeDisplay()
                            startContinuousScroll()
                        }
                    }
                }
            }
        }
        .padding(12)
        .onDisappear {
            stopScroll()
        }
        .onChange(of: feedService.matchedArticles.count) { _, newCount in
            print("DetailPanel: Matched articles count changed to \(newCount)")
            displayArticles = feedService.matchedArticles
            resetDisplay()
        }
    }
    
    @ViewBuilder
    private func articleView(for article: Article, displayIndex: Int, geometry: GeometryProxy) -> some View {
        // Only first two articles are expanded
        let isExpanded = displayIndex < 2
        let originalIndex = feedService.matchedArticles.firstIndex(where: { $0.id == article.id }) ?? 0
        let articleNumber = originalIndex + 1
        
        VStack(alignment: .leading, spacing: 0) {
            // Always visible header
            articleHeader(for: article, articleNumber: articleNumber, isExpanded: isExpanded)
                .frame(height: headerHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MatrixTheme.backgroundColor.opacity(0.8))
                .overlay(
                    Rectangle()
                        .stroke(isExpanded ? MatrixTheme.primaryGreen.opacity(0.8) : MatrixTheme.darkGreen.opacity(0.5), lineWidth: isExpanded ? 2 : 1)
                )
            
            // Expandable content - only show if expanded
            if isExpanded {
                articleContent(for: article)
                    .frame(height: contentHeight) // Fixed height
            }
        }
        .frame(height: isExpanded ? expandedHeight : collapsedHeight)
    }
    
    @ViewBuilder
    private func articleHeader(for article: Article, articleNumber: Int, isExpanded: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Article number and matched keywords
            HStack(spacing: 6) {
                // Article number badge
                Text("#\(articleNumber)")
                    .font(MatrixTheme.font(size: fontSize(9), bold: true))
                    .foregroundColor(isExpanded ? MatrixTheme.backgroundColor : MatrixTheme.primaryGreen)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isExpanded ? MatrixTheme.primaryGreen : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(MatrixTheme.primaryGreen, lineWidth: 1)
                            )
                    )
                
                // Matched keywords
                if !article.matchedKeywords.isEmpty {
                    ForEach(article.matchedKeywords.prefix(3), id: \.self) { keyword in
                        Text("[\(keyword)]")
                            .font(MatrixTheme.font(size: fontSize(9), bold: true))
                            .foregroundColor(MatrixTheme.primaryGreen)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(isExpanded ? MatrixTheme.primaryGreen.opacity(0.2) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(MatrixTheme.primaryGreen, lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            
            // Title
            Text(article.title)
                .font(MatrixTheme.font(size: fontSize(14), bold: true))
                .foregroundColor(MatrixTheme.primaryGreen)
                .modifier(GlowModifier(intensity: isExpanded ? preferences.glowIntensity * 1.5 : preferences.glowIntensity, radius: isExpanded ? 4 : 2))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Source and date
            HStack {
                Text(article.source)
                    .font(MatrixTheme.font(size: fontSize(9)))
                    .foregroundColor(MatrixTheme.dimGreen)
                
                Spacer()
                
                if isExpanded {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: fontSize(10)))
                        .foregroundColor(MatrixTheme.primaryGreen)
                }
                
                Text(article.publishDate, style: .relative)
                    .font(MatrixTheme.font(size: fontSize(9)))
                    .foregroundColor(MatrixTheme.darkGreen)
            }
        }
        .padding(8)
    }
    
    @ViewBuilder
    private func articleContent(for article: Article) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                // Image if available
                if let imageURL = article.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            MatrixImageView(image: image)
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                                .clipped()
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                }
                
                // Divider
                Divider()
                    .background(MatrixTheme.darkGreen.opacity(0.5))
                    .padding(.horizontal, 8)
                
                // Content text - scrollable within fixed height
                Text(cleanHTMLContent(article.content))
                    .font(MatrixTheme.font(size: fontSize(11)))
                    .foregroundColor(MatrixTheme.dimGreen)
                    .lineSpacing(6)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: contentHeight) // Fixed height
        .background(MatrixTheme.backgroundColor.opacity(0.6))
        .overlay(
            Rectangle()
                .stroke(MatrixTheme.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }
    
    // Clean HTML tags from content
    private func cleanHTMLContent(_ html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func fontSize(_ base: CGFloat) -> CGFloat {
        return base * CGFloat(preferences.fontSize / 14.0)
    }
    
    private func initializeDisplay() {
        displayArticles = feedService.matchedArticles
    }
    
    private func startContinuousScroll() {
        guard !displayArticles.isEmpty else { return }
        
        stopScroll()
        
        let scrollInterval = 1.0 / 60.0 // 60 fps
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { [self] _ in
            let pixelsPerFrame = preferences.detailPanelScrollSpeed
            scrollOffset -= pixelsPerFrame
            
            // The first article is always expanded, so check when its FULL height
            // (header + content) has scrolled off the top of the screen
            let firstArticleFullHeight = expandedHeight
            let firstArticleBottom = scrollOffset + firstArticleFullHeight
            
            // Remove the first article when its bottom edge scrolls past the top of the screen
            if firstArticleBottom <= 0 && !displayArticles.isEmpty {
                print("🔄 Article removed (scrolled off after \(firstArticleFullHeight)px)")
                
                // Remove the first article completely (don't recycle)
                displayArticles.removeFirst()
                articleRotationCount += 1
                
                // Adjust scroll offset so the second article (now first) starts at the top
                // Account for the spacing that was between articles
                scrollOffset += firstArticleFullHeight + articleSpacing
                
                // If we've run out of articles, stop scrolling
                if displayArticles.isEmpty {
                    stopScroll()
                }
            }
        }
    }
    
    private func stopScroll() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    private func resetDisplay() {
        scrollOffset = 0
        displayArticles = feedService.matchedArticles
        articleRotationCount = 0
        initializeDisplay()
        startContinuousScroll()
    }
}

// MARK: - Matrix-style Image View

struct MatrixImageView: View {
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .grayscale(1.0)
            .colorMultiply(MatrixTheme.primaryGreen)
            .brightness(-0.1)
            .contrast(1.3)
            .opacity(0.8)
    }
}

#Preview {
    DetailPanel()
        .environmentObject(RSSFeedService())
        .environmentObject(AppPreferences.shared)
        .frame(width: 600, height: 480)
        .background(MatrixTheme.backgroundColor)
}
