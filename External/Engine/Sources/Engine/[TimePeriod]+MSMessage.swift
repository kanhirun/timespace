import SwiftDate
import Messages

extension Array where Element : TimePeriod {
    public static func fromMessage(_ message: MSMessage) -> [TimePeriod] {
        guard let url = message.url
        else {
            fatalError("Expected message to have url, but found none.")
        }
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            fatalError("Expected url to have query items, but found none.")
        }
        
        return [TimePeriod].fromQueryItems(queryItems)!
    }
}
