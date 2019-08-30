import JTAppleCalendar

class CalendarView: JTAppleCalendarView {

    override func awakeFromNib() {
        super.awakeFromNib()

        allowsMultipleSelection = true
        scrollDirection = .horizontal
        scrollingMode   = .stopAtEachCalendarFrame
        showsHorizontalScrollIndicator = false
    }

}

class CalendarHeader: JTAppleCollectionReusableView {
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var sendButton: UIButton!
    
    var actionDelegate: ActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sendButton.addTarget(self, action: #selector(send), for: .primaryActionTriggered)
    }
    
    @objc func send() {
        actionDelegate?.didAction(action: .willSend)
    }
    
    func updateUI(_ range: (start: Date, end: Date) ) {
        let aDate = range.start
        monthLabel.text = "\(aDate.monthName(.default)) \(aDate.toFormat("YYYY"))"
    }
}

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
