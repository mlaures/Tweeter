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
    
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
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
