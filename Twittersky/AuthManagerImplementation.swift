//
//  AuthManagerImplementation.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import CoreData

class AuthManagerImplementation: AuthManager {
    var currentUser: User?
    
    func authenticate(login: String, password: String, completionHandler: @escaping (User) -> (), onFail: @escaping () -> Void = {}) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let predicateLogin = NSPredicate(format: "login == %@", login)
        let predicatePassword = NSPredicate(format: "password == %@", password)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLogin, predicatePassword])
        if let users = try? NSManagedObjectContext.shared.fetch(fetchRequest) as? [User], let user = users.first
        {
            currentUser = user
            NSManagedObjectContext.saveShared()
            print("User logged in")
            completionHandler(user)
        } else {
            onFail()
        }
    }
    
    func logout() {
        
    }
}
