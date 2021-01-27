//
//  ProfileEditPresenter.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import AppKit
import SwiftUI

class ProfileEditWindow: NSWindow {
    init(user: User, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let newWindow = ProfileEditView()
        self.title = "Edit Profile"
        self.contentView = NSHostingView(rootView: newWindow)
    }
}

class ProfileEditPresenter: NSObject, NSWindowDelegate {
    var profileEditWindow: ProfileEditWindow?
    var rootWindow: NSWindow
    
    init(rootWindow: NSWindow, user: User) {
        let window = ProfileEditWindow(user: user, contentRect: NSRect(x: 0, y: 0, width: 320, height: 600), styleMask: [.closable, .docModalWindow, .titled], backing: .buffered, defer: false)
        self.rootWindow = rootWindow
        self.profileEditWindow = window
        super.init()
        window.delegate = self
    }
    
    func present() {
        rootWindow.beginSheet(profileEditWindow!) { (_) in
            NSManagedObjectContext.saveShared()
        }
    }
    
}
