//
//  DataManager.swift
//  SomeApp
//
//  Created by Perry on 3/17/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataManager {
    private static var applicationDirectoryPath: String = {
        if let libraryDirectoryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).last {
            return libraryDirectoryPath
        }

        📘("ERROR!! Library directory not found 😱")
        return ""
    }()

    private static var managedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        return appDelegate.managedObjectContext
    }

    static func saveImage(imageToSave: UIImage, toFile filename: String) -> Bool {
        if let data = UIImagePNGRepresentation(imageToSave) {
            do {
                try data.writeToFile(applicationDirectoryPath + "/" + filename, options: .AtomicWrite)
                return true
            } catch {
                📘("Failed to save image!")
            }
        }

        return false
    }
    
    static func loadImage(fromFile filename: String) -> UIImage? {
        if let data = NSData(contentsOfFile: applicationDirectoryPath + "/" + filename) {
            return UIImage(data: data)
        }

        return nil
    }
    
    static func createUser() -> User {
        let entity = NSEntityDescription.entityForName(className(User), inManagedObjectContext: DataManager.managedContext)
        return User(entity: entity!, insertIntoManagedObjectContext: DataManager.managedContext)
    }

    static func syncedUserDefaults() -> SyncedUserDefaults {
        return SyncedUserDefaults.sharedInstance
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