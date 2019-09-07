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
    
    public convenience init?(fromQueryItems queryItems: [URLQueryItem]) {
        for queryItem in queryItems {
            if let jsonString = queryItem.value, queryItem.name == TimePeriodCollection.queryItemKey {
                let json = JSON(parseJSON: jsonString)
                self.init(fromJSON: json)
                return
            }
        }
        
        return nil
    }
}
