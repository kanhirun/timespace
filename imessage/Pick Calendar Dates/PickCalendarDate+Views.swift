import JTAppleCalendar
import class Engine.CalendarDateViewModel
import UIKit

class CalendarDateCell: JTACDayCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var circleView: UIView!
    
    var viewModel : CalendarDateViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        circleView.layer.cornerRadius = circleView.bounds.width / 2.0
    }
    
    // todo: remove me and use KVO
    func updateUI() {
        switch viewModel!.viewState {
        case .selected:
            dateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            circleView.backgroundColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 1, alpha: 1)
            circleView.isHidden = false
            circleView.alpha = 1.0
        case .available:
            circleView.isHidden = false

            switch viewModel!.busyLevel {
            case .high:
                dateLabel.textColor = #colorLiteral(red: 0.8588235294, green: 0.01176470588, blue: 0, alpha: 1)
                circleView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.6705882353, blue: 0.6470588235, alpha: 1)
            case .medium:
                dateLabel.textColor = #colorLiteral(red: 0.8156862745, green: 0.2705882353, blue: 0.1333333333, alpha: 1)
                circleView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.7725490196, blue: 0.5568627451, alpha: 1)
            case .low:
                dateLabel.textColor = #colorLiteral(red: 0.8705882353, green: 0.4196078431, blue: 0, alpha: 1)
                circleView.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9529411765, blue: 0.662745098, alpha: 1)
            case .free:
                dateLabel.textColor = #colorLiteral(red: 0.3029262424, green: 0.3029828668, blue: 0.3029187918, alpha: 1)
                circleView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        case .unavailable:
            dateLabel.textColor = #colorLiteral(red: 0.796245873, green: 0.8126872182, blue: 0.8302764297, alpha: 1)
            circleView.isHidden = true
            circleView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        dateLabel.text = viewModel!.dateText
    }
}
