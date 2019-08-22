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

        backgroundColor = cellState.date.isToday ? .lightGray : .white

        if cellState.isSelected {
            selectedView.isHidden = false
            dateLabel.textColor = .white
        } else {
            selectedView.isHidden = true
            dateLabel.textColor = .black
        }
    }
}
