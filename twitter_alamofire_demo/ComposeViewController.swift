//
//  ComposeViewController.swift
//  twitter_alamofire_demo
//
//  Created by Mei-Ling Laures on 7/6/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import AlamofireImage

class ComposeViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // display the current user's name, profile image, and screen name
        let user = User.current
        userImage.af_setImage(withURL: user!.profileImageURL!)
        userName.text = user!.name
        userScreenName.text = user!.screenName
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTweet(_ sender: Any) {
        // Make the call to API
        
        // make sure that the tweet shows up immediately in the feed
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
