//
//  TweetsViewController.swift
//  TwitterNLPExample
//
//  Created by Doron Katz on 11/29/17.
//  Copyright © 2017 Doron Katz. All rights reserved.
//

import UIKit
import TwitterKit
import SafariServices
import Highlighter

class TweetsViewController:  UITableViewController , TWTRTweetViewDelegate {
    
    // setup a 'container' for Tweets
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let reuseIdentifier: String = "reuseIdentifier"
    
    var isLoadingTweets = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.register(TweetCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Setup table data
        Twitter.sharedInstance().sessionStore.fetchGuestSession { (guestSession, error) in
            if (guestSession != nil) {
                self.loadTweets()
            } else {
                print("Error \(String(describing: error?.localizedDescription))")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make sure the navigation bar is not translucent when scrolling the table view.
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    
    func loadTweets() {
        // Do not trigger another request if one is already in progress.
        if self.isLoadingTweets {
            return
        }
        self.isLoadingTweets = true
        
        // set tweetIds to find
        let tweetIDs = ["936415556197945344", "936248803182514176", "936093689612505088", "935187735844917255", "935094631787843584"];
        
        
        // Find the tweets with the tweetIDs
        let client = TWTRAPIClient()
        
        client.loadTweets(withIDs: tweetIDs) { (twttrs, error) -> Void in
            
            // If there are tweets do something magical
            if ((twttrs) != nil) {
                
                // Loop through tweets and do something
                for i in twttrs! {
                    // Append the Tweet to the Tweets to display in the table view.
                    self.tweets.append(i as TWTRTweet)
                }
            } else {
                print(error as Any)
            }
        }
        
    }
    
    func refreshInvoked() {
        // Trigger a load for the most recent Tweets.
        loadTweets()
    }
    
    // MARK: TWTRTweetViewDelegate
    func tweetView(_ tweetView: TWTRTweetView!, didSelect tweet: TWTRTweet!) {
        // Display a Web View when selecting the Tweet.
        let webViewController = UIViewController()
        let webView = UIWebView(frame: webViewController.view.bounds)
        webView.loadRequest(URLRequest(url: tweet.permalink))
        webViewController.view = webView
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of Tweets.
        return tweets.count
    }
    
    
    /*
     let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
     cell.textLabel?.text = tweets[indexPath.row]["text"].string
     cell.detailTextLabel?.text = "By \(tweets[indexPath.row]["user"]["name"].string!), @\(tweets[indexPath.row]["user"]["screen_name"].string!)"
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        // Assign the delegate to control events on Tweets.
        //cell.tweetView.delegate = self
        
        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]
        
        cell.textLabel?.text = tweet.text
        cell.detailTextLabel?.text = "By \(tweet.author.screenName)"
        cell.textLabel?.highlight(text: "Drag", normal: nil, highlight: [NSAttributedStringKey.backgroundColor: UIColor.yellow])
        
        // Configure the cell with the Tweet.
        //cell.configure(with: tweet)
        
        // Return the Tweet cell.
        return cell
    }
    
    
}



