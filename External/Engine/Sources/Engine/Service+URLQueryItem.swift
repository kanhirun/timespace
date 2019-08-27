import Foundation
import SwiftyJSON

extension Service: QueryItemRepresentable {

    var queryItem: URLQueryItem {
        return URLQueryItem(name: Service.queryItemKey,
                            value: try! String(data: self.toJSON().rawData(), encoding: .ascii))
    }
    
    static var queryItemKey: String {
        return "Service"
    }
    
    convenience public init?(fromQueryItems queryItems: [URLQueryItem]) {
        for queryItem in queryItems {
            if let jsonString = queryItem.value, queryItem.name == Service.queryItemKey {
                let json = JSON(parseJSON: jsonString)
                self.init(fromJSON: json)
                return
            }
        }
        
        return nil
    }
}
