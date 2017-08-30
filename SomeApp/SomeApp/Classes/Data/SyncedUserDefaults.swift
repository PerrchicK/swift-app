//
//  SyncedUserDefaults.swift
//  SomeApp
//
//  Created by Perry on 3/26/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import Firebase

protocol SyncedUserDefaultsDelegate: class {
    func syncedUserDefaults(_ syncedUserDefaults: SyncedUserDefaults, dbKey key: String, dbValue value: String, changed changeType: SyncedUserDefaults.ChangeType)
}

// Inspired from: https://www.raywenderlich.com/109706/firebase-tutorial-getting-started
// Many thanks, Ray :)
class SyncedUserDefaults {
    enum ChangeType {
        case added
        case removed
        case modified
    }

    weak var delegate: SyncedUserDefaultsDelegate?

    fileprivate(set) var currentDictionary = [String:String]()
    fileprivate static let FIREBASE_APP_URL = "https://boiling-inferno-8318.firebaseio.com/"
    fileprivate static let bundleIdentifier  = Bundle.main.bundleIdentifier
    // https://firebase.google.com/support/guides/firebase-ios
    var syncedDbRef: DatabaseReference?

    static let sharedInstance = SyncedUserDefaults()
    
    fileprivate func databaseChangedEvent(_ firebaseChangeType: DataEventType, dataSnapshot: DataSnapshot?) {
        guard let key = dataSnapshot?.key, let value = dataSnapshot?.value as? String else { return }
        
        var changeType: ChangeType?

        switch firebaseChangeType {
        case .childAdded:
            changeType = .added
        case .childRemoved:
            changeType = .removed
        case .childChanged:
            changeType = .modified
        case .childMoved:
            changeType = .modified
        default:
            print("\(className(SyncedUserDefaults.self)) Error: unhandled firebase change type: \(firebaseChangeType)")
        }

        // Update current state
        if firebaseChangeType == .childRemoved {
            currentDictionary.removeValue(forKey: key)
        } else {
            currentDictionary[key] = value
        }

        delegate?.syncedUserDefaults(self, dbKey: key, dbValue: value, changed: changeType!)
    }

    fileprivate init() {
        syncFireBase()
    }

    func syncFireBase(_ appUrl: String? = nil) {
        guard let bundleIdentifier = SyncedUserDefaults.bundleIdentifier, syncedDbRef == nil else { return }

        let rootRef = Database.database().reference(fromURL: String(format: "%@", appUrl ?? SyncedUserDefaults.FIREBASE_APP_URL))
        syncedDbRef = rootRef.child(bundleIdentifier.replacingOccurrences(of: ".", with: "-"))

        // Listen to "add" events
        syncedDbRef?.observe(DataEventType.childAdded, with: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.childAdded, dataSnapshot: dataSnapshot)
            }, withCancel: { (error) -> Void in
                📘("Error: \(error)")
        })

        // Listen to "changed" events
        syncedDbRef?.observe(DataEventType.childChanged, with: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.childChanged, dataSnapshot: dataSnapshot)
            }, withCancel: { (error) -> Void in
                📘("Error: \(error)")
        })
        // Listen to "moved" (?) events
        syncedDbRef?.observe(DataEventType.childMoved, with: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.childMoved, dataSnapshot: dataSnapshot)
            }, withCancel: { (error) -> Void in
                📘("Error: \(error)")
        })
        // Listen to "delete" events
        syncedDbRef?.observe(DataEventType.childRemoved, with: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.childRemoved, dataSnapshot: dataSnapshot)
            }, withCancel: { (error) -> Void in
                📘("Error: \(error)")
        })
    }

    @discardableResult
    func putString(key: String, value: String) -> SyncedUserDefaults {
        syncedDbRef?.child(key).setValue(value)
        return self
    }

    @discardableResult
    func removeString(key: String) -> SyncedUserDefaults {
        syncedDbRef?.child(key).removeValue()
        return self
    }
}
