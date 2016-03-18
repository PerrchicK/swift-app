//
//  DataManager.swift
//  SomeApp
//
//  Created by Perry on 3/17/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    private static var managedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        return appDelegate.managedObjectContext
    }

    static func createUser() -> User {
        let entity = NSEntityDescription.entityForName(className(User), inManagedObjectContext: DataManager.managedContext)
        return User(entity: entity!, insertIntoManagedObjectContext: DataManager.managedContext)
    }

    static func fetchUsers(named: String? = nil) -> [User]? {
        var fetchedUsers: [User]?
        let usersFetchRequest = NSFetchRequest(entityName: className(User))
        
        if named != nil {
            usersFetchRequest.predicate = NSPredicate(format: "firstName == %@", named!)
        }
        
        do {
            fetchedUsers = try managedContext.executeFetchRequest(usersFetchRequest) as? [User]
        } catch {
            ToastMessage.show(messageText: "Error fetching from Core Data: \(error)")
        }
        
        return fetchedUsers
    }
}