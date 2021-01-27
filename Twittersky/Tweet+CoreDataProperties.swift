//
//  Tweet+CoreDataProperties.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//
//

import Foundation
import CoreData


extension Tweet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tweet> {
        return NSFetchRequest<Tweet>(entityName: "Tweet")
    }

    @NSManaged public var body: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var author: User?
    @NSManaged public var parent: Tweet?
    @NSManaged public var replies: NSSet?

}

// MARK: Generated accessors for replies
extension Tweet {

    @objc(addRepliesObject:)
    @NSManaged public func addToReplies(_ value: Tweet)

    @objc(removeRepliesObject:)
    @NSManaged public func removeFromReplies(_ value: Tweet)

    @objc(addReplies:)
    @NSManaged public func addToReplies(_ values: NSSet)

    @objc(removeReplies:)
    @NSManaged public func removeFromReplies(_ values: NSSet)

}

extension Tweet : Identifiable {
}
