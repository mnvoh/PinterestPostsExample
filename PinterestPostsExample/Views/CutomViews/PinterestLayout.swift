//
//  PinterestLayout.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/17/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import UIKit


protocol PinterestLayoutDelegate {
  
  /// Method to ask the delegate for the height of the image
  func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath ,
                      withWidth: CGFloat) -> CGFloat
  
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
  
  /// Custom attribute
  var photoHeight: CGFloat = 0.0
  
  /// Override copyWithZone to conform to NSCopying protocol
  override func copy(with zone: NSZone? = nil) -> Any {
    let copy = super.copy(with: zone) as! PinterestLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  /// Override isEqual
  override func isEqual(_ object: Any?) -> Bool {
    if let attributtes = object as? PinterestLayoutAttributes {
      if( attributtes.photoHeight == photoHeight  ) {
        return super.isEqual(object)
      }
    }
    return false
  }
  
}


class PinterestLayout: UICollectionViewLayout {
  
  /// Pinterest Layout Delegate
  var delegate:PinterestLayoutDelegate!
  
  /// Configurable properties
  var numberOfColumns = 2
  var cellPadding: CGFloat = 8.0
  
  /// Array to keep a cache of attributes.
  private var cache = [PinterestLayoutAttributes]()
  
  /// Content height and size
  private var contentHeight:CGFloat  = 0.0
  private var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return collectionView!.bounds.width - (insets.left + insets.right)
  }
  
  override class var layoutAttributesClass: AnyClass {
    return PinterestLayoutAttributes.self
  }
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func prepare() {
    // Only calculate once
    if cache.isEmpty {
      
      // Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
      let columnWidth = (contentWidth - cellPadding * 2) / CGFloat(numberOfColumns)
      var xOffset = [CGFloat]()
      for column in 0 ..< numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth + cellPadding)
      }
      var column = 0
      var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
      
      // Iterates through the list of items in the first section
      for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
        
        let indexPath = IndexPath(item: item, section: 0)
        
        // Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
        let width = columnWidth - cellPadding * 2
        let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:width)
        let height = cellPadding +  photoHeight + cellPadding
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        
        // Creates an UICollectionViewLayoutItem with the frame and add it to the cache
        let attributes = PinterestLayoutAttributes(forCellWith: indexPath)
        attributes.photoHeight = photoHeight
        attributes.frame = insetFrame
        cache.append(attributes)
        
        // Updates the collection view content height
        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + height
        
        column = column >= (numberOfColumns - 1) ? 0 : column + 1
      }
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes  in cache {
      if attributes.frame.intersects(rect) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
}
