import SwiftDate
import Foundation

struct ViewModel {
    
    var numberOfCells: Int {
        return cellViewModels.count
    }

    let subHeaderViewModels: [HeaderViewModel]
    let cellViewModels: [CellViewModel]
    
    init() {
        self.subHeaderViewModels = [
            HeaderViewModel(DateComponents(month: 1, day: 12, weekday: 1)),
            HeaderViewModel(DateComponents(month: 1, day: 12, weekday: 1)),
            HeaderViewModel(DateComponents(month: 1, day: 12, weekday: 1)),
        ]
        self.cellViewModels = [
            CellViewModel(TimePeriod(start: DateInRegion(), end: DateInRegion())),
            CellViewModel(TimePeriod(start: 2.days.fromNow.inDefaultRegion(), end: DateInRegion())),
            CellViewModel(TimePeriod(start: 2.days.fromNow.inDefaultRegion(), end: DateInRegion())),
            CellViewModel(TimePeriod(start: 2.days.fromNow.inDefaultRegion(), end: DateInRegion())),
            CellViewModel(TimePeriod(start: 2.days.fromNow.inDefaultRegion(), end: DateInRegion())),
        ]
    }
    
    func generate() {
//        guard periods.count > 0 else {
//            return
//        }
//
//        // Pointer for tracking whether a new column should be created
//        var currDay: Int? = nil
//        var currColumn: UIStackView!
//
//        periods.forEach { period in
//            if (currDay == nil || period.start!.day > currDay! ) {
//                currColumn = createColumnView(period)
//
//                addArrangedSubview(currColumn!)
//
//                currDay = period.start?.day
//            }
//
//            let timeCell: AppointmentCell = .fromNib()
//            timeCell.updateUI(period)
//            timeCell.timeButton.addTarget(self, action: #selector(TimeSheetView.selectAppointment(sender:)), for: .primaryActionTriggered)
//
//            currColumn.addArrangedSubview(timeCell)
//        }
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
