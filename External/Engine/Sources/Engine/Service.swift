import Foundation
import SwiftDate
import SwiftyJSON

public class ServiceRepository {
    public static let shared = ServiceRepository(value: nil)
    
    public var value: Service?
    
    init(value: Service?) {
        self.value = value
    }
}

public class Service {
    
    public let name: String
    public let duration: TimeInterval
    
    public convenience init(name: String, duration: DateComponents) {
        self.init(name: name, duration: duration.timeInterval)
    }
    
    init(name: String, duration: TimeInterval) {
        self.name = name
        self.duration = duration
    }
}
