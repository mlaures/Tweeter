//
//  TweetCell.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import AlamofireImage

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNamelabel: UILabel!
    @IBOutlet weak var tweetTimeStamp: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var replyButton: UIImageView!
    @IBOutlet weak var retweetButton: UIImageView!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIImageView!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    
    var tweet: Tweet! {
        didSet {
            // main body of the tweet
            tweetTextLabel.text = tweet.text
            userNameLabel.text = tweet.user.name
            tweetTimeStamp.text = tweet.createdAtString
            if let screenName = tweet.user.screenName {
                userScreenNamelabel.text = "@ \(screenName)"
            }
            if let url = tweet.user.profileImageURL {
                userProfileImage.af_setImage(withURL: url)
            }
            
            // extras for the tweet
            retweetCountLabel.text = String(describing: tweet.retweetCount)
            favoriteCountLabel.text = String(describing: tweet.favoriteCount!)
            
            if tweet.retweeted {
                retweetButton.image = #imageLiteral(resourceName: "retweet-icon-green")
            }
            if tweet.favorited! {
                favoriteButton.image = #imageLiteral(resourceName: "favor-icon-red")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
