import SwiftDate
import Messages

extension TimePeriodCollection {
    public convenience init?(fromMessage message: MSMessage) {
        guard let url = message.url
        else {
            debugPrint("Expected message to have url, but found none.")
            return nil
        }
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            debugPrint("Expected url to have query items, but found none.")
            return nil
        }
        
        self.init(fromQueryItems: queryItems)
    }
}
