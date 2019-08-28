import UIKit
import Messages
import Engine

class TimeSheetCollectionViewControllerV2: UIViewController,
                                           TimeSheetCollectionViewDelegate {

    @IBOutlet var contentView: TimeSheetCollectionViewV2!
    
    var conversation: MSConversation!
    var viewModel: ViewModel!
    
    var actionDelegate: TimeSheetCollectionViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.actionDelegate = self
        contentView.viewModel = viewModel
    }
    
    func didAction(action: ViewAction) {
        switch action {
        case .booked(let service, let period):
            let layout = MSMessageTemplateLayout()
            let view: ConfirmationView = .fromNib()
            view.updateUI(period, service)
            layout.image = view.asImage()
            
            let message = MSMessage(session: conversation.selectedMessage!.session!)
            message.layout = layout
            
            conversation.insert(message) { err in
                if let err = err {
                    debugPrint(err)
                }
                
                let calendar = AppleCalendar()
                _ = calendar.book(service: service, period: period)
                
                self.actionDelegate?.didAction(action: action)
            }
        }
    }
}
