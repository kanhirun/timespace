import UIKit

@IBDesignable
class XibView: UIView {
    
    @IBInspectable
    var nibName: String?

    var contentView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else {
            return
        }
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(view)
        
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        guard let nibName = nibName else {
            return nil
        }
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
