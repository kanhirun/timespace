import UIKit
import SwiftDate
import Messages
import Engine

class TimeSheetViewController: UIViewController {
    
    var contentView: TimeSheetView? = nil
    var data: [TimePeriod]!

    var activeConversation: MSConversation? = nil

    weak var controller: MessagesViewController? = nil

    var service: Service!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Define
        contentView = TimeSheetView(periods: data, controller: self)

        // Add
        view.addSubview(contentView!)
        
        // Layout
        let safeArea = view.safeAreaLayoutGuide
        contentView!.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        contentView!.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Actions
    
    func selectAppointment(period: TimePeriod) {
        let layout = MSMessageTemplateLayout()
        let view: ConfirmationView = .fromNib()
        view.updateUI(period, service)
        layout.image = view.asImage()

        let message = MSMessage(session: activeConversation!.selectedMessage!.session!)
        message.layout = layout
        
        activeConversation?.insert(message) { err in
            if let err = err {
                debugPrint(err)
            }
            
            let calendar = AppleCalendar()
            _ = calendar.book(service: self.service, period: period)
            
            self.controller!.dismiss()
        }
    }
}
