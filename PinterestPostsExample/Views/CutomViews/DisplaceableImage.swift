//
//  DisplaceableImage.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/18/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import Foundation
import ImageViewer

/// This class will bridge the incompatibility between the new `UIImageView` api 
/// and `ImageViewer`'s `DisplaceableView` protocol
class DisplaceableImage: DisplaceableView {
  
  var imageView: UIImageView
  var image: UIImage? {
    return imageView.image
  }
  var bounds: CGRect {
    return imageView.bounds
  }
  var center: CGPoint {
    return imageView.center
  }
  var boundsCenter: CGPoint {
    return imageView.boundsCenter
  }
  var contentMode: UIViewContentMode {
    return imageView.contentMode
  }
  var hidden: Bool {
    get { return imageView.isHidden }
    set (value) { imageView.isHidden = value }
  }
  
  init(_ imageView: UIImageView) {
    self.imageView = imageView
  }
  
  func convertPoint(_ point: CGPoint, toView view: UIView?) -> CGPoint {
    let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
    return imageView.convert(rect, to: view).origin
  }
  
}
