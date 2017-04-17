//
//  Pin.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/17/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import Foundation
import UIKit

struct Pin {
  
  let id: String
  let createdAt: String
  let size: CGSize
  let color: UIColor
  let likes: Int
  let fullUrl: URL?
  let thumbUrl: URL?
  let user: User?
  let categories: [Category]
  
}
