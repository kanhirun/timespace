import UIKit
import Messages

class TimeSheetCollectionViewControllerV2: UIViewController,
                                           TimeSheetCollectionViewDelegate {

    @IBOutlet var contentView: TimeSheetCollectionViewV2!
    
    var conversation: MSConversation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.actionDelegate = self
    }
    
    func didAction() {
        let message = MSMessage(session: MSSession())
        let layout = MSMessageTemplateLayout()
        layout.image = TimeSheetCollectionViewV2.toImage()
        message.layout = layout

        conversation.insert(message, completionHandler: nil)
    }
}
