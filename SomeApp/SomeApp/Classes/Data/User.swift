//
//  User.swift
//  SomeApp
//
//  Created by Perry on 3/17/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {
    @NSManaged var email: String!
    @NSManaged var firstName: String!
    @NSManaged var lastName: String!
    @NSManaged var nickname: String!

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    func save() -> Bool {
        var isSaved = false
        do {
            try self.managedObjectContext?.save()
            isSaved = true
        } catch {
            📘("Error: failed to save user in Core Data: \(error)")
        }
        
        return isSaved
    }
    
    func remove() -> Bool {
        self.managedObjectContext?.delete(self)

        return true
    }
    
    override var description: String {
        return "First name: \(firstName)\n,Enail: \(email)"
    }
}
