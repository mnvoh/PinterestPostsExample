//
//  HomeViewController.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/17/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import UIKit
import CachedRequester

class HomeViewController: UIViewController {
  
  // MARK: IBOutlets

  @IBOutlet weak var collectionView: UICollectionView!
  
  
  // MARK: Properties
  
  var pins = [Pin]()
  
  struct Storyboard {
    static let pinsCollectionViewCellId = "pincell"
  }
  
  // MARK: Overrides

  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
      layout.delegate = self
    }
    
    ApiClient.getPins(offset: 0) { (pins, error) in
      
      guard let pins = pins else {
        print(error)
        return
      }
      
      self.pins = pins
      
      self.collectionView.reloadData()
      
    }
    
  }
  
}


// MARK: UICollectionView DataSource

extension HomeViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return pins.count
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.pinsCollectionViewCellId, for: indexPath)
      as? PinCollectionViewCell else {
        return UICollectionViewCell()
    }
    
    cell.pinView.pin = pins[indexPath.item]
    
    return cell
    
  }
  
}


// MARK: UICollectinoView Delegate

extension HomeViewController: UICollectionViewDelegate {
  
  
  
}


// MARK: PinterestLayoutDelegate
extension HomeViewController: PinterestLayoutDelegate {
  
  func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath ,
                      withWidth: CGFloat) -> CGFloat {
    let pin = pins[indexPath.item]
    
    let aspectRatio = pin.size.width / pin.size.height
    
    return withWidth / aspectRatio
  }
  
}
