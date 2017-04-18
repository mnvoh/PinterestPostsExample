//
//  PullToRefreshControl.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/18/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import UIKit

/// A custom pull-to-refresh control
class PullToRefreshControl: UIRefreshControl {

  /// The initial offset of the scroll view is not zero, so we use this to zero it out
  var initialScrollViewOffset = CGPoint(x: 0, y: -64)
  
  /// The background color of the refresh control when it's not refreshing
  var inactiveColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
  
  // the backgroud color of the refresh control when it's refreshing
  var activeColor: UIColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
  
  // whether animation should be in progress or not
  var isAnimating = false
  
  // How much the angry emoji should bounce up and down
  let angryEmojiBounceValue: CGFloat = 25
  
  // the initial distance from the bottom of the emoji to the bottom of the container view
  let angryEmojiBottom: CGFloat = 5
  
  // A wrapper view around our subviews
  private var containerView: UIView!
  
  // the emoji label
  private var emojiLabel: UILabel!
  
  override init() {
    
    super.init()
    setup()
    
  }
  
  override init(frame: CGRect) {
    
    super.init(frame: frame)
    setup()
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
    setup()
    
  }
  
  /// Do the required initial configurations here
  func setup() {
    
    frame.origin = CGPoint(x: -6, y: -6)
    tintColor = .clear
    
    containerView = UIView(frame: bounds)
    containerView.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    containerView.clipsToBounds = true
    addSubview(containerView)
    
    emojiLabel = UILabel()
    emojiLabel.text = "😊"
    emojiLabel.font = emojiLabel.font.withSize(28)
    emojiLabel.textAlignment = .center
    
    containerView.addSubview(emojiLabel)
    
  }
  
  
  /// This function should be called from the super view of this class
  /// whenever the scrollview of the containing table view/collection view
  /// is scrolled
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    // zero out the offset
    let yOffset = abs(scrollView.contentOffset.y - initialScrollViewOffset.y)
    
    // set the height of the container view to the available space
    containerView.frame.size.height = yOffset
    
    // set the position of the emoji label to the bottom of the container view
    emojiLabel.frame = CGRect(
      x: containerView.frame.width / 2 - emojiLabel.frame.width / 2,
      y: calculateBottomPosition(angryEmojiBottom),
      width: containerView.frame.width,
      height: 28
    )
    
    // change the emoji based on how much the control has been pulled
    if yOffset < 48 {
      emojiLabel.text = "😊"
    }
    else if yOffset < 88 {
      emojiLabel.text = "😣"
    }
    else {
      emojiLabel.text = "😖"
    }
    
    // act according to whether the control is refreshing or not
    if isRefreshing {
      containerView.backgroundColor = activeColor
      emojiLabel.text = "😡"
      isAnimating = true
      animate()
    }
    else {
      containerView.backgroundColor = inactiveColor
      isAnimating = false
    }
    
  }
  
  
  /// Animates the emoji label to bounce up and down
  func animate() {
    
    let duration = 0.075
    
    UIView.animate(withDuration: duration, delay: 0, animations: {
      self.emojiLabel.frame.origin.y = self.calculateBottomPosition(self.angryEmojiBounceValue)
    }) { (finished) in
      if finished {
        UIView.animate(withDuration: duration, delay: 0, animations: {
          self.emojiLabel.frame.origin.y = self.calculateBottomPosition(self.angryEmojiBottom)
        }) { (finished) in
          if finished && self.isAnimating {
            self.animate()
          }
        }
      }
    }
    
  }
  
  /// Calculates the bottom position of the emoji label using only a single value
  func calculateBottomPosition(_ bottom: CGFloat) -> CGFloat {
    
    return containerView.frame.height - emojiLabel.frame.height - bottom
    
  }

}
