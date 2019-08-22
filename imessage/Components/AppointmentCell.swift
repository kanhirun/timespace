import UIKit
import SwiftDate

class AppointmentCell: UIView {
    @IBOutlet var timeButton: TimeButton!
    
    func updateUI(_ period: TimePeriod) {
        let ref = period.start!
        timeButton.setTitle("\(ref.toFormat("h:mm"))\(ref.toFormat("a").lowercased())", for: .normal)
    }
}

@IBDesignable
class TimeButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius  = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        didSet {
            layer.borderColor = self.titleLabel?.textColor.cgColor
        }
    }
}
