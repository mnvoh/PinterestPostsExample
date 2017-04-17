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
  @IBOutlet weak var netActivityIndicator: UIActivityIndicatorView!
  
  
  // MARK: Properties
  
  let cellSpacing: CGFloat = 12
  var refreshControll: UIRefreshControl!
  var pins = [Pin]()
  var lastLoadTime: TimeInterval = 0
  var isLoading: Bool = false {
    didSet {
      if isLoading {
        netActivityIndicator.startAnimating()
      } else {
        netActivityIndicator.stopAnimating()
      }
    }
  }
  
  struct Storyboard {
    static let pinsCollectionViewCellId = "pincell"
  }
  
  // MARK: Overrides

  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    setupCollectionView()
    
    loadData()
    
  }
  
  // MARK: Private Functions
  
  private func setupCollectionView() {
    
    if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
      layout.delegate = self
    }
    let layout = collectionView.collectionViewLayout as! PinterestLayout
    let padding = layout.cellPadding
    collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    collectionView.alwaysBounceVertical = true
    
    refreshControll = UIRefreshControl()
    refreshControll.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    
    collectionView.addSubview(refreshControll)
    
  }
  
  @objc private func reloadData() {
    
    loadData(forceReload: true)
    
  }
  
  fileprivate func loadData(forceReload: Bool = false) {
    
    if isLoading {
      return
    }
    
    var offset = pins.count
    if forceReload {
      offset = 0
    }
    
    isLoading = true
    
    ApiClient.getPins(offset: offset) { (pins, error) in
      
      self.refreshControll.endRefreshing()
      self.isLoading = false
      
      guard let pins = pins else {
        print("\(error ?? "An unknown error has occured")")
        return
      }
      
      if forceReload {
        self.pins.removeAll()
      }
      
      self.pins.append(contentsOf: pins)
      
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


// MARK: UIScrollView Delegate
extension HomeViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
    
    if (bottomEdge >= scrollView.contentSize.height)
    {
      loadData()
    }
    
  }
  
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
