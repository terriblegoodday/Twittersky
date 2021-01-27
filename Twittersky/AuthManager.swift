//
//  AuthManager.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation

protocol AuthManager {
    var currentUser: User? { get }
    
    func authenticate(login: String, password: String, completionHandler: @escaping (_ user: User) -> (), onFail: @escaping () -> Void)
    func logout()
}
