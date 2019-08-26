import SwiftDate
import Foundation
import SwiftyJSON

extension Array: QueryItemRepresentable where Element : TimePeriod {
    var queryItem: URLQueryItem {
        return URLQueryItem(name: [TimePeriod].queryItemKey, value: self.toJSON().rawString())
    }
    
    static var queryItemKey: String {
        return "TimePeriods"
    }
    
    public static func fromQueryItems(_ queryItems: [URLQueryItem]) -> [TimePeriod]? {
        for queryItem in queryItems {
            if let value = queryItem.value, queryItem.name == [TimePeriod].queryItemKey {
                let json = JSON(parseJSON: value)
                return [TimePeriod].fromJSON(json)
            }
        }
        
        return nil
    }
}
