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
    private static let rootRef: DatabaseReference = Database.database().reference()
    private struct Keys {
        static let Users: String = "Users"
    }

    static func initialize() {
        FirebaseApp.configure()
        📘(rootRef)
    }

    static func createUserNode(user: User) {
        let clouUser = CloudUser(from: user, fcmToken: AppDelegate.fcmToken)
        rootRef.child(Keys.Users).child(clouUser.uid).setValue(clouUser.toDictionary())
    }

}

