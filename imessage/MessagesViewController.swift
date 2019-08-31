import UIKit
import Messages

import SwiftyJSON
import SwiftDate
import Engine


protocol MessageDelegate: class {
    
    func willTransition(to presentationStyle: MSMessagesAppPresentationStyle)
    func didTransition(to presentationStyle: MSMessagesAppPresentationStyle)
    func didStartSending(_ message: MSMessage, conversation: MSConversation)

}

class MessagesViewController: MSMessagesAppViewController, ActionDelegate {
    
    weak var messageDelegate : MessageDelegate?

    func didAction(action: ViewAction) {
        switch action {
        case .didBook(_):
            dismiss()
        default:
            return
        }
    }

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        // Use this method to configure the extension and restore previously stored state.

        let vc = UIStoryboard(name: "Calendar", bundle: Bundle.main).instantiateInitialViewController()!
        messageDelegate = vc as? MessageDelegate
        present(vc, animated: true, completion: nil)
//        if let message = conversation.selectedMessage  {
//            guard let periods = [TimePeriod].fromMessage(message) else {
//                return
//            }
//            let service = Service(message: message)
//
//            present(instantiateTimeSheetViewController(periods, conversation, service), animated: false, completion: nil)
//        } else {
//            present(instantiateServiceViewController(conversation), animated: false, completion: nil)
//        }
    }
    
    func instantiateTimeSheetViewController(_ data: [TimePeriod], _ conversation: MSConversation, _ service: Service) -> UIViewController {
        let destination = UIStoryboard(name: "TimeSheet", bundle: Bundle.main).instantiateInitialViewController() as! TimeSheetCollectionViewControllerV2
        
        destination.viewModel = ViewModel(
            periods: data,
            service: service,
            conversation: conversation
        )
        destination.conversation = conversation
        destination.actionDelegate = self
        
        return destination
    }
    
    func instantiateServiceViewController(_ conversation: MSConversation) -> UIViewController {
        let nav: UINavigationController = {
            let rootVC = self.storyboard!.instantiateViewController(withIdentifier: "ServicesViewController") as! ServicesViewController
            rootVC.activeConversation = conversation
            return UINavigationController(rootViewController: rootVC)
        }()
        
        return nav
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        messageDelegate?.didStartSending(message, conversation: conversation)
        dismiss()
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        messageDelegate?.willTransition(to: presentationStyle)
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        messageDelegate?.didTransition(to: presentationStyle)
    }

}
