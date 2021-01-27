//
//  ReplyToTweetWindow.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import AppKit
import SwiftUI

class ReplyToTweetWindow: NewTweetWindow {
    override init(presenter: NewTweetPresenter, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(presenter: presenter, contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.title = "Reply to Tweet"
    }
}
