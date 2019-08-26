import UIKit
import Messages

import SwiftyJSON
import SwiftDate
import Engine

class MessagesViewController: MSMessagesAppViewController {

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        // Use this method to configure the extension and restore previously stored state.
        
        if let message = conversation.selectedMessage  {
            guard let url = message.url else {
                debugPrint("no url")
                return
            }
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
                debugPrint("no url components")
                return
            }
            guard let queryItems = components.queryItems else {
                debugPrint("no query items")
                return
            }
            
            // get data
            let data = queryItems.first { $0.name == "data" }!
            let value = data.value!
            let json = JSON(parseJSON: value)
            let periods = [TimePeriod].fromJSON(json)
            
            let service = Service(fromQueryItems: queryItems)!

            present(instantiateTimeSheetViewController(periods, conversation, service), animated: false, completion: nil)
        } else {
            present(instantiateServiceViewController(conversation), animated: false, completion: nil)
        }
    }
    
    func instantiateTimeSheetViewController(_ data: [TimePeriod], _ conversation: MSConversation, _ service: Service) -> UIViewController {
        let nav: UINavigationController = {
            let rootVC = self.storyboard!.instantiateViewController(withIdentifier: "TimeSheetViewController") as! TimeSheetViewController
            rootVC.data = data
            rootVC.activeConversation = conversation
            rootVC.controller = self
            rootVC.service = service
            return UINavigationController(rootViewController: rootVC)
        }()
        
        return nav
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
        // Called when the user taps the send button.
        dismiss()
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
