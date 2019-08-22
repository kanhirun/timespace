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
