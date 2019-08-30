import UIKit
import CoreGraphics

class TimeSheetLayout: UICollectionViewFlowLayout {
    
    private var numberOfColumns: Int {
        return collectionView!.numberOfSections
    }
    
    var cellPadding: CGFloat = 6
    
    private var cellAttrs = [UICollectionViewLayoutAttributes]()
    private var headerAttrs: UICollectionViewLayoutAttributes?
    
    private let headerOffSet: CGFloat = 70
    
    var cellHeight: CGFloat = 60
    
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
        guard cellAttrs.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        headerAttrs = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0))
        
        // Tracking offsets
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        // Handles the rest of the content
        for column in 0 ..< numberOfColumns {
            for item in 0 ..< collectionView.numberOfItems(inSection: column) {
                let indexPath = IndexPath(item: item, section: column)
                
                // Calculates frame
                let height = cellPadding * 2 + cellHeight
                let frame = CGRect(x: xOffset[column], y: yOffset[column] + headerOffSet, width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // Sets attrs to cell at indexPath
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cellAttrs.append(attributes)
                
                // Expands content height
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
            }
            
            xOffset[column] = xOffset[column] + columnWidth
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleCellLayoutAttributes = cellAttrs.filter { rect.intersects($0.frame) }
        let visibleHeaderLayoutAttributes = rect.intersects(headerAttrs!.frame) ? [headerAttrs!] : []
        
        let visibleLayoutAttributes = Array(visibleCellLayoutAttributes) + Array(visibleHeaderLayoutAttributes)
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttrs[indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader else { return nil }
        
        if headerAttrs != nil {
            return headerAttrs
        }

        let frame = CGRect(x: 0, y: 0, width: contentWidth, height: headerOffSet)
        let attrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
        attrs.frame = frame
        
        return attrs
    }
    
}
