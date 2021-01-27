//  TweetManager.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 30.01.2021.
//

import Foundation
import CoreData
import AppKit

protocol TweetManagerDelegate {
    var currentUser: User { get }
}

class TweetEditor: NSObject, NewTweetPresenter, NSWindowDelegate {
    var window: NSWindow?
    var currentTweet: Tweet
    
    init(tweet: Tweet) {
        self.currentTweet = tweet
    }
    
    func sendTweet(body: String) {
        currentTweet.body = body
        window?.close()
        NSManagedObjectContext.saveShared()
    }
    
    func present() {
        let window = EditTweetWindow(presenter: self, text: currentTweet.body!, contentRect: NSRect(x: 0, y: 0, width: 320, height: 320), styleMask: [.closable, .hudWindow, .titled], backing: .buffered, defer: false)
        let _ = NSWindowController(window: window)
        window.delegate = self
        self.window = window
        NSApp.runModal(for: window)
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }
}

class TweetManager: NSObject, NewTweetPresenter, NSWindowDelegate, TweetDelegate {
    var delegate: TweetManagerDelegate?
    var window: NSWindow?
    var tweetToReply: Tweet?
    var previousView = 0
    
    init(with delegate: TweetManagerDelegate? = nil) {
        self.delegate = delegate
    }
    
    func sendTweet(body: String) {
        let tweet = Tweet(context: NSManagedObjectContext.shared)
        tweet.body = body
        tweet.author = delegate?.currentUser
        tweet.createdAt = Date()
        tweet.parent = tweetToReply
        NSManagedObjectContext.saveShared()
        self.window?.close()
    }
    
    func removeTweet(_ tweet: Tweet) {
        NSManagedObjectContext.shared.delete(tweet)
        NSManagedObjectContext.saveShared()
    }
    
    func reply(to tweet: Tweet) {
        if let currentUser = delegate?.currentUser, let login = currentUser.login, login != "anonymous" {
            let window = ReplyToTweetWindow(presenter: self, contentRect: NSRect(x: 0, y: 0, width: 320, height: 320), styleMask: [.closable, .hudWindow, .titled], backing: .buffered, defer: false)
            window.delegate = self
            let _ = NSWindowController(window: window)
            self.tweetToReply = tweet
            self.window = window
            NSApp.runModal(for: window)
        } else {
            let alert = NSAlert()
            alert.messageText = "You are not authorized"
            alert.addButton(withTitle: "Done")
            alert.runModal()
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }
    
    func showParent(of tweet: Tweet) {
        let window = TweetParentWindow(tweet: tweet.parent!, contentRect: NSRect(x: previousView + 15, y: previousView + 15, width: 320, height: 120), styleMask: [.closable, .hudWindow, .titled], backing: .buffered, defer: false)
        previousView += 15
        window.delegate = self
        let _ = NSWindowController(window: window)
        window.makeKeyAndOrderFront(self)
        window.tweetDelegate = self
    }
    
    func shouldShowRemoveButton(for user: User) -> Bool {
        return delegate?.currentUser == user
    }
    
    func showThread(parent tweet: Tweet) {
        let window = TweetThreadWindow(root: tweet, contentRect: NSRect(x: 0, y: 0, width: 600, height: 1200),
                                       styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                                       backing: .buffered, defer: false)
        let _ = NSWindowController(window: window)
        window.makeKeyAndOrderFront(self)
        window.tweetDelegate = self
    }
    
    func edit(tweet: Tweet) {
        if let currentUser = delegate?.currentUser, let _ = currentUser.login, currentUser == tweet.author {
            let tweetEditor = TweetEditor(tweet: tweet)
            tweetEditor.present()
        } else {
            let alert = NSAlert()
            alert.messageText = "You are not authorized"
            alert.addButton(withTitle: "Done")
            alert.runModal()
        }
    }
    
    func edit(profile: User) {
        
    }
    
    func showAuthor(tweet: Tweet) {
        let userInfo = UserInfo()
        userInfo.user = tweet.author
        userInfo.currentUser = delegate?.currentUser ?? User(context: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
        let presenter = UserProfilePresenter(userInfo: userInfo)
        presenter.present()
    }
}
