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
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    
    var cellTweet: Tweet! {
        didSet {
            // main body of the tweet
            tweetTextLabel.text = cellTweet.text
            userNameLabel.text = cellTweet.user.name
            tweetTimeStamp.text = cellTweet.createdAtString
            if let screenName = cellTweet.user.screenName {
                userScreenNamelabel.text = "@ \(screenName)"
            }
            if let url = cellTweet.user.profileImageURL {
                userProfileImage.af_setImage(withURL: url)
            }
            
            // extras for the tweet
            retweetCountLabel.text = String(describing: cellTweet.retweetCount)
            favoriteCountLabel.text = String(describing: cellTweet.favoriteCount!)
            
            if cellTweet.retweeted {
                retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
            } else {
                retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)

            }
            if cellTweet.favorited! {
                favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
            } else {
                favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)

            }
        }
    }
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if cellTweet.favorited! {
            APIManager.shared.unfavoriteTweet(with: cellTweet, completion: { (tweet, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let tweet = tweet {
                        // set the returned data as the new data for the cell
                        self.cellTweet = tweet
                        
                        // change what the user sees to reflect the action
                        self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
                        self.favoriteCountLabel.text = String(describing: tweet.favoriteCount!)
                    }
                }
            })
        } else if !cellTweet.favorited! {
            APIManager.shared.favoriteTweet(with: cellTweet, completion: { (tweet, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let tweet = tweet {
                        // set the returned data as new data for the cell
                        self.cellTweet = tweet
                        
                        // change what the user sees to reflect the action
                        self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
                        self.favoriteCountLabel.text = String(describing: tweet.favoriteCount!)
                    
                    }
                }
            }) 
            
        } else {
            assert(false, "the tweet favorite bool failed")
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
