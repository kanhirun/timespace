import SwiftDate
import Foundation
import SwiftyJSON

extension Array: QueryItemRepresentable where Element : TimePeriod {
    public var queryItem: URLQueryItem {
        return URLQueryItem(name: [TimePeriod].queryItemKey,
                            value: try! String(data: self.toJSON().rawData(), encoding: .ascii))
    }

    static var queryItemKey: String {
        return "TimePeriods"
    }
    
    public static func fromQueryItems(_ queryItems: [URLQueryItem]) -> [TimePeriod]? {
        for queryItem in queryItems {
            if let jsonString = queryItem.value, queryItem.name == [TimePeriod].queryItemKey {
                let json = JSON(parseJSON: jsonString)
                return [TimePeriod].fromJSON(json)
            }
        }
        
        return nil
    }
}
