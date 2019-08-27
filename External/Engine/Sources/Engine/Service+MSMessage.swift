import Messages

extension Service {
    convenience public init(message: MSMessage) {
        guard let url = message.url
        else {
            fatalError("Expected message to have url, but found none.")
        }

        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
              fatalError("Expected url to have query items, but found none.")
        }

        self.init(fromQueryItems: queryItems)!
    }
}
