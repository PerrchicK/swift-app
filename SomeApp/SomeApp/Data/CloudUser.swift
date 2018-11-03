//
//  CloudUser.swift
//  SomeApp
//
//  Created by Perry on 12/01/2018.
//  Copyright © 2018 PerrchicK. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

//protocol FirebaseDictionaryConveratable {
//    func toFirebaseDictionary()
//}
//
//extension FirebaseDictionaryConveratable {
//    /// https://stackoverflow.com/questions/25463146/iterate-over-object-class-attributes-in-swift
//    func toFirebaseDictionary() -> [String:Any] {
//        let mirrored_object = Mirror(reflecting: self)
//        var firebaseDictionary = [String:Any]()
//        for (index, attr) in mirrored_object.children.enumerated() {
//            if let propertyName = attr.label {
//                let propertyValue = attr.value
//                print("Attr \(index): \(propertyName) = \(propertyValue)")
//                firebaseDictionary[propertyName] = propertyValue
//            }
//        }
//
//        return firebaseDictionary
//    }
//}

class CloudUser: DictionaryConvertible {
    private(set) var uid: String
    var fcmToken: String?

    init(from user: User, fcmToken: String?) {
        uid = user.uid
        self.fcmToken = fcmToken
    }
}
