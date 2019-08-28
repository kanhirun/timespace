import SwiftDate
import Foundation

struct ViewModel {

    let subHeaderViewModels: [HeaderViewModel]
    let cellViewModels: [ [CellViewModel] ]
    
    init() {
        self.subHeaderViewModels = [
            HeaderViewModel(DateComponents(month: 1, day: 12, weekday: 1)),
            HeaderViewModel(DateComponents(month: 1, day: 13, weekday: 2)),
            HeaderViewModel(DateComponents(month: 1, day: 14, weekday: 3)),
        ]

        self.cellViewModels = [
            [
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-12T01:00:00Z")!, end: DateInRegion())),
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-12T02:00:00Z")!, end: DateInRegion())),
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-12T03:00:00Z")!, end: DateInRegion())),
            ],
            [
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-13T11:00:00Z")!, end: DateInRegion())),
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-13T12:00:00Z")!, end: DateInRegion())),
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-13T13:00:00Z")!, end: DateInRegion())),
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-13T14:00:00Z")!, end: DateInRegion())),
            ],
            [
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-14T20:00:00Z")!, end: DateInRegion())),
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-14T21:00:00Z")!, end: DateInRegion())),
                CellViewModel(TimePeriod(start: DateInRegion("2019-01-14T22:00:00Z")!, end: DateInRegion())),
            ],
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
