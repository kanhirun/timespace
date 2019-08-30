import SwiftDate
import Engine

protocol ActionDelegate {
    func didAction(action: ViewAction)
}

enum ViewAction {
    case willBook(service: Service, period: TimePeriod)
    case didBook(service: Service, period: TimePeriod)
    case willSend
}
