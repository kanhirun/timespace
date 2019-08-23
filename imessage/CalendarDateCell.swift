import JTAppleCalendar
import UIKit

class CalendarDateCell: JTAppleCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var selectedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius =  13
    }
    
    func updateUI(_ cellState: CellState) {
        dateLabel.text = cellState.text
        
        if cellState.isSelected {
            selectedView.isHidden = false
            dateLabel.textColor = .white
        } else {
            selectedView.isHidden = true

            if cellState.date.isInPast && !cellState.date.isToday {
                isUserInteractionEnabled = false
                dateLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            } else {
                isUserInteractionEnabled = true
                dateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
    }
}
