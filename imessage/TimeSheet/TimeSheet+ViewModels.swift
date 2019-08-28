import SwiftDate
import Foundation

//let periods = [
//    TimePeriod(start: DateInRegion("2019-08-01T10:00:00Z")!, duration: 1.hours),
//    TimePeriod(start: DateInRegion("2019-08-01T09:00:00Z")!, duration: 1.hours),
//    TimePeriod(start: DateInRegion("2019-08-01T08:00:00Z")!, duration: 1.hours),
//    TimePeriod(start: DateInRegion("2019-08-01T07:00:00Z")!, duration: 1.hours),
//    TimePeriod(start: DateInRegion("2019-08-01T06:00:00Z")!, duration: 1.hours),
//    TimePeriod(start: DateInRegion("2019-08-01T05:00:00Z")!, duration: 1.hours),
//
////    TimePeriod(start: DateInRegion("2019-08-02T10:00:00Z")!, duration: 1.hours),
////    TimePeriod(start: DateInRegion("2019-08-02T11:00:00Z")!, duration: 1.hours),
////
////    TimePeriod(start: DateInRegion("2019-08-03T20:00:00Z")!, duration: 1.hours),
////    TimePeriod(start: DateInRegion("2019-08-03T21:00:00Z")!, duration: 1.hours),
////    TimePeriod(start: DateInRegion("2019-08-03T22:00:00Z")!, duration: 1.hours),
//]

let periods = Array(repeating: TimePeriod(start: DateInRegion("2019-08-01T10:00:00Z")!, duration: 1.hours), count: 50)

struct ViewModel {

    let subHeaderViewModels: [HeaderViewModel]
    let cellViewModels: [[CellViewModel]]
    
    init() {
        (self.subHeaderViewModels, self.cellViewModels) = ViewModel.generateModels(periods: periods)
    }
    
    private static func generateModels(periods: [TimePeriod]) -> ( [HeaderViewModel], [[CellViewModel]] ) {
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
            
            let cell = CellViewModel(period)
            cells[headerIndex].append(cell)
        }
        
        return (headers, cells)
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
    
    init(_ timePeriod: TimePeriod) {
        let ref = timePeriod.start!
        self.timeText = "\(ref.toFormat("h:mm"))\(ref.toFormat("a").lowercased())"
    }
}
