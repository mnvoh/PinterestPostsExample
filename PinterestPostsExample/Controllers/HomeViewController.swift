//
//  HomeViewController.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/17/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import UIKit
import CachedRequester
import ImageViewer

class HomeViewController: UIViewController {
  
  // MARK: IBOutlets

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var netActivityIndicator: UIActivityIndicatorView!
  
  
  // MARK: Properties
  
  var refreshControll: PullToRefreshControl!
  var pins = [Pin]()
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
    
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    collectionView.alwaysBounceVertical = true
    
    refreshControll = PullToRefreshControl(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 200))
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
      
      // the following code block is just to show off the refresh control
      DispatchQueue.global(qos: .userInitiated).async {
        sleep(2)
        
        DispatchQueue.main.async {
          self.refreshControll.endRefreshing()
        }
      }
      
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
  
  
  
  fileprivate func imageViewerConfig() -> GalleryConfiguration {
    
    return [
      
      GalleryConfigurationItem.closeButtonMode(.builtIn),
      GalleryConfigurationItem.thumbnailsButtonMode(.none),
      
      GalleryConfigurationItem.pagingMode(.standard),
      GalleryConfigurationItem.presentationStyle(.displacement),
      GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
      
      GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
      GalleryConfigurationItem.overlayColorOpacity(1),
      GalleryConfigurationItem.overlayBlurOpacity(1),
      GalleryConfigurationItem.overlayBlurStyle(UIBlurEffectStyle.light),
      
      GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
      
      GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
      
      GalleryConfigurationItem.blurPresentDuration(0.25),
      GalleryConfigurationItem.blurPresentDelay(0),
      GalleryConfigurationItem.colorPresentDuration(0.25),
      GalleryConfigurationItem.colorPresentDelay(0),
      
      GalleryConfigurationItem.blurDismissDuration(0.1),
      GalleryConfigurationItem.blurDismissDelay(0.4),
      GalleryConfigurationItem.colorDismissDuration(0),
      GalleryConfigurationItem.colorDismissDelay(0),
      
      GalleryConfigurationItem.itemFadeDuration(0.3),
      GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
      GalleryConfigurationItem.rotationDuration(0.15),
      
      GalleryConfigurationItem.displacementDuration(0.55),
      GalleryConfigurationItem.reverseDisplacementDuration(0.55),
      GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.25)),
      GalleryConfigurationItem.displacementTimingCurve(.easeInOut),
      
      GalleryConfigurationItem.statusBarHidden(true),
      GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
      GalleryConfigurationItem.displacementInsetMargin(50)
    ]
    
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
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let gallery = GalleryViewController(
      startIndex: indexPath.item,
      itemsDatasource: self,
      displacedViewsDatasource: self,
      configuration: imageViewerConfig()
    )
    presentImageGallery(gallery)
  }
  
}


// MARK: UIScrollView Delegate
extension HomeViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    refreshControll.scrollViewDidScroll(scrollView)
    
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


// MARK: GalleryItemsDatasource

extension HomeViewController: GalleryItemsDatasource {
  
  func itemCount() -> Int {
    return pins.count
  }
  
  func provideGalleryItem(_ index: Int) -> GalleryItem {
    guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PinCollectionViewCell else {
      return GalleryItem.image { $0(#imageLiteral(resourceName: "placeholder")) }
    }
    let item = GalleryItem.image { $0(cell.pinView.pinImage.image) }
    return item
  }
  
}


// MARK: GalleryDisplacedViewsDatasource

extension HomeViewController: GalleryDisplacedViewsDatasource {
  
  func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
    guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PinCollectionViewCell else {
      return nil
    }
    return DisplaceableImage(cell.pinView.pinImage)
  }
  
}
