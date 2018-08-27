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
import Foundation

class TweetsViewController:  UITableViewController , TWTRTweetViewDelegate {
    
    // setup a 'container' for Tweets
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let reuseIdentifier: String = "reuseIdentifier"
    var range: NSRange? = nil
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
    
    
    var isLoadingTweets = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.register(TweetCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Setup table data
        TWTRTwitter.sharedInstance().sessionStore.fetchGuestSession { (guestSession, error) in
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

    }
    
    
    func loadTweets() {
        // Do not trigger another request if one is already in progress.
        if self.isLoadingTweets {
            return
        }
        self.isLoadingTweets = true
        
        // set tweetIds to find
        let tweetIDs = ["936248803182514176", "936093689612505088", "930594260352561152", "935094631787843584", "932338973724348417"];
        
        
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
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of Tweets.
        return tweets.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]
        
        cell.textLabel?.text = tweet.text
        cell.detailTextLabel?.text = "By \(tweet.author.screenName)."
        self.range = NSRange(location:0, length: (tweet.text.utf16.count))
        self.detectLanguage(with: cell.textLabel!)
        self.getTokenization(with: cell.textLabel!)
        self.getNamedEntityRecognition(with: cell.textLabel!)
        self.getLemmatization(with: cell.textLabel!)
        // Return the Tweet cell.
        return cell
    }

}

//NLP Implementation methods
extension TweetsViewController{
    
//    (1) First method detects the language using .language property of NSLinguisticTagger
    func detectLanguage(with textLabel:UILabel) {
        let _ = enumerate(scheme: .language, label: textLabel)
    }
    
    //(2) Tokenization - Segmenting into words, sentences, paragraphs etc
    func getTokenization(with textLabel:UILabel){
        let _ = enumerate(scheme: .tokenType, label: textLabel)

    }
    
    //(3) Named Entity Recognition
    func getNamedEntityRecognition(with textLabel: UILabel) {
        
        let _ = enumerate(scheme: .nameType, label: textLabel)
        
    }
    //(4) Lemmatization - Finding the root of words
    func getLemmatization(with textLabel: UILabel){
        let _ = enumerate(scheme: .lemma, label: textLabel)
    }
}

extension TweetsViewController{
    func enumerate(scheme:NSLinguisticTagScheme, label: UILabel) -> [String]?{
        var keywords = [String]()
        var tokens = [String]()
        var lemmas = [String]()
        
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
        
        let tagger = NSLinguisticTagger(tagSchemes: [scheme], options: 0)
        tagger.string = label.text
        tagger.enumerateTags(in: range!, unit: .word, scheme: scheme, options: options) {
            tag, tokenRange, _ in

            switch(scheme){
            case NSLinguisticTagScheme.lemma:
                if let lemma = tag?.rawValue {
                    lemmas.append(lemma)
                }
                break
            case NSLinguisticTagScheme.language:
                print("Dominant language: \(tagger.dominantLanguage ?? "Undetermined ")")
                break
            case NSLinguisticTagScheme.nameType:
                if let tag = tag, tags.contains(tag) {
                    let name = (label.text! as NSString).substring(with: tokenRange)
                    print("entity: \(name)")
                    keywords.append(name)
                }
                break
            case NSLinguisticTagScheme.lexicalClass:
                break
            case NSLinguisticTagScheme.tokenType:
                if let tagVal = tag?.rawValue {
                    tokens.append(tagVal.lowercased())
                }
                break
            default:
                break
            }

        }

        if (scheme == .nameType){
            let keywordAttrString = NSMutableAttributedString(string: tagger.string!, attributes: nil)
            
            for name in keywords{
                
                if let indices = label.text?.indicesOf(string: name){
                    for i in indices{
                        let range = NSRange(i..<name.count+i)
                        keywordAttrString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
                    }
                    label.attributedText = keywordAttrString
                }
            }
            return keywords
        }else if (scheme == .lemma){
            print("lemmas \(lemmas)")
            return lemmas
        }else if (scheme == .tokenType){
            print("tokens \(tokens)")
            return tokens
        }
        return nil
    }

}

