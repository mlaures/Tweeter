//
//  Tweet.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation

class Tweet {
    
    // MARK: Properties
    var id: Int64 // For favoriting, retweeting & replying
    var text: String // Text content of tweet
    var favoriteCount: Int? // Update favorite count label
    var favorited: Bool? // Configure favorite button
    var retweetCount: Int // Update favorite count label
    var retweeted: Bool // Configure retweet button
    var user: User // Contains name, screenname, etc. of tweet author
    var createdAtString: String // Display date
    var createdDate: Date
    var originalTweet: Tweet?
    
    // MARK: - Create initializer with dictionary
    init(dictionary: [String: Any]) {
        id = dictionary["id"] as! Int64
        text = dictionary["text"] as! String
        favoriteCount = (dictionary["favorite_count"] as! Int)
        favorited = (dictionary["favorited"] as! Bool)
        retweetCount = dictionary["retweet_count"] as! Int
        retweeted = dictionary["retweeted"] as! Bool
        
        let user = dictionary["user"] as! [String: Any]
        self.user = User(dictionary: user)
        
        let createdAtOriginalString = dictionary["created_at"] as! String
        let formatter = DateFormatter()
        // Configure the input format to parse the date string
        formatter.dateFormat = "E MMM d HH:mm:ss Z y"
        // Convert String to Date
        createdDate = formatter.date(from: createdAtOriginalString)!
        // Configure output format
        formatter.dateFormat = "hh:mm a - d MMM yyyy"
        // Convert Date to String
        createdAtString = formatter.string(from: createdDate)
        
        if let original = dictionary["retweeted_status"] as? [String:Any] {
            let oTweet = Tweet(dictionary: original)
            originalTweet = oTweet
        }
    }
}

