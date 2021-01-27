//
//  NewTweetWindow.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 30.01.2021.
//

import Foundation
import Cocoa
import SwiftUI

class NewTweetWindow: NSWindow, NSApplicationDelegate, NSWindowDelegate {
    init(presenter: NewTweetPresenter, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let newWindow = NewTweet(presenter: presenter)
        self.title = "New Tweet"
        self.contentView = NSHostingView(rootView: newWindow)
    }
}
