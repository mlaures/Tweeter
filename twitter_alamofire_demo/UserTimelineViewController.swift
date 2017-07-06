//
//  UserTimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Mei-Ling Laures on 7/6/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit

class UserTimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate {
    
    var tweets: [Tweet] = []
    var user: User?
    
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh control initialization for the table view
        
        // have the view controller deal with the table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // automatic cell resizing
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // change separator style
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // makes a table header
        tableView.tableHeaderView = tableHeaderView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // need to check which user data is going to be fetched
        if let user = user {
            // do network call with the passed in user
        } else {
            // do network call with the current user
        }
        
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
    
    func didAddPost(post: Tweet) {
        <#code#>
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
