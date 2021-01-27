//
//  UserInfo.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import CoreData

class UserInfo: ObservableObject {
    var currentUser: User?
    var user: User?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSManagedObjectContext.didChangeObjectsNotification, object: NSManagedObjectContext.shared)
    }
    
    @objc func refresh() {
        refreshed.toggle()
    }
    
    @Published private var refreshed = false
}
