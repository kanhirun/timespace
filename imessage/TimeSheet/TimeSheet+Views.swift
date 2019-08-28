import UIKit
import SwiftDate

protocol TimeSheetCollectionViewDelegate {
    func didAction()
}


// MARK: - Collection View


class TimeSheetCollectionViewV2: UICollectionView {

    var actionDelegate: TimeSheetCollectionViewDelegate?
    
    var viewModel = ViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataSource = self
        showsVerticalScrollIndicator = false
        
        collectionViewLayout = TimeSheetLayout()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // note: superview can be the UISnapshotView when taking screenshotss
        if let superview = superview {
            trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
}


// MARK: - Custom Layout


class TimeSheetLayout: UICollectionViewLayout {
    
    private var numberOfColumns: Int {
        return collectionView!.numberOfSections
    }

    private var cellPadding: CGFloat = 6

    private var cache = [UICollectionViewLayoutAttributes]()
    
    private let cellHeight: CGFloat = 60
    
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }

        // Tracking offsets
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        // Handles the rest of the content
        for column in 0 ..< collectionView.numberOfSections {
            for item in 0 ..< collectionView.numberOfItems(inSection: column) {
                let indexPath = IndexPath(item: item, section: column)
                
                // Calculates frame
                let height = cellPadding * 2 + cellHeight
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // Sets attrs to cell at indexPath
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // Expands content height
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
            }
            
            xOffset[column] = xOffset[column] + columnWidth
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }

        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

}


// MARK: - Data Source


extension TimeSheetCollectionViewV2: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellViewModels[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSheetCollectionViewCell",
                                                      for: indexPath) as! TimeSheetCollectionViewCell

        cell.delegate = actionDelegate
        cell.viewModel = viewModel.cellViewModels[indexPath.section][indexPath.row]

        return cell
    }
}


// MARK: - Header View


class TimeSheetHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var subHeaderViews: UIStackView!

    var subHeaderViewModels: [HeaderViewModel]? {
        didSet {
            installSubHeaders()
        }
    }
    
    private func installSubHeaders() {
        subHeaderViewModels?.forEach { subHeaderVM in
            let subHeaderView: DateCell = .fromNib()

            subHeaderView.viewModel = subHeaderVM

            self.subHeaderViews.addArrangedSubview(subHeaderView)
        }
    }
}


// MARK: - Cell View


class TimeSheetCollectionViewCell: UICollectionViewCell {

    @IBOutlet var timeButton: UIButton!
    
    var viewModel: CellViewModel? {
        didSet {
            timeButton.setTitle(self.viewModel!.timeText, for: .normal)
        }
    }
    
    var delegate: TimeSheetCollectionViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeButton.addTarget(self, action: #selector(didAction), for: .primaryActionTriggered)
    }
    
    @objc func didAction() {
        delegate?.didAction()
    }

}

class TimeButtonV2: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 105, height: 60)
    }
}
