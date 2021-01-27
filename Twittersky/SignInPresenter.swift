//
//  SignInPresenter.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import AppKit

extension NSWindow {
    func shakeWindow(){
        let numberOfShakes          = 3
        let durationOfShake         = 0.3
        let vigourOfShake : CGFloat = 0.04
        let frame : CGRect = self.frame
        let shakeAnimation :CAKeyframeAnimation  = CAKeyframeAnimation()
        
        let shakePath = CGMutablePath()
        shakePath.move( to: CGPoint(x:NSMinX(frame), y:NSMinY(frame)))
        
        for _ in 0...numberOfShakes-1 {
            shakePath.addLine(to: CGPoint(x:NSMinX(frame) - frame.size.width * vigourOfShake, y:NSMinY(frame)))
            shakePath.addLine(to: CGPoint(x:NSMinX(frame) + frame.size.width * vigourOfShake, y:NSMinY(frame)))
        }
        
        shakePath.closeSubpath()
        shakeAnimation.path = shakePath
        shakeAnimation.duration = durationOfShake
        
        self.animations = ["frameOrigin":shakeAnimation]
        self.animator().setFrameOrigin(self.frame.origin)
    }
}

protocol SignInPresenterDelegate: NSObjectProtocol {
    func didSignIn(with user: User)
}

class SignInPresenter: NSObject, NSWindowDelegate {
    var delegate: SignInPresenterDelegate!
    var window: SignInWindow?
    
    func present() {
        let authManager = AuthManagerImplementation()
        let window = SignInWindow(self, authManager: authManager, contentRect: NSRect(x: 0, y: 0, width: 250, height: 320), styleMask: [.titled, .docModalWindow], backing: .buffered, defer: false)
        window.delegate = self
        self.window = window
        let _ = NSWindowController(window: window)
        NSApp.runModal(for: window)
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }
    
    func shakeWindow() {
        window?.shakeWindow()
    }
    
    func completeSignIn(user: User) {
        if let delegate = delegate {
            delegate.didSignIn(with: user)
        } else {
            print("No delegate")
        }
        window?.close()
    }
}
