import JTAppleCalendar

class CalendarDateCell: JTAppleCell {
    
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
            dateLabel.textColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 1, alpha: 1)
            circleView.backgroundColor = #colorLiteral(red: 0.8828615546, green: 0.9683210254, blue: 1, alpha: 1)
            circleView.isHidden = false
            circleView.alpha = viewModel!.alphaBusyOrNotBusy
        case .unavailable:
            dateLabel.textColor = #colorLiteral(red: 0.796245873, green: 0.8126872182, blue: 0.8302764297, alpha: 1)
            circleView.isHidden = true
            circleView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            circleView.alpha = viewModel!.alphaBusyOrNotBusy
        }
        
        dateLabel.text = viewModel!.dateText
    }
}
