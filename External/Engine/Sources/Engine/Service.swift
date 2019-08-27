import Foundation
import SwiftDate
import SwiftyJSON

public class Service {
    public let name: String
    public let duration: TimeInterval
    
    convenience init(name: String, duration: DateComponents) {
        self.init(name: name, duration: duration.timeInterval)
    }
    
    init(name: String, duration: TimeInterval) {
        self.name = name
        self.duration = duration
    }
}
