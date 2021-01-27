//
//  UserProfileWindow.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 01.02.2021.
//

import Foundation
import AppKit
import SwiftUI

class UserProfilePresenter: NSObject, NSWindowDelegate, TweetDelegate {
    var delegate: TweetDelegate?
    var window: UserProfileWindow
    var userInfo: UserInfo
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
        let window = UserProfileWindow(userInfo: userInfo, contentRect: NSRect(x: 0, y: 0, width: 400, height: 800), styleMask: [.closable, .docModalWindow, .miniaturizable, .titled], backing: .buffered, defer: false)
        let _ = NSWindowController(window: window)
        self.window = window
        super.init()
        window.delegate = self
    }
    
    func present() {
        window.makeKeyAndOrderFront(self)
    }
    
    // MARK: - TweetDelegate
    func shouldShowRemoveButton(for user: User) -> Bool {
        return delegate?.shouldShowRemoveButton(for: user) ?? true
    }
    
    func removeTweet(_ tweet: Tweet) {
        delegate?.removeTweet(tweet)
    }
    
    func reply(to tweet: Tweet) {
        delegate?.reply(to: tweet)
    }
    
    func showParent(of tweet: Tweet) {
        delegate?.showParent(of: tweet)
    }
    
    func showThread(parent tweet: Tweet) {
        delegate?.showThread(parent: tweet)
    }
    
    func edit(tweet: Tweet) {
        delegate?.edit(tweet: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        delegate?.showAuthor(tweet: tweet)
    }
}

class UserProfileWindow: NSWindow, TweetDelegate {
    var userInfo: UserInfo
    var tweetDelegate: TweetDelegate?
    
    init(userInfo: UserInfo, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        self.userInfo = userInfo
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let newWindow = ProfileView(userInfoForAnotherUser: userInfo)
        self.contentView = NSHostingView(rootView: newWindow)
        self.title = "@\(userInfo.user?.login ?? "")"
    }
    
    // MARK: - TweetDelegate
    func shouldShowRemoveButton(for user: User) -> Bool {
        return tweetDelegate?.shouldShowRemoveButton(for: user) ?? true
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
    
    func edit(tweet: Tweet) {
        tweetDelegate?.edit(tweet: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        tweetDelegate?.showAuthor(tweet: tweet)
    }
}
