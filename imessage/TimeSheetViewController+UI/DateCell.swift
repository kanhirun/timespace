import UIKit
import SwiftDate

class DateCell: UIView {
    @IBOutlet var weekdayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    func updateUI(_ period: TimePeriod) {
        let ref = period.start!

        weekdayLabel.text = ref.weekdayName(.short).uppercased()
        dateLabel.text = "\(ref.monthName(.short)) \(ref.day)"
    }
}
