//
//  MainWindowDelegate.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation

protocol MainWindowDelegate {
    func didClickSignInButton()
    func logout()
    func destroy()
}
