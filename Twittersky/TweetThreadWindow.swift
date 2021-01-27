//
//  TweetThreadWindow.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import AppKit
import SwiftUI

class TweetThreadWindow: NSWindow, TweetDelegate {
    func edit(tweet: Tweet) {
        tweetDelegate?.edit(tweet: tweet)
    }
    
    var tweetDelegate: TweetDelegate?
    
    func shouldShowRemoveButton(for user: User) -> Bool {
        tweetDelegate?.shouldShowRemoveButton(for: user) ?? true
    }
    
    func removeTweet(_ tweet: Tweet) {
        tweetDelegate?.removeTweet(tweet)
    }
    
    func reply(to tweet: Tweet) {
        tweetDelegate?.reply(to: tweet)
    }
    
    func showParent(of tweet: Tweet) {
        tweetDelegate?.showParent(of: tweet)
    }
    
    func showThread(parent tweet: Tweet) {
        tweetDelegate?.showThread(parent: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        tweetDelegate?.showAuthor(tweet: tweet)
    }
    
    var root: Tweet
    
    init(root: Tweet, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        var tweets = [root]
        tweets.append(contentsOf: root.replies!.sortedArray(using: [NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)]) as! [Tweet])
        self.root = root
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let newWindow = Tweets(tweets: tweets, delegate: self, toggleActive: false)
        self.contentView = NSHostingView(rootView: newWindow)
        self.title = "Thread @\(root.author!.login ?? "nil")"
    }
    
    
}
