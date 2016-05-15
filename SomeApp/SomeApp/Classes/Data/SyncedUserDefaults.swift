//
//  SyncedUserDefaults.swift
//  SomeApp
//
//  Created by Perry on 3/26/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

protocol SyncedUserDefaultsDelegate: class {
    func syncedUserDefaults(syncedUserDefaults: SyncedUserDefaults, dbKey key: String, dbValue value: String, changed changeType: SyncedUserDefaults.ChangeType)
}

class GameResult {
    var score = 0
    var name = ""
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

    private(set) var currentDictionary = ["111":"yo"]//[String:String]()
    private static let FIREBASE_APP_URL = "https://boiling-inferno-8318.firebaseio.com/"
    private static let bundleIdentifier  = NSBundle.mainBundle().bundleIdentifier
    var syncedDbRef: Firebase?

    static let sharedInstance = SyncedUserDefaults()
    
    private func databaseChangedEvent(firebaseChangeType: FEventType, dataSnapshot: FDataSnapshot?) {
        guard let key = dataSnapshot?.key, let value = dataSnapshot?.value as? String else { return }
        var arr = [GameResult]()
        let minResult = arr.minElement { (result1, result2) -> Bool in
            result1.score < result2.score
        }

        let smaller = minResult?.score < 10
        if smaller {
            arr = arr.filter( { $0.score != minResult!.score } )
        }
        
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

        // Update current state
        if firebaseChangeType == .ChildRemoved {
            currentDictionary.removeValueForKey(key)
        } else {
            currentDictionary[key] = value
        }

        delegate?.syncedUserDefaults(self, dbKey: key, dbValue: value, changed: changeType!)
    }

    private init() {
        syncFireBase()
    }

    func syncFireBase(appUrl: String? = nil) {
        guard let bundleIdentifier = SyncedUserDefaults.bundleIdentifier where syncedDbRef == nil else { return }

        let rootRef = Firebase(url: String(format: "%@", appUrl ?? SyncedUserDefaults.FIREBASE_APP_URL))
        syncedDbRef = rootRef.childByAppendingPath(bundleIdentifier.stringByReplacingOccurrencesOfString(".", withString: "-"))

        // Listen to "add" events
        syncedDbRef?.observeEventType(FEventType.ChildAdded, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildAdded, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })

        // Listen to "changed" events
        syncedDbRef?.observeEventType(FEventType.ChildChanged, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildChanged, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })
        // Listen to "moved" (?) events
        syncedDbRef?.observeEventType(FEventType.ChildMoved, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildMoved, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })
        // Listen to "delete" events
        syncedDbRef?.observeEventType(FEventType.ChildRemoved, withBlock: { [weak self] (dataSnapshot) -> Void in
            self?.databaseChangedEvent(.ChildRemoved, dataSnapshot: dataSnapshot)
            }, withCancelBlock: { (error) -> Void in
                📘("Error: \(error)")
        })
    }

    func putString(key key: String, value: String) -> SyncedUserDefaults {
        syncedDbRef?.childByAppendingPath(key).setValue(value)
        return self
    }

    func removeString(key key: String) -> SyncedUserDefaults {
        syncedDbRef?.childByAppendingPath(key).removeValue()
        return self
    }
}