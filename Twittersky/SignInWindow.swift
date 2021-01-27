//
//  SignInWindow.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import AppKit
import SwiftUI

class SignInWindow: NSWindow {
    private var signInContentView: SignInView
    
    
    init(_ presenter: SignInPresenter, authManager: AuthManager, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        self.signInContentView = SignInView(presenter: presenter, authManager: authManager)
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.title = ""
        self.titlebarSeparatorStyle = .none
        self.contentView = NSHostingView(rootView: self.signInContentView)
    }
}
