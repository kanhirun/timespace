import JTAppleCalendar

class CalendarDateCellV2: JTAppleCell {
    
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
        case .available:
            dateLabel.textColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 1, alpha: 1)
            circleView.backgroundColor = #colorLiteral(red: 0.9513656497, green: 0.9814328551, blue: 1, alpha: 1)
            circleView.isHidden = false
        case .unavailable:
            dateLabel.textColor = #colorLiteral(red: 0.5803921569, green: 0.5882352941, blue: 0.6, alpha: 1)
            circleView.isHidden = true
        }
        
        dateLabel.text = viewModel!.dateText
        circleView.alpha = viewModel!.alphaBusyOrNotBusy
    }
}
