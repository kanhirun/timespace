import UIKit
import Messages

class TimeSheetCollectionViewControllerV2: UIViewController,
                                           TimeSheetCollectionViewDelegate,
                                           UICollectionViewDelegateFlowLayout {

    @IBOutlet var contentView: TimeSheetCollectionViewV2!
    
    var conversation: MSConversation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.actionDelegate = self
        contentView.delegate = self
    }
    
    func didAction() {
        let message = MSMessage(session: MSSession())
        let layout = MSMessageTemplateLayout()
        layout.image = TimeSheetCollectionViewV2.toImage()
        message.layout = layout

        conversation.insert(message, completionHandler: nil)
    }
    
    // todo: Not sure why this didn't work delegating to collectionView!
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.intrinsicContentSize.width,
                      height: TimeSheetHeaderView.fixedHeaderHeight)
    }
}
