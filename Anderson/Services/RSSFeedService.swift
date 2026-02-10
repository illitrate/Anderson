//
//  RSSFeedService.swift
//  Anderson
//
//  Service for fetching and parsing RSS feeds
//

import Foundation
import Combine

class RSSFeedService: NSObject, ObservableObject, XMLParserDelegate {
    @Published var allArticles: [Article] = []
    @Published var matchedArticles: [Article] = []
    
    private var preferences: AppPreferences { AppPreferences.shared }
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let articleQueue = DispatchQueue(label: "com.anderson.articleQueue", qos: .userInitiated)
    
    // XML parsing state
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentSource = ""
    private var currentFeedConfig: RSSFeedConfig?
    private var parsedArticles: [Article] = []
    
    override init() {
        super.init()
        
        // Listen for preference changes
        preferences.$keywords
            .sink { [weak self] _ in
                self?.reprocessArticles()
            }
            .store(in: &cancellables)
        
        preferences.$negativeKeywords
            .sink { [weak self] _ in
                self?.reprocessArticles()
            }
            .store(in: &cancellables)
        
        preferences.$rssFeeds
            .sink { [weak self] _ in
                self?.fetchAllFeeds()
            }
            .store(in: &cancellables)
    }
    
    func start() {
        fetchAllFeeds()
        startRefreshTimer()
    }
    
