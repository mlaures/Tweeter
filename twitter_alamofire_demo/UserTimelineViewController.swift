//
//  UserTimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Mei-Ling Laures on 7/6/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import AlamofireImage

class UserTimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate {
    
    var tweets: [Tweet] = []
    var user: User?
    
    var refreshControl: UIRefreshControl!
    var navController: UINavigationController!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var profileBackground: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileScreenName: UILabel!
    @IBOutlet weak var profileBio: UILabel!
    @IBOutlet weak var profileTweets: UILabel!
    @IBOutlet weak var profileFollowing: UILabel!
    @IBOutlet weak var profileFollowers: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh control initialization for the table view
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(UserTimelineViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // have the view controller deal with the table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // automatic cell resizing
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // change separator style
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // set the navigation controller
        navController = self.navigationController
        
    }
    
    func didPullToRefresh(_: UIRefreshControl) {
        if let user = user {
            // do network call with the passed in user
            APIManager.shared.getUserTimeline(with: user, completion: { (tweets, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    // make the list of tweets and reload the table data
                    self.tweets = tweets!
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        } else {
            // do network call with the current user
            APIManager.shared.getUserTimeline(with: User.current!, completion: { (tweets, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    // make the list of tweets and reload the table data
                    self.tweets = tweets!
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        // resize the header view
        tableHeaderView.setNeedsLayout()
        tableHeaderView.layoutIfNeeded()
        
        // set sizes for the frame explicitly
        let height = tableHeaderView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = tableHeaderView.frame
        frame.size.height  = height
        tableHeaderView.frame = frame
        
        // as the view is now the correct size, set it as the table header
        tableView.tableHeaderView = tableHeaderView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // need to check which user data is going to be fetched
        if let user = user {
            // do network call with the passed in user
            APIManager.shared.getUserTimeline(with: user, completion: { (tweets, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    // make the list of tweets and reload the table data
                    self.tweets = tweets!
                    self.tableView.reloadData()
                }
            })
            // set the table header for the correct user
            setHeader(user: user)
        } else {
            // do network call with the current user
            APIManager.shared.getUserTimeline(with: User.current!, completion: { (tweets, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    // make the list of tweets and reload the table data
                    self.tweets = tweets!
                    self.tableView.reloadData()
                }
            })
            // set the table header for the correct user
            setHeader(user: User.current!)
        }
        
    }
    
    func setHeader (user: User) {
        // set the table header with all the user info
        profileImage.af_setImage(withURL: user.profileImageURL!)
        if let url = user.backgroundImageURL {
            profileBackground.af_setImage(withURL: url)

        }
        profileBio.text = user.bio
        profileName.text = user.name
        profileScreenName.text = "@\(user.screenName)"
        profileTweets.text = "\(user.tweetCount) Tweets"
        profileFollowers.text = "\(user.followerCount) Followers"
        profileFollowing.text = "\(user.followingCount) Following"
        
        // set profile image top be circular
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        
        cell.cellTweet = tweets[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didAddPost(post: Tweet) {
        // this is a placeholder
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
