//
//  FirebaseHelper.swift
//  SomeApp
//
//  Created by Perry on 12/01/2018.
//  Copyright © 2018 PerrchicK. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Firebase

class FirebaseHelper {

    static let FIREBASE_CONFIGURATION_FILE_DEFAULT_NAME = "GoogleService-Info.plist"
    private(set) static var isActivated: Bool?
    private static let rootRef: DatabaseReference = Database.database().reference()
    private struct Keys {
        static let Users: String = "Users"
    }

    static let dbUrl: String = {
        return (GoogleServiceInfoPlistContent["DATABASE_URL"] as? String) ?? ""
    }()

    static func loggedInUser(completionCallback: @escaping (_: Firebase.User?) -> ()) {
        if let isActivated = isActivated {
            if isActivated {
                if Auth.auth().currentUser == nil {
                    Auth.auth().signInAnonymously { (anAnonymouslyUser, error) in
                        📘("\(anAnonymouslyUser) logged in with error: \(error)")
                        completionCallback(anAnonymouslyUser)
                    }
                } else {
                    completionCallback(Auth.auth().currentUser)
                }
            } else {
                completionCallback(nil)
            }
        } else {
            initialize()
            loggedInUser(completionCallback: completionCallback)
        }
    }

    static let GoogleServiceInfoPlistContent: NSDictionary = {
        let googleServiceInfoPlistContent: NSDictionary
        let fileNameAndExtension = FIREBASE_CONFIGURATION_FILE_DEFAULT_NAME.components(separatedBy: ".")
        guard fileNameAndExtension.count == 2 else { return [:] }

        let fileName = fileNameAndExtension.first
        let fileExtension = fileNameAndExtension.last

        if let fileExtension = fileExtension,
            let fileName = fileName,
            let filePath: String = Bundle.main.path(forResource: fileName, ofType: fileExtension),
            let _googleServiceInfoPlistContent = NSDictionary(contentsOfFile:filePath) {
            googleServiceInfoPlistContent = _googleServiceInfoPlistContent
            //Dictionary<AnyHashable, Any>.init(from: filePath) ??
        } else {
            googleServiceInfoPlistContent = [:]
        }
        
        return googleServiceInfoPlistContent
    }()

    @discardableResult
    static func initialize() -> String? {
        if let isActivated = isActivated {
            if isActivated {
                return dbUrl
            } else {
                return nil
            }
        }

        let _dbUrl = dbUrl
        if let _ = URL(string: _dbUrl) {
            FirebaseApp.configure()
            isActivated = true
            return _dbUrl
        }

        isActivated = false

        return nil
    }

    static func createUserNode(user: Firebase.User) {
        if let isActivated = isActivated {
            if !isActivated { return }

            let clouUser = CloudUser(from: user, fcmToken: AppDelegate.fcmToken)
            rootRef.child(Keys.Users).child(clouUser.uid).setValue(clouUser.toDictionary())
        } else {
            initialize()
            createUserNode(user: user)
        }
    }

}
