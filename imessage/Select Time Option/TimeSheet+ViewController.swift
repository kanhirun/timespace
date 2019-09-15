import UIKit
import Messages
import Engine

class TimeSheetCollectionViewControllerV2: UIViewController,
                                           ActionDelegate {

    @IBOutlet var contentView: TimeSheetCollectionViewV2!
    
    var conversation: MSConversation!
    var viewModel: ViewModel!
    
    weak var actionDelegate: ActionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.actionDelegate = self
        contentView.viewModel = viewModel
    }
    
    func didAction(action: ViewAction) {
        switch action {
        case .willBook(let service, let period):
            let layout = MSMessageTemplateLayout()
            let view: ConfirmationView = .fromNib()
            view.updateUI(period, service)
            layout.image = view.asImage()
            layout.caption = "This time works for me"
            layout.subcaption = "Add to calendar"
            
            let message = MSMessage(session: conversation.selectedMessage!.session!)
            message.layout = layout
            
            conversation.insert(message) { err in
                if let err = err {
                    debugPrint(err)
                }
                
                let calendar = AppleCalendar()

                if calendar.book(service: service, period: period) {
                    self.actionDelegate?.didAction(action: .didBook(service: service, period: period))
                } else {
                    debugPrint("booking failed")
                }
            }
        default:
            return
        }
    }
}
