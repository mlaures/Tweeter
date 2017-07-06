//
//  ComposeViewController.swift
//  twitter_alamofire_demo
//
//  Created by Mei-Ling Laures on 7/6/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import AlamofireImage

protocol ComposeViewControllerDelegate: class {
    func didAddPost(post: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var tweetText: UITextView!
    
    // make the view controller where it is coming from as the delegate
    weak var delegate: ComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // display the current user's name, profile image, and screen name
        let user = User.current
        userImage.af_setImage(withURL: user!.profileImageURL!)
        userName.text = user!.name
        userScreenName.text = user!.screenName
        
        // make self the text view delegate
        tweetText.delegate = self
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
        print("making call")
        APIManager.shared.compose(with: tweetText.text) { (tweet, error) in
            if let error = error {
                // there has been an error, must show this
                print(error.localizedDescription)
            } else {
                if let tweet = tweet {
                    // pass this tweet into the feed so that is shows up immediately
                    self.delegate?.didAddPost(post: tweet)
                    print(tweet)
                    print("tweet properly posted")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if tweetText.text == "Compose your gem here..." {
            tweetText.text = ""
        }
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
