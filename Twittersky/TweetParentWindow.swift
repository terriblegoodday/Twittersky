//
//  TweetParentWindow.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import AppKit
import SwiftUI

class TweetParentWindow: NSWindow, TweetDelegate {
    var tweet: Tweet
    var tweetDelegate: TweetDelegate?
    
    init(tweet: Tweet, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        self.tweet = tweet
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let newWindow = TweetView(tweet: self.tweet, delegate: self).padding()
        self.contentView = NSHostingView(rootView: newWindow)
        self.title = "Tweet of @\(tweet.author!.login ?? "")"
    }
    
    func showParent(of tweet: Tweet) {
        tweetDelegate?.showParent(of: tweet)
    }
    
    func reply(to tweet: Tweet) {
        tweetDelegate?.reply(to: tweet)
    }
    
    func shouldShowRemoveButton(for user: User) -> Bool {
        tweetDelegate?.shouldShowRemoveButton(for: user) ?? false
    }
    
    func removeTweet(_ tweet: Tweet) {
        tweetDelegate?.removeTweet(tweet)
    }
    
    func showThread(parent tweet: Tweet) {
        tweetDelegate?.showThread(parent: tweet)
    }
    
    func edit(tweet: Tweet) {
        tweetDelegate?.edit(tweet: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        tweetDelegate?.showAuthor(tweet: tweet)
    }
}
