//
//  Article.swift
//  Anderson
//
//  Article data model with keyword matching
//

import Foundation

struct Article: Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let snippet: String
    let source: String
    let url: URL?
    let imageURL: URL?
    let publishDate: Date
    var matchedKeywords: [String] = []
    var matchesNegativeKeyword: Bool = false
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        snippet: String,
        source: String,
        url: URL? = nil,
        imageURL: URL? = nil,
        publishDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.snippet = snippet
        self.source = source
        self.url = url
        self.imageURL = imageURL
        self.publishDate = publishDate
    }
    
    // Create snippet from content if not provided
    static func createSnippet(from content: String, maxLength: Int = 150) -> String {
        let cleaned = content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleaned.count <= maxLength {
            return cleaned
        }
        
        let truncated = String(cleaned.prefix(maxLength))
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace]) + "..."
        }
        
        return truncated + "..."
    }
    
    // Calculate priority based on number of unique keyword matches
    var priority: Int {
        return matchedKeywords.count
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Keyword Matching

class KeywordMatcher {
    static func matchKeywords(in article: Article, keywords: [String], negativeKeywords: [String] = []) -> Article {
        var matchedArticle = article
        var matched: [String] = []
        
        let searchableText = "\(article.title) \(article.content)".lowercased()
        
        // Check for positive keyword matches
        for keyword in keywords {
            if matchesKeyword(keyword.lowercased(), in: searchableText) {
                matched.append(keyword)
            }
        }
        
        matchedArticle.matchedKeywords = matched
        
        // Check for negative keyword matches
        for negativeKeyword in negativeKeywords {
            if matchesKeyword(negativeKeyword.lowercased(), in: searchableText) {
                matchedArticle.matchesNegativeKeyword = true
                break
            }
        }
        
        return matchedArticle
    }
    
    private static func matchesKeyword(_ keyword: String, in text: String) -> Bool {
        // Handle wildcards (* becomes .*)
        let pattern = keyword
            .replacingOccurrences(of: "*", with: ".*")
            .replacingOccurrences(of: "?", with: ".")
        
        // Try regex match
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(text.startIndex..., in: text)
            return regex.firstMatch(in: text, range: range) != nil
        }
        
        // Fallback to simple contains
        return text.contains(keyword)
    }
    
    // Highlight keywords in text by returning attributed string components
    static func highlightKeywords(in text: String, keywords: [String]) -> [(text: String, isKeyword: Bool)] {
        var result: [(text: String, isKeyword: Bool)] = []
        var remainingText = text
        let lowerText = text.lowercased()
        
        while !remainingText.isEmpty {
            var earliestMatch: (keyword: String, range: Range<String.Index>)?
            
            // Find the earliest keyword match
            for keyword in keywords {
                let searchKeyword = keyword.lowercased()
                if let range = lowerText.range(of: searchKeyword, range: remainingText.startIndex..<remainingText.endIndex) {
                    if earliestMatch == nil || range.lowerBound < earliestMatch!.range.lowerBound {
                        earliestMatch = (keyword, range)
                    }
                }
            }
            
            if let match = earliestMatch {
                // Add text before keyword
                if match.range.lowerBound > remainingText.startIndex {
                    let beforeText = String(remainingText[remainingText.startIndex..<match.range.lowerBound])
                    result.append((text: beforeText, isKeyword: false))
                }
                
                // Add keyword
                let keywordText = String(remainingText[match.range])
                result.append((text: keywordText, isKeyword: true))
                
                // Update remaining text
                remainingText = String(remainingText[match.range.upperBound...])
            } else {
                // No more keywords, add remaining text
                result.append((text: remainingText, isKeyword: false))
                break
            }
        }
        
        return result
    }
}
