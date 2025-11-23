//
//  RSSFeedService.swift
//  MatrixMonitor
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
    
    // XML parsing state
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentSource = ""
    private var parsedArticles: [Article] = []
    
    override init() {
        super.init()
        
        // Listen for preference changes
        preferences.$keywords
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
        
        for feed in enabledFeeds {
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
            
            self.parseFeed(data: data, source: config.name)
        }
        
        task.resume()
    }
    
    private func parseFeed(data: Data, source: String) {
        currentSource = source
        parsedArticles = []
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        // Process parsed articles
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Match keywords
            let matchedParsedArticles = self.parsedArticles.map { article in
                KeywordMatcher.matchKeywords(in: article, keywords: self.preferences.keywords)
            }
            
            // Add to all articles (avoid duplicates by URL)
            for article in matchedParsedArticles {
                if !self.allArticles.contains(where: { $0.url == article.url }) {
                    self.allArticles.append(article)
                }
                
                // Add matched articles
                if !article.matchedKeywords.isEmpty {
                    self.addMatchedArticle(article)
                }
            }
            
            // Keep only recent articles (last 100)
            if self.allArticles.count > 100 {
                self.allArticles = Array(self.allArticles.suffix(100))
            }
        }
    }
    
    func addMatchedArticle(_ article: Article) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Avoid duplicates
            if !self.matchedArticles.contains(where: { $0.id == article.id }) {
                self.matchedArticles.append(article)
                
                // Sort by priority (most keyword matches first)
                self.matchedArticles.sort { $0.priority > $1.priority }
                
                // Keep only last 50 matched articles
                if self.matchedArticles.count > 50 {
                    self.matchedArticles = Array(self.matchedArticles.prefix(50))
                }
            }
        }
    }
    
    private func reprocessArticles() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Reprocess all articles with new keywords
            self.allArticles = self.allArticles.map { article in
                KeywordMatcher.matchKeywords(in: article, keywords: self.preferences.keywords)
            }
            
            // Rebuild matched articles
            self.matchedArticles = self.allArticles
                .filter { !$0.matchedKeywords.isEmpty }
                .sorted { $0.priority > $1.priority }
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
