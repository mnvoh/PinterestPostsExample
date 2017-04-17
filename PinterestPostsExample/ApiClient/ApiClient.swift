//
//  ApiClient.swift
//  PinterestPostsExample
//
//  Created by Milad on 4/17/17.
//  Copyright © 2017 Milad Nozary. All rights reserved.
//

import Foundation
import CachedRequester

/// `ApiClient` takes care of network requests by abstracting the required operations.
class ApiClient {
  
  /// Gets a page of the pins/posts and calls `completionHandler` when done with the results.
  ///
  /// - parameter offset:               Skip this number of pins
  /// - parameter count:                fetch this number of pins
  /// - parameter completionhandler     The callback which will be called when the request is done.
  ///                                   It takes two arguments, an array of pins and an error message
  static func getPins(offset: Int, count: Int = 10, _ completionHandler: @escaping ([Pin]?, String?) -> Void) {
    
    guard let url = URL(string: EndPoints.pins) else {
      return
    }
    
    // Since we won't cancel this request, we can dump the task handle
    _ = Requester.sharedInstance.newTask(
      url: url,
      completionHandler: { (data, error) in
        guard let data = data, error == nil else {
          // an error occured while processing the request
          completionHandler(nil, error?.localizedDescription)
          return
        }
        
        do {
          // prase the json string retrieved from the server
          let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [Any]
          
          // since our endpoint doesn't actually take care of offseting and limiting
          // we have to slice the array of the results
          let currentPage = json[offset ..< offset + count]
          
          var pins = [Pin]()
          
          for item in currentPage {
            if let itemDict = item as? [AnyHashable: Any] {
              let pin = self.parsePin(json: itemDict)
              pins.append(pin)
            }
          }
          
          completionHandler(pins, nil)
          
        }
        catch {
          // Error while parsing JSON
          completionHandler(nil, error.localizedDescription)
        }
        
        // We don't need to report or show progress of the request for this one
      }) { (progress) in }
    
  }
  
  /// Parses a dictionary an returns a `Pin` model
  ///
  /// - parameter json:             A dictionary containing the data a pin has
  ///
  /// - returns:                    An instance of the `Pin` model
  static func parsePin(json: [AnyHashable: Any]) -> Pin {
    
    let id = json["id"] as? String ?? ""
    let createdAt = json["created_at"] as? String ?? ""
    let width = json["width"] as? Int ?? 0
    let height = json["height"] as? Int ?? 0
    let color = json["color"] as? String ?? "#ffffff"
    let likes = json["likes"] as? Int ?? 0
    var fullUrlString = ""
    var thumbUrlString = ""
    
    if let urls = json["urls"] as? [AnyHashable: Any] {
      fullUrlString = urls["full"] as? String ?? ""
      thumbUrlString = urls["thumb"] as? String ?? ""
    }
    
    var user: User?
    if let userDict = json["user"] as? [AnyHashable: Any] {
      user = parseUser(json: userDict)
    }
    
    var categories = [Category]()
    if let categoriesArray = json["categories"] as? [Any] {
      categories = praseCategories(json: categoriesArray)
    }
    
    var fullUrl: URL? = nil
    var thumbUrl: URL? = nil
    if let furl = fullUrlString.addingPercentEscapes(using: .utf8) {
      fullUrl = URL(string: furl)
    }
    if let turl = thumbUrlString.addingPercentEscapes(using: .utf8) {
      thumbUrl = URL(string: turl)
    }
    
    return Pin(
      id: id,
      createdAt: createdAt,
      size: CGSize(width: width, height: height),
      color: UIColor(hexString: color),
      likes: likes,
      fullUrl: fullUrl,
      thumbUrl: thumbUrl,
      user: user,
      categories: categories
    )
  }
  
  /// Parses a dictionary an returns a `User` model
  ///
  /// - parameter json:             A dictionary containing the data a user has
  ///
  /// - returns:                    An instance of the `User` model
  static func parseUser(json: [AnyHashable: Any]) -> User {
    
    let id = json["id"] as? String ?? ""
    let username = json["username"] as? String ?? ""
    let name = json["name"] as? String ?? ""
    var profileImageUrl: URL?
    
    if let profileImages = json["profile_images"] as? [AnyHashable: Any] {
      if let profileImage = profileImages["small"] as? String {
        profileImageUrl = URL(string: profileImage)
      }
    }
    
    return User(id: id, username: username, name: name, profileImage: profileImageUrl)
  }
  
  
  /// Parses a dictionary an returns an array of Category models
  ///
  /// - parameter json:             An array containing the categories of a pin
  ///
  /// - returns:                    An array of `Categpry` instances
  static func praseCategories(json: [Any]) -> [Category] {
    
    var categories = [Category]()
    
    for item in json {
      if let itemDict = item as? [AnyHashable: Any] {
        let id = itemDict["id"] as? Int ?? 0
        let title = itemDict["title"] as? String ?? ""
        let photoCount = itemDict["photo_count"] as? Int ?? 0
        var url: URL?
        
        if let urls = itemDict["links"] as? [AnyHashable: Any] {
          let selfUrl = urls["self"] as? String ?? ""
          url = URL(string: selfUrl)
        }
        
        let category = Category(id: id, title: title, photoCount: photoCount, url: url)
        categories.append(category)
      }
    }
    
    return categories
    
  }
  
}
