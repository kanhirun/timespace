import UIKit

extension UIImage {
    func imageScaledToSize(size: CGSize) -> UIImage {
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //draw
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext();
        
        return image
    }
    
    func imageScaledToFitSize(size: CGSize) -> UIImage {
        //calculate rect
        let aspect = self.size.width / self.size.height
        
        if (size.width / aspect <= size.height) {
            return self.imageScaledToSize(size: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return self.imageScaledToSize(size: CGSize(width: size.height * aspect, height: size.height))
        }
    }
}


extension TimeSheetCollectionViewV2 {
    static func toImage(viewModel: ViewModel) -> UIImage {
        let vc = UIStoryboard(name: "TimeSheet", bundle: Bundle.main).instantiateInitialViewController()! as! TimeSheetCollectionViewControllerV2
        vc.viewModel = viewModel
        _ = vc.view
        let viewToSnapshot = vc.contentView!
        
        // Positions the camera at the top
        viewToSnapshot.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        // Makes the size smaller
        let compactSize = CGSize(width: viewToSnapshot.bounds.width, height: 265)
        
        // Take snapshot
        UIGraphicsBeginImageContextWithOptions(compactSize, false, 0.0)
        viewToSnapshot.drawHierarchy(in: viewToSnapshot.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
