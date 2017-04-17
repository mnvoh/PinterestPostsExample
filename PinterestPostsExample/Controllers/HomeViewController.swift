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
  
  @IBOutlet weak var pinView: PinView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ApiClient.getPins(offset: 0) { (pins, error) in
      guard let pins = pins else {
        print(error ?? "Unknown Error")
        return
      }
      
      self.pinView.pin = pins[4]
    }
  }
  
}
