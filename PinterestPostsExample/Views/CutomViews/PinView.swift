//
//  PinView.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/17/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import UIKit
import CachedRequester

class PinView: UIView {

  // MARK: Properties
  var pinImage: UIImageView!
  var progressBar: UIProgressView!
  var cancelButton: UIButton!
  var reloadButton: UIButton!
  
  var downloadTask: RequestHandle?
  
  private let roundButtonsSize: CGFloat = 48
  
  var pin: Pin? {
    didSet {
      updateView()
    }
  }
  
  // MARK: Initialization
  override init(frame: CGRect) {
    
    super.init(frame: frame)
    setup()
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
    setup()
    
  }
  
  // MARK: Public Functions
  
  
  // MARK: Private Functions
  
  /// Setup up the views in this view
  private func setup() {
    
    // setup self
    layer.cornerRadius = 6
    clipsToBounds = true
    
    // initialize the sub views
    pinImage = UIImageView()
    pinImage.backgroundColor = #colorLiteral(red: 0.8430629969, green: 0.8431848884, blue: 0.8430363536, alpha: 1)
    pinImage.image = #imageLiteral(resourceName: "placeholder")
    pinImage.contentMode = .center
    pinImage.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(pinImage)
    
    progressBar = UIProgressView()
    progressBar.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(progressBar)
    
    cancelButton = UIButton(type: .custom)
    cancelButton.setTitle(nil, for: .normal)
    cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
    cancelButton.layer.cornerRadius = roundButtonsSize / 2
    cancelButton.clipsToBounds = true
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.addTarget(self, action: #selector(cancelDownload(_:)), for: .touchUpInside)
    cancelButton.isHidden = true
    
    addSubview(cancelButton)
    
    reloadButton = UIButton(type: .custom)
    reloadButton.setTitle(nil, for: .normal)
    reloadButton.setImage(#imageLiteral(resourceName: "reload"), for: .normal)
    reloadButton.layer.cornerRadius = roundButtonsSize / 2
    reloadButton.clipsToBounds = true
    reloadButton.translatesAutoresizingMaskIntoConstraints = false
    reloadButton.addTarget(self, action: #selector(restartDownload(_:)), for: .touchUpInside)
    reloadButton.isHidden = true
    
    addSubview(reloadButton)
    
    // add the layout constraints
    let piTopC = NSLayoutConstraint(item: pinImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
    let piRightC = NSLayoutConstraint(item: pinImage, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
    let piBottomC = NSLayoutConstraint(item: pinImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
    let piLeftC = NSLayoutConstraint(item: pinImage, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.01, constant: 0)
    //
    let pbRightC = NSLayoutConstraint(item: progressBar, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
    let pbTopC = NSLayoutConstraint(item: progressBar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
    let pbLeftC = NSLayoutConstraint(item: progressBar, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
    //
    let cbWidthC = NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: roundButtonsSize)
    let cbHeightC = NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: roundButtonsSize)
    let cbHorizontalC = NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
    let cbVerticalC = NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
    //
    let rbWidthC = NSLayoutConstraint(item: reloadButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: roundButtonsSize)
    let rbHeightC = NSLayoutConstraint(item: reloadButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: roundButtonsSize)
    let rbHorizontalC = NSLayoutConstraint(item: reloadButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
    let rbVerticalC = NSLayoutConstraint(item: reloadButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
    //
    NSLayoutConstraint.activate([
      piTopC, piRightC, piBottomC, piLeftC,
      pbRightC, pbTopC, pbLeftC,
      cbWidthC, cbHeightC, cbHorizontalC, cbVerticalC,
      rbWidthC, rbHeightC, rbHorizontalC, rbVerticalC
    ])
    
  }
  
  /// After `pin` has been set updates the view with the new data
  private func updateView() {
    
    guard let pin = pin, let thumbUrl = pin.thumbUrl else {
      // either pin has not been set, or its thumbnail URL is nil
      return
    }
    
    cancelButton.isHidden = false
    progressBar.isHidden = false
    progressBar.progress = 0
    reloadButton.isHidden = true
    
    // TODO: Remove this, and use thumbUrl
    let testUrl = URL(string: "https://static.pexels.com/photos/2079/nature-forest-waterfall-jungle.jpg")!
    
    downloadTask = Requester.sharedInstance.newTask(
      url: testUrl,
      completionHandler: { (data, error) in
        guard error == nil, let data = data else { return }
        if let image = UIImage(data: data) {
          self.pinImage.image = image
          self.pinImage.contentMode = .scaleAspectFit
          self.cancelButton.isHidden = true
          self.progressBar.isHidden = true
          self.reloadButton.isHidden = true
          self.downloadTask = nil
        }
      },
      progressHandler: { (progress) in
        self.progressBar.progress = Float(progress)
      }
    )
    
  }
  
  /// Cancels the download task, if it's in progress
  @objc private func cancelDownload(_ sender: UIButton) {
    
    if let task = downloadTask {
      task.cancel()
      progressBar.isHidden = true
      cancelButton.isHidden = true
      reloadButton.isHidden = false
    }
    
  }
  
  /// Restarts the download task if it has been canceled
  @objc private func restartDownload(_ sender: UIButton) {
    
    updateView()
    
  }

}
