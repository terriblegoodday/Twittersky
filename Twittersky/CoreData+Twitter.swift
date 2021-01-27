//
//  CoreData+Twitter.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 29.01.2021.
//

import CoreData
import AppKit
import Foundation

public extension NSManagedObject {
    convenience init(usedContext: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: usedContext)!
        self.init(entity: entity, insertInto: usedContext)
    }
}

public extension NSManagedObjectContext {
    static var shared: NSManagedObjectContext {
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return context
    }
    
    static func saveShared() {
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! context.save()
    }
}
