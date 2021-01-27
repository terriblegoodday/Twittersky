//
//  EditTweetWindow.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import Cocoa
import SwiftUI

class EditTweetWindow: NSWindow, NSApplicationDelegate, NSWindowDelegate {
    init(presenter: NewTweetPresenter, text: String, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let newWindow = NewTweet(presenter: presenter, text: text, existingTweet: true)
        self.title = "Edit Tweet"
        self.contentView = NSHostingView(rootView: newWindow)
    }
}
