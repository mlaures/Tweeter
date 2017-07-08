//
//  TweetCell.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import AlamofireImage
import DateToolsSwift
import TTTAttributedLabel

class TweetCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var tweetTextLabel: TTTAttributedLabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNamelabel: UILabel!
    @IBOutlet weak var tweetTimeStamp: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var tweetTimeAgo: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweeterLabel: UILabel!
    
    
    var cellTweet: Tweet! {
        didSet {
            // pass in the original tweet (whether or not it is a retweeted one) and include the reposter
            if let original = cellTweet.originalTweet {
                refreshData(tweet: original, reposter: cellTweet.user.name)
            } else {
                refreshData(tweet: cellTweet, reposter: nil)
            }
        }
    }
    
    func refreshData(tweet: Tweet, reposter: String?) {
        
        // text is interactable, and can check types eg link
        tweetTextLabel.delegate = self
        tweetTextLabel.isUserInteractionEnabled = true
        tweetTextLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        
        // this is the text to evaluate for links
        tweetTextLabel.text = tweet.text

        
        // tweet details
        userNameLabel.text = tweet.user.name
        tweetTimeStamp.text = tweet.createdAtString
        if let screenName = tweet.user.screenName {
            userScreenNamelabel.text = "@\(screenName)"
        }
        if let url = tweet.user.profileImageURL {
            userProfileImage.af_setImage(withURL: url)
            // set image to be circular
            userProfileImage.layer.cornerRadius = userProfileImage.frame.height/2
            userProfileImage.clipsToBounds = true

        }
        
        // another time stamp
        tweetTimeAgo.text = tweet.createdDate.shortTimeAgoSinceNow
        
        // let the user know about a possible reposter
        if let repost = reposter {
            retweeterLabel.isHidden = false
            retweeterLabel.text = "\(repost) retweeted this"
        } else {
            retweeterLabel.isHidden = true
        }
        
        // stats for the tweet
        retweetCountLabel.text = String(describing: tweet.retweetCount)
        favoriteCountLabel.text = String(describing: tweet.favoriteCount!)
        
        if tweet.retweeted {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
        } else {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
            
        }
        if tweet.favorited! {
            favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
            
        }
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if cellTweet.favorited! {
            // change what the user sees to reflect the action of unfavoriting
            self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
            self.favoriteCountLabel.text = String(describing: cellTweet.favoriteCount! - 1)
            
            // make the network call
            APIManager.shared.unfavoriteTweet(with: cellTweet, completion: { (tweet, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let tweet = tweet {
                        // set the returned data as the new data for the cell (automatically refreshes cell)
                        self.cellTweet = tweet
                        
                    }
                }
            })
        } else if !cellTweet.favorited! {
            // change what the user sees to reflect the action of favoriting
            self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
            self.favoriteCountLabel.text = String(describing: cellTweet.favoriteCount! + 1)
            
            // make the network call
            APIManager.shared.favoriteTweet(with: cellTweet, completion: { (tweet, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let tweet = tweet {
                        // set the returned data as new data for the cell (automatically refreshes cell)
                        self.cellTweet = tweet
                    }
                }
            })
            
        } else {
            assert(false, "the tweet favorite bool failed")
        }
    }
    
    @IBAction func toggleRetweet(_ sender: Any) {
        if cellTweet.retweeted {
            // change what the user sees to reflect the action of un-retweeting
            self.retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
            self.retweetCountLabel.text = String(describing: cellTweet.retweetCount - 1)

            // make the network call
            APIManager.shared.unretweet(with: cellTweet, completion: { (tweet, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("retweet deleted")
                }
            })
            
        } else if !cellTweet.retweeted {
            // change what the user sees to reflect the action of retweeting
            self.retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
            self.retweetCountLabel.text = String(describing: cellTweet.retweetCount + 1)
            
            // make the network call
            APIManager.shared.retweet(with: cellTweet, completion: { (tweet, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let tweet = tweet {
                        // set the returned data as the new data for the cell (automatically refreshes data)
                        self.cellTweet = tweet
                        
                    }
                }
            })
        } else {
            assert(false, "the retweet bool failed")
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
