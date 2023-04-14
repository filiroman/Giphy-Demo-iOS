//
//  MosaicLayout.swift
//  Giphy Demo
//
//  Created by Roman on 11.04.2023.
//

import UIKit

protocol MosaicLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
}

class MosaicLayout: UICollectionViewLayout {
    private var attributesCache: [UICollectionViewLayoutAttributes] = []
    
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 5
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    weak var delegate: MosaicLayoutDelegate?
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView else {
            return
        }
        
        var offsetX: [CGFloat] = []
        var offsetY: [CGFloat] = [CGFloat].init(repeating: 0, count: numberOfColumns)
        
        let colWidth = contentWidth / CGFloat(numberOfColumns)
        var nextColumn = 0
        
        for column in 0..<numberOfColumns {
            offsetX.append(CGFloat(column) * colWidth)
        }
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let photoSize = delegate?.collectionView(collectionView, sizeForPhotoAtIndexPath: indexPath) ?? .zero
            let widthRatio = photoSize.width / (colWidth - cellPadding*2)
            let height = cellPadding * 2 + (photoSize.height / widthRatio)
            let frame = CGRect(x: offsetX[nextColumn],
                               y: offsetY[nextColumn],
                               width: colWidth,
                               height: height)
            let finalFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = finalFrame
            attributesCache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            offsetY[nextColumn] = offsetY[nextColumn] + height
            
            nextColumn = nextColumn < (numberOfColumns - 1) ? (nextColumn + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attributes in attributesCache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache[indexPath.item]
    }
}
