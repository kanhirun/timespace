import UIKit
import Foundation
import JTAppleCalendar

class CalendarHeader: JTAppleCollectionReusableView {
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var sendButton: UIButton!
    
    func updateUI(_ range: (start: Date, end: Date) ) {
        let aDate = range.start
        monthLabel.text = "\(aDate.monthName(.default)) \(aDate.toFormat("YYYY"))"
    }
}
