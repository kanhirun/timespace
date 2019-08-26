import Foundation
import SwiftyJSON

extension Service: QueryItemRepresentable {

    var queryItem: URLQueryItem {
        return URLQueryItem(name: Service.queryItemKey, value: self.toJSON().rawString())
    }
    
    static var queryItemKey: String {
        return "Service"
    }
    
    public init?(fromQueryItems queryItems: [URLQueryItem]) {
        for queryItem in queryItems {
            if let value = queryItem.value, queryItem.name == Service.queryItemKey {
                let json = JSON(parseJSON: value)
                self.init(fromJSON: json)
                return
            }
        }
        
        return nil
    }
}
