private func fetchFeed(config: RSSFeedConfig) {
    guard config.enabled else { return }

    guard let url = URL(string: config.url),
          let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
        print("Skipping invalid feed URL: \(config.url)")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        if let err = error as? URLError {
            print("Fetch failed (\(config.name)): \(err.code) \(err.localizedDescription) [\(url.absoluteString)]")
            return
        } else if let error = error {
            print("Fetch failed (\(config.name)): \(error.localizedDescription) [\(url.absoluteString)]")
            return
        }

        guard let data = data, !data.isEmpty else {
            print("Empty response for feed: \(config.name) [\(url.absoluteString)]")
            return
        }

        self?.parseFeed(data: data, source: config.name)
    }
    task.resume()
}
