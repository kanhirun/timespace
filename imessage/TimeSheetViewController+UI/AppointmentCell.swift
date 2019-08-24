import UIKit
import SwiftDate

class AppointmentCell: UIView {
    @IBOutlet var timeButton: TimeButton!
    
    func updateUI(_ period: TimePeriod) {
        timeButton.period = period

        let ref = period.start!
        timeButton.setTitle("\(ref.toFormat("h:mm"))\(ref.toFormat("a").lowercased())", for: .normal)
    }
}


class TimeButton: UIButton {
    var period: TimePeriod!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
}
