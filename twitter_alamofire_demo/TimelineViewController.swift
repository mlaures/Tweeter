//
//  TimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate {
    
    var tweets: [Tweet] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize refresh control for the table view (including where to put the indicator)
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TimelineViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // have view controller deal with the data of the table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // automatic cell resizing
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        //gets rid of separator between cells
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // network call to twitter API
        APIManager.shared.getHomeTimeLine { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
            } else if let error = error {
                print("Error getting home timeline: " + error.localizedDescription)
            }
        }
    }
    
    func imageTapped (tapGestureRecognizer: UITapGestureRecognizer) {
        
        // this is to find the row that the image was in to pass in the correct user
        let position = tapGestureRecognizer.view?.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: position!)
        if let indexPath = indexPath {
            // you can have the row now!
            let chosenTweet = tweets[indexPath.row]
            let user = chosenTweet.user
            
            // perform the segue with the user to put straight into the user timeline view
            performSegue(withIdentifier: "userTimelineSegue", sender: user)

        } else {
            print("could not locate the cell/ row")
        }
    }
    
    func didPullToRefresh(_: UIRefreshControl) {
        APIManager.shared.getHomeTimeLine { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else if let error = error {
                print("Error getting home timeline: " + error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
        cell.cellTweet = tweets[indexPath.row]
        
        // recognize an object that the user touches
        let screenNameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TimelineViewController.imageTapped(tapGestureRecognizer:)))
        let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TimelineViewController.imageTapped(tapGestureRecognizer:)))
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TimelineViewController.imageTapped(tapGestureRecognizer:)))
        // apply the gesture recognizer to the elements that need to recognize it
        cell.userNameLabel.isUserInteractionEnabled = true
        cell.userScreenNamelabel.isUserInteractionEnabled = true
        cell.userProfileImage.isUserInteractionEnabled = true
        cell.userProfileImage.addGestureRecognizer(imageGestureRecognizer)
        cell.userNameLabel.addGestureRecognizer(nameGestureRecognizer)
        cell.userScreenNamelabel.addGestureRecognizer(screenNameGestureRecognizer)

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapLogout(_ sender: Any) {
        APIManager.shared.logout()
    }
    
    @IBAction func newPost(_ sender: Any) {
        // make the segue (any information passed into compose view should be put in prepare function)
        print("make a new post")
        performSegue(withIdentifier: "composeSegue", sender: sender)
    }
    

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "composeSegue" {
            let nav = segue.destination as! UINavigationController
            let composeViewController = nav.topViewController as! ComposeViewController
            composeViewController.delegate = self
        }

        if segue.identifier == "userTimelineSegue" {
            let userTimelineViewController = segue.destination as! UserTimelineViewController
            userTimelineViewController.user = sender as! User
        }
     }
    
    func didAddPost(post: Tweet) {
        // add the newest tweet to the top of the list
        var newTweets: [Tweet] = [post]
        newTweets += tweets
        
        // reset the tweets and reload the table
        tweets = newTweets
        tableView.reloadData()
        
    }
    
}
