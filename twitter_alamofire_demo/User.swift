//
//  User.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/17/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    // user properties
    var name: String?
    var screenName: String?
    var profileImageURL: URL?
    var bio: String?
    var id: Int64
    var tweetCount: Int64
    var followingCount: Int64
    var followerCount: Int64
    
    // for persisted user
    var dictionary: [String: Any]?
    
    private static var _current: User?
    
    // computed property to update _current and save to UserDefaults
    static var current: User? {
        
        // use this function if there is already a user saved within UserDefaults (persisted user)
        get {
            if _current == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.data(forKey: "currentUserData") {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String:Any]
                    _current = User(dictionary: dictionary)
                }
            }
            return _current
        }
        
        // use this function if the UserDefaults user data needs to be changed (set or removed)
        set (user) {
            _current = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
        }
    }
    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary

        // initialize other user properties
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        bio = dictionary["description"] as? String
        id = dictionary["id"] as! Int64
        tweetCount = dictionary["statuses_count"] as! Int64
        followingCount = dictionary["friends_count"] as! Int64
        followerCount = dictionary["followers_count"] as! Int64

        
        // for the image
        let profileImage = dictionary["profile_image_url"] as? String
        profileImageURL = URL(string: profileImage!)
    }
    
    
}
