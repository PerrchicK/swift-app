//
//  User.swift
//  SomeApp
//
//  Created by Perry on 3/17/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import CoreData

/**
 Thanks to the swift namespacing, this 'User' class won't conflict the Firebase 'User' class.
 It's possible to access this class by using 'SomeApp.User'.

 In ObjC we had to rename one of these classes.
 */
class User: NSManagedObject {
    @NSManaged var email: String!
    @NSManaged var firstName: String!
    @NSManaged var lastName: String!
    @NSManaged var nickname: String!

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    @discardableResult
    func save() -> Bool {
        var isSaved = false
        do {
            try self.managedObjectContext?.save()
            isSaved = true
        } catch {
            📘("Error: failed to save user (\(self)) in Core Data: \(error)")
        }
        
        return isSaved
    }

    func remove() -> Bool {
        self.managedObjectContext?.delete(self)

        return true
    }

    // We have this method thanks to the NSObject inheritance
    override var description: String {
        return "first name: \(firstName ?? "none"), email: \(email ?? "none")"
    }
}
