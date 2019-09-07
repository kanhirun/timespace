import SwiftDate
import Messages

extension Array where Element : TimePeriod {
    public static func fromMessage(_ message: MSMessage) -> [TimePeriod]? {
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
        
        return TimePeriodCollection.fromQueryItems(queryItems)
    }
}
