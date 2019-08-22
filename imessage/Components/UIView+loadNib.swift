import UIKit


extension UIView {
    static func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)!.first! as! T
    }
}