    private func startRefreshTimer() {
        refreshTimer?.invalidate()
        
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: preferences.refreshInterval,
            repeats: true
        ) { [weak self] _ in
            self?.fetchAllFeeds()
        }
    }
    
    func fetchAllFeeds() {
        let enabledFeeds = preferences.rssFeeds.filter { $0.enabled }
        
        print("🔄 Fetching \(enabledFeeds.count) enabled RSS feeds...")
        
        for feed in enabledFeeds {
            print("  📡 Fetching: \(feed.name) (\(feed.url)) [Mode: \(feed.keywordMode.rawValue)]")
            fetchFeed(config: feed)
        }
    }
    
    private func fetchFeed(config: RSSFeedConfig) {
        guard let url = URL(string: config.url) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                return
            }
            
            self.parseFeed(data: data, feedConfig: config)
        }
        
        task.resume()
    }
    
    private func parseFeed(data: Data, feedConfig: RSSFeedConfig) {
        currentSource = feedConfig.name
        currentFeedConfig = feedConfig
        parsedArticles = []
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        print("📰 Parsed \(parsedArticles.count) articles from \(feedConfig.name)")

        // Process parsed articles on background queue for thread safety
        articleQueue.async { [weak self] in
            guard let self = self else { return }

            // Get the appropriate keywords for this feed
            let (positiveKeywords, negativeKeywords) = self.getKeywordsForFeed(feedConfig)

            print("🔑 Using keywords for \(feedConfig.name):")
            print("   Mode: \(feedConfig.keywordMode.rawValue)")
            print("   Positive: \(positiveKeywords)")
            print("   Negative: \(negativeKeywords)")

            // Match keywords and filter by negative keywords
            let matchedParsedArticles = self.parsedArticles.compactMap { article -> Article? in
                let matchedArticle = KeywordMatcher.matchKeywords(
                    in: article,
                    keywords: positiveKeywords,
                    negativeKeywords: negativeKeywords
                )

                // Return nil if article matches any negative keyword (filter it out)
                return matchedArticle.matchesNegativeKeyword ? nil : matchedArticle
            }

            print("🔍 Keyword matching: \(matchedParsedArticles.count) articles passed filters from \(feedConfig.name)")

            // Prepare all updates in background
            var updatedAll = self.allArticles
            var updatedMatched = self.matchedArticles

            // Add to all articles (avoid duplicates by URL)
            for article in matchedParsedArticles {
                if !updatedAll.contains(where: { $0.url == article.url }) {
                    updatedAll.append(article)
                }

                // Add matched articles (avoid duplicates)
                if !article.matchedKeywords.isEmpty && !updatedMatched.contains(where: { $0.id == article.id }) {
                    updatedMatched.append(article)
                    print("✅ Added matched article: '\(article.title)' (Keywords: \(article.matchedKeywords.joined(separator: ", ")))")
                }
            }

            // Sort matched by priority
            updatedMatched.sort { $0.priority > $1.priority }

            // Keep only recent articles (last 100 for all, 50 for matched)
            if updatedAll.count > 100 {
                updatedAll = Array(updatedAll.suffix(100))
            }
            if updatedMatched.count > 50 {
                updatedMatched = Array(updatedMatched.prefix(50))
            }

            print("📊 Total matched articles after update: \(updatedMatched.count)")

            // Single atomic update on main thread
            DispatchQueue.main.async {
                self.allArticles = updatedAll
                self.matchedArticles = updatedMatched
            }
        }
    }
    
    /// Returns the appropriate (positive, negative) keywords for a feed based on its keyword mode
    private func getKeywordsForFeed(_ feedConfig: RSSFeedConfig) -> ([String], [String]) {
        switch feedConfig.keywordMode {
        case .globalOnly:
            return (preferences.keywords, preferences.negativeKeywords)
            
        case .feedOnly:
            return (feedConfig.keywords, feedConfig.negativeKeywords)
            
        case .combined:
            // Merge global and feed-specific keywords (removing duplicates)
            let combinedPositive = Array(Set(preferences.keywords + feedConfig.keywords))
            let combinedNegative = Array(Set(preferences.negativeKeywords + feedConfig.negativeKeywords))
            return (combinedPositive, combinedNegative)
        }
    }
    
    /// Gets keywords for a feed by finding it in preferences (used during reprocessing)
    private func getKeywordsForSource(_ source: String) -> ([String], [String]) {
        if let feedConfig = preferences.rssFeeds.first(where: { $0.name == source }) {
            return getKeywordsForFeed(feedConfig)
        }
        // Fallback to global keywords if feed not found
        return (preferences.keywords, preferences.negativeKeywords)
    }
    
    func addMatchedArticle(_ article: Article) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Avoid duplicates
            if !self.matchedArticles.contains(where: { $0.id == article.id }) {
                self.matchedArticles.append(article)
                print("✅ Added matched article: '\(article.title)' (Keywords: \(article.matchedKeywords.joined(separator: ", ")))")
                
                // Sort by priority (most keyword matches first)
                self.matchedArticles.sort { $0.priority > $1.priority }
                
                // Keep only last 50 matched articles
                if self.matchedArticles.count > 50 {
                    self.matchedArticles = Array(self.matchedArticles.prefix(50))
                }
                
                print("📊 Total matched articles: \(self.matchedArticles.count)")
            }
        }
    }
    
    private func reprocessArticles() {
        // Use articleQueue for synchronization with feed processing
        articleQueue.async { [weak self] in
            guard let self = self else { return }

            // Reprocess all articles with appropriate keywords based on their source
            let reprocessedAll = self.allArticles.compactMap { article -> Article? in
                let (positiveKeywords, negativeKeywords) = self.getKeywordsForSource(article.source)

                let matchedArticle = KeywordMatcher.matchKeywords(
                    in: article,
                    keywords: positiveKeywords,
                    negativeKeywords: negativeKeywords
                )

                // Return nil if article matches any negative keyword (filter it out)
                return matchedArticle.matchesNegativeKeyword ? nil : matchedArticle
            }

            // Rebuild matched articles WITH 50-ITEM CAP
            let reprocessedMatched = Array(reprocessedAll
                .filter { !$0.matchedKeywords.isEmpty }
                .sorted { $0.priority > $1.priority }
                .prefix(50))

            // Single atomic update on main thread
            DispatchQueue.main.async {
                self.allArticles = reprocessedAll
                self.matchedArticles = reprocessedMatched
            }
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !data.isEmpty {
            switch currentElement {
            case "title":
                currentTitle += data
            case "description", "content:encoded":
                currentDescription += data
            case "link":
                currentLink += data
            case "pubDate":
                currentPubDate += data
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            // Create article
            let snippet = Article.createSnippet(from: currentDescription)
            let url = URL(string: currentLink)
            let pubDate = parseDate(currentPubDate) ?? Date()
            
            let article = Article(
                title: currentTitle,
                content: currentDescription,
                snippet: snippet,
                source: currentSource,
                url: url,
                publishDate: pubDate
            )
            
            parsedArticles.append(article)
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatters: [DateFormatter] = [
            rssDateFormatter(),
            iso8601Formatter()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    private func rssDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    private func iso8601Formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
