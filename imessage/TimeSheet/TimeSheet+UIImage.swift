import UIKit

extension TimeSheetCollectionViewV2 {
    static func toImage() -> UIImage {
        let vc = UIStoryboard(name: "TimeSheet", bundle: Bundle.main).instantiateInitialViewController()! as! TimeSheetCollectionViewControllerV2
        _ = vc.view
        let viewToSnapshot = vc.contentView!
        
        // Positions the camera at the top
        viewToSnapshot.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        // Makes the size smaller
        let compactSize = CGSize(width: viewToSnapshot.bounds.width, height: 300)
        
        // Take snapshot
        UIGraphicsBeginImageContextWithOptions(compactSize, false, 0.0)
        viewToSnapshot.drawHierarchy(in: viewToSnapshot.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
