import SwiftDate
import Foundation
import SwiftyJSON

extension TimePeriodCollection: QueryItemRepresentable  {
    public var queryItem: URLQueryItem {
        return URLQueryItem(name: TimePeriodCollection.queryItemKey,
                            value: try! String(data: self.toJSON().rawData(), encoding: .ascii))
    }

    static var queryItemKey: String {
        return "TimePeriods"
    }
    
    public static func fromQueryItems(_ queryItems: [URLQueryItem]) -> [TimePeriod]? {
        for queryItem in queryItems {
            if let jsonString = queryItem.value, queryItem.name == TimePeriodCollection.queryItemKey {
                let json = JSON(parseJSON: jsonString)
                return TimePeriodCollection.fromJSON(json)
            }
        }
        
        return nil
    }
}
