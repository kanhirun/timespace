import SwiftDate
import Foundation
import Messages
import Engine

struct ViewModel {

    let subHeaderViewModels: [HeaderViewModel]
    let cellViewModels: [[CellViewModel]]
    
    private let service: Service
    private let conversation: MSConversation
    
    init(periods: [TimePeriod], service: Service, conversation: MSConversation) {
        (self.subHeaderViewModels, self.cellViewModels) = ViewModel.generateModels(periods: periods, service: service)
        self.service = service
        self.conversation = conversation
    }
    
    private static func generateModels(periods: [TimePeriod], service: Service) -> ( [HeaderViewModel], [[CellViewModel]] ) {
        var headers = [HeaderViewModel]()
        var cells = [ [CellViewModel] ]()

        var curr: Int? = nil
        var headerIndex = -1

        periods.forEach { period in
            if (curr == nil || period.start!.day > curr! ) {
                let newHeader = HeaderViewModel(period.start!.dateComponents)
                
                headers.append(newHeader)
                cells.append([])
                
                curr = period.start?.day
                headerIndex += 1
            }
            
            let cell = CellViewModel(timePeriod: period, service: service)
            cells[headerIndex].append(cell)
        }
        
        return (headers, cells)
    }
    
    func composeMessage() -> MSMessage {
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        let layout = MSMessageTemplateLayout()
        layout.image = TimeSheetCollectionViewV2.toImage(viewModel: self)
        message.layout = layout

        return message
    }

}

struct HeaderViewModel {
    let headingText: String
    let subHeadingText: String
    
    init(_ component: DateComponents) {
        self.headingText    = WeekDay(rawValue: component.weekday!)!.name(style: .standaloneShort).uppercased()
        self.subHeadingText = "\(Month(rawValue: component.month!)!.name(style: .short)) \(component.day!)"
    }
}

struct CellViewModel {
    let timeText: String
    
    let service: Service
    let period: TimePeriod
    
    init(timePeriod: TimePeriod, service: Service) {
        let ref = timePeriod.start!
        self.timeText = "\(ref.toFormat("h:mm"))\(ref.toFormat("a").lowercased())"
        self.service = service
        self.period = timePeriod
    }
}
