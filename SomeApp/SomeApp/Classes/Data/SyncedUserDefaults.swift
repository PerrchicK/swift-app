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
    func syncedUserDefaults(syncedUserDefaults: SyncedUserDefaults, dbKey key: String, dbValue value: String, changed changeType: SyncedUserDefaults.ChangeType)
}

// Inspired from: https://www.raywenderlich.com/109706/firebase-tutorial-getting-started
// Many thanks, Ray :)
class SyncedUserDefaults {
    enum ChangeType {
        case Added
        case Removed
        case Modified
    }

    weak var delegate: SyncedUserDefaultsDelegate?

    private static let FIREBASE_APP_URL = "https://boiling-inferno-8318.firebaseio.com/"
    private static let bundleIdentifier  = NSBundle.mainBundle().bundleIdentifier
    // https://firebase.google.com/support/guides/firebase-ios
    var syncedDbRef: FIRDatabaseReference?

    static let sharedInstance = SyncedUserDefaults()
    
    private func databaseChangedEvent(firebaseChangeType: FIRDataEventType, dataSnapshot: FIRDataSnapshot?) {
        guard let key = dataSnapshot?.key, let value = dataSnapshot?.value as? String else { return }
        var changeType: ChangeType?

        switch firebaseChangeType {
        case .ChildAdded:
            changeType = .Added
        case .ChildRemoved:
            changeType = .Removed
        case .ChildChanged:
            changeType = .Modified
        case .ChildMoved:
            changeType = .Modified
        default:
            print("\(className(SyncedUserDefaults)) Error: unhandled firebase change type: \(firebaseChangeType)")
        }
        delegate?.syncedUserDefaults(self, dbKey: key, dbValue: value, changed: changeType!)
    }

    private init() {
        syncFireBase()
    }

    func syncFireBase(appUrl: String? = nil) {
        guard let bundleIdentifier = SyncedUserDefaults.bundleIdentifier where syncedDbRef == nil else { return }

        let rootRef = FIRDatabase.database().referenceFromURL(String(format: "%@", appUrl ?? SyncedUserDefaults.FIREBASE_APP_URL))
        syncedDbRef = rootRef.child(bundleIdentifier.stringByReplacingOccurrencesOfString(".", withString: "-"))

        // Listen to "add" events
        syncedDbRef?.observeEventType(FIRDataEventType.ChildAdded, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildAdded, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })

        // Listen to "changed" events
        syncedDbRef?.observeEventType(FIRDataEventType.ChildChanged, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildChanged, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })
        // Listen to "moved" (?) events
        syncedDbRef?.observeEventType(FIRDataEventType.ChildMoved, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildMoved, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })
        // Listen to "delete" events
        syncedDbRef?.observeEventType(FIRDataEventType.ChildRemoved, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildRemoved, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })
    }

    func putString(key: String, value: String) -> SyncedUserDefaults {
        syncedDbRef?.child(key).setValue(value)
        return self
    }
}