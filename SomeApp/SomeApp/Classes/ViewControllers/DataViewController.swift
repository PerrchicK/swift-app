//
//  DataViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import CoreData

class DataViewController: UIViewController {
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        return appDelegate.managedObjectContext
    }()

    override func viewDidLoad() {

        print(fetchUsers())

        let user = NSEntityDescription.insertNewObjectForEntityForName(className(User), inManagedObjectContext: self.managedContext) as! User
        📘("\(user)")
        user.email = "perrchick@gmail.com"
        user.firstName = "Perry"
        user.lastName = "Shalom"
        user.nickname = "perrchick"
        user.save()
    }

    func fetchUsers(named: String? = nil) -> [User]? {
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

class User: NSManagedObject {
    @NSManaged var email: String!
    @NSManaged var firstName: String!
    @NSManaged var lastName: String!
    @NSManaged var nickname: String!
    
    func save() -> Bool {
        defer {
            ToastMessage.show(messageText: "User")
        }

        var isSaved = false
        do {
            try self.managedObjectContext?.save()
            isSaved = true
        } catch {
            📘("Error: failed to save user in Core Data: \(error)")
        }

        return isSaved
    }
}