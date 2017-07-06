//
//  APIManager.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 4/4/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift
import OAuthSwiftAlamofire
import KeychainAccess

class APIManager: SessionManager {
    
    static let consumerKey = "awmLFtBeVXNwx6MK5VuHO3Y3b"
    static let consumerSecret = "0p8AJMPg11Y9k9oS1hCg3sARChPGhn1843fs8kJ5vv8VAHKxZK"
    
    static let requestTokenURL = "https://api.twitter.com/oauth/request_token"
    static let authorizeURL = "https://api.twitter.com/oauth/authorize"
    static let accessTokenURL = "https://api.twitter.com/oauth/access_token"
    
    static let callbackURLString = "alamoTwitter://"
    
    // MARK: Twitter API methods
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        
        // Add callback url to open app when returning from Twitter login on web
        let callbackURL = URL(string: APIManager.callbackURLString)!
        oauthManager.authorize(withCallbackURL: callbackURL, success: { (credential, _response, parameters) in
            
            // Save Oauth tokens
            self.save(credential: credential)
            
            self.getCurrentAccount(completion: { (user, error) in
                if let error = error {
                    failure(error)
                } else if let user = user {
                    print("Welcome \(user.name!)")
                    
                    // set the current user that persists across app accesses
                    User.current = user
                    
                    success()
                }
            })
        }) { (error) in
            failure(error)
        }
    }
    
    func logout() {
        clearCredentials()
        
        // set the current user to nil so that the app no longer logs in as the user
        User.current = nil

        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }
    
    func getCurrentAccount(completion: @escaping (User?, Error?) -> ()) {
        request(URL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!)
            .validate()
            .responseJSON { response in
                
                // Check for errors
                guard response.result.isSuccess else {
                    completion(nil, response.result.error)
                    return
                }
                
                guard let userDictionary = response.result.value as? [String: Any] else {
                    completion(nil, JSONError.parsing("Unable to create user dictionary"))
                    return
                }
                completion(User(dictionary: userDictionary), nil)
        }
    }
        
    func getHomeTimeLine(completion: @escaping ([Tweet]?, Error?) -> ()) {

        // This uses tweets from disk to avoid hitting rate limit. Comment out if you want fresh
        // tweets,
        if let data = UserDefaults.standard.object(forKey: "hometimeline_tweets") as? Data {
            let tweetDictionaries = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[String: Any]]
            let tweets = tweetDictionaries.flatMap({ (dictionary) -> Tweet in
                Tweet(dictionary: dictionary)
            })
            
            completion(tweets, nil)
            return
        }
        
        
        request(URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!, method: .get)
            .validate()
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    completion(nil, response.result.error)
                    return
                }
                guard let tweetDictionaries = response.result.value as? [[String: Any]] else {
                    print("Failed to parse tweets")
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to parse tweets"])
                    completion(nil, error)
                    return
                }
                
                let data = NSKeyedArchiver.archivedData(withRootObject: tweetDictionaries)
                UserDefaults.standard.set(data, forKey: "hometimeline_tweets")
                UserDefaults.standard.synchronize()
                
                let tweets = tweetDictionaries.flatMap({ (dictionary) -> Tweet in
                    Tweet(dictionary: dictionary)
                })
                completion(tweets, nil)
        }
    }
    
    func favoriteTweet (with tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        // set up url and parameters for network call
        let urlString = "https://api.twitter.com/1.1/favorites/create.json"
        let parameters: Parameters = ["id":tweet.id]

        // make the post network request
        request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.queryString, headers: nil)
            .validate()
            .responseJSON { (response) in
                if response.result.isSuccess, let tweetDictionary = response.result.value as? [String:Any] {
                    // the network request was a success so pass in the returned tweet (original)
                    let tweet = Tweet(dictionary: tweetDictionary)
                    completion(tweet, nil)
                    
                } else {
                    // network request failed so pass in the error
                    print(response.description)
                    completion(nil, response.result.error)
                }
        }
        
    }
    
    func unfavoriteTweet (with tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        // set up url and parameters for network call
        let urlString = "https://api.twitter.com/1.1/favorites/destroy.json"
        let parameters: Parameters = ["id":tweet.id]

        // make the post network request
        request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.queryString, headers: nil)
            .validate()
            .responseJSON { (response) in
                if response.result.isSuccess, let tweetDictionary = response.result.value as? [String:Any] {
                    // the network request was a success so pass in the returned tweet (original)
                    let tweet = Tweet(dictionary: tweetDictionary)
                    completion(tweet, nil)
                } else {
                    // network request failed so pass in the errror
                    print(response.description)
                    completion(nil, response.result.error)
                }
        }
    }
    
    func retweet (with tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        // set up url and parameters for network call
        let id = tweet.id
        let urlString = "https://api.twitter.com/1.1/statuses/retweet/\(id).json"
        
        // make the network request
        request(urlString, method: .post, parameters: nil, encoding: URLEncoding.queryString, headers: nil)
            .validate()
            .responseJSON { (response) in
                if response.result.isSuccess, let tweetDictionary = response.result.value as? [String:Any] {
                    // the network request was a success so pass in the returned tweet (original)
                    let tweet = Tweet(dictionary: tweetDictionary)
                    completion(tweet, nil)
                } else {
                    // network request failed so pass in the error
                    print(response.description)
                    completion(nil, response.result.error)
                }
        }
    }
    
    func unretweet (with tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        var originalID: Int64? // paramater for the original tweet id
        var id: Int64? // parameter for the user retweet id
        
        // get the original tweet
        if let originalTweet = tweet.originalTweet {
            originalID = originalTweet.id
        } else {
            originalID = tweet.id
        }
        
        // get the tweet that needs to be destroyed (one's own tweet) with network request
        let urlString = "https://api.twitter.com/1.1/statuses/show.json"
        if let originalID = originalID {
            print("original ID: \(originalID)")
            let parameters: Parameters = [
                "id" : originalID,
                "include_my_retweet" : 1
            ]
            
            // network request for the original tweet with the user retweet id
            request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: nil)
                .validate()
                .responseJSON { (response: DataResponse<Any>) in
                    print(response.result.isSuccess)
                    if response.result.isSuccess, let tweetDictionary = response.result.value as? [String:Any] {
                        let idDictionary = tweetDictionary["current_user_retweet"] as! [String:Any]
                        id = idDictionary["id"] as! Int64
                        
                        // destroy the retweet through its id
                        let urlDestroy = "https://api.twitter.com/1.1/statuses/unretweet/\(id!).json"
                        self.request(urlDestroy, method: .post, parameters: nil, encoding: URLEncoding.queryString, headers: nil)
                            .validate()
                            .responseJSON { (response) in
                                if response.result.isSuccess{
                                    // TODO: redisplay the original tweet
                                    completion(nil, nil)
                                } else {
                                    // network request failed so pass in the error
                                    print(response.description)
                                    completion(nil, response.result.error)
                                }
                        }
                    } else {
                        print(response.description)
                        print(response.result.error!.localizedDescription)
                        completion(nil, response.result.error)
                    }
            }
        } else {
            print ("there is no original tweet")
        }
        
        
        
        
        
        

    }
    
    func compose (with message: String, completion: @escaping (Tweet?, Error?)->()) {
        // make the status that will be posted to the network
        let urlString = "https://api.twitter.com/1.1/statuses/update.json"
        let parameters = ["status" : message]
        request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.queryString)
            .validate()
            .responseJSON { (response) in
                if response.result.isSuccess, let tweetDictionary = response.result.value as? [String:Any] {
                    let tweet = Tweet(dictionary: tweetDictionary)
                    completion(tweet, nil)
                } else {
                    print(response.description)
                    completion(nil, response.result.error)
                }
        }
    }

    // MARK: TODO: Get User Timeline
    
    
    //--------------------------------------------------------------------------------//
    
    
    //MARK: OAuth
    static var shared: APIManager = APIManager()
    
    var oauthManager: OAuth1Swift!
    
    // Private init for singleton only
    private init() {
        super.init()
        
        // Create an instance of OAuth1Swift with credentials and oauth endpoints
        oauthManager = OAuth1Swift(
            consumerKey: APIManager.consumerKey,
            consumerSecret: APIManager.consumerSecret,
            requestTokenUrl: APIManager.requestTokenURL,
            authorizeUrl: APIManager.authorizeURL,
            accessTokenUrl: APIManager.accessTokenURL
        )
        
        // Retrieve access token from keychain if it exists
        if let credential = retrieveCredentials() {
            oauthManager.client.credential.oauthToken = credential.oauthToken
            oauthManager.client.credential.oauthTokenSecret = credential.oauthTokenSecret
        }
        
        // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
        adapter = oauthManager.requestAdapter
    }
    
    // MARK: Handle url
    // OAuth Step 3
    // Finish oauth process by fetching access token
    func handle(url: URL) {
        OAuth1Swift.handle(url: url)
    }
    
    // MARK: Save Tokens in Keychain
    private func save(credential: OAuthSwiftCredential) {
        
        // Store access token in keychain
        let keychain = Keychain()
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)
        keychain[data: "twitter_credentials"] = data
    }
    
    // MARK: Retrieve Credentials
    private func retrieveCredentials() -> OAuthSwiftCredential? {
        let keychain = Keychain()
        
        if let data = keychain[data: "twitter_credentials"] {
            let credential = NSKeyedUnarchiver.unarchiveObject(with: data) as! OAuthSwiftCredential
            return credential
        } else {
            return nil
        }
    }
    
    // MARK: Clear tokens in Keychain
    private func clearCredentials() {
        // Store access token in keychain
        let keychain = Keychain()
        do {
            try keychain.remove("twitter_credentials")
        } catch let error {
            print("error: \(error)")
        }
    }
}

enum JSONError: Error {
    case parsing(String)
}
