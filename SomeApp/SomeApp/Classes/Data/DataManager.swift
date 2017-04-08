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
    fileprivate static var applicationDirectoryPath: String = {
        if let libraryDirectoryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last {
            return libraryDirectoryPath
        }

        📘("ERROR!! Library directory not found 😱")
        return ""
    }()

    fileprivate static var managedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.managedObjectContext
    }

    static func saveImage(_ imageToSave: UIImage, toFile filename: String) -> Bool {
        if let data = UIImagePNGRepresentation(imageToSave) {
            do {
                try data.write(to: URL(fileURLWithPath: applicationDirectoryPath + "/" + filename), options: .atomicWrite)
                return true
            } catch {
                📘("Failed to save image!")
            }
        }

        return false
    }
    
    static func loadImage(fromFile filename: String) -> UIImage? {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: applicationDirectoryPath + "/" + filename)) {
            return UIImage(data: data)
        }

        return nil
    }
    
    static func createUser() -> User {
        let entity = NSEntityDescription.entity(forEntityName: className(User.self), in: DataManager.managedContext)
        return User(entity: entity!, insertInto: DataManager.managedContext)
    }

    static func syncedUserDefaults() -> SyncedUserDefaults {
        return SyncedUserDefaults.sharedInstance
    }

    static func fetchUsers(_ named: String? = nil) -> [User]? {
        var fetchedUsers: [User]?
        let usersFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: className(User.self))
        
        if named != nil {
            usersFetchRequest.predicate = NSPredicate(format: "firstName == %@", named!)
        }
        
        do {
            fetchedUsers = try managedContext.fetch(usersFetchRequest) as? [User]
        } catch {
            ToastMessage.show(messageText: "Error fetching from Core Data: \(error)")
        }
        
        return fetchedUsers
    }
}
