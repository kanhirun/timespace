import UIKit
import SwiftDate
import Engine

class ConfirmationView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    func updateUI(_ period: TimePeriod, _ service: Service) {
        nameLabel.text = service.name
        timeLabel.text = "\(formatted(period.start!))-\(formatted(period.end!))"
    }
    
    func asImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func formatted(_ date: DateInRegion) -> String {
        return date.toString(.time(.short))
    }
}
