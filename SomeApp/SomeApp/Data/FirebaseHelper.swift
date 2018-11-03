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
        static let Requests: String = "Requests"
    }

    static var requestsCounter = 0
    static let dbUrl: String = {
        return (GoogleServiceInfoPlistContent["DATABASE_URL"] as? String) ?? ""
    }()

    static func loggedInUser(completionCallback: @escaping (_: User?) -> ()) {
        if let isActivated = isActivated {
            if isActivated {
                if Auth.auth().currentUser == nil {
                    Auth.auth().signInAnonymously { (authResult, error) in
                        📘("auth result: '\(String(describing: authResult))' with error: \(String(describing: error))")
                        completionCallback(authResult?.user)
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

    static func createUserNode(user: User) {
        if let isActivated = isActivated {
            if !isActivated { return }

            let clouUser = CloudUser(from: user, fcmToken: AppDelegate.shared.fcmToken)
            rootRef.child(Keys.Users).child(clouUser.uid).setValue(clouUser.toDictionary())
        } else {
            initialize()
            createUserNode(user: user)
        }
    }

    static func performPseudoPostRequest(path: String, data requestData: [String:Any], completion: @escaping ([String:Any]?) -> ()) {
        guard let deviceId = UIDevice.current.identifierForVendor?.description else {
            completion(nil)
            return
        }
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let requestId = "\(deviceId)_\(FirebaseHelper.requestsCounter)_\(timestamp)"
        FirebaseHelper.requestsCounter += 1
        let requestReference = rootRef.child(Keys.Requests).child("\(requestId)")
        
        requestReference.observe(DataEventType.childAdded) { (dataSnapshot) in
            guard dataSnapshot.key == "responseData" else { return }
            guard let responseDataContainer = dataSnapshot.value as? [String:Any] else { completion(nil); return }
            guard let responseData = responseDataContainer["data"] as? [String:Any] else { completion(nil); return }

            📘("Request ID: \(requestId), request data: \(requestData), response data: \(responseData)")
            requestReference.removeAllObservers()
            requestReference.removeValue()
            completion(responseData)
        }

        var request: [String:Any] = [:]
        request["requestData"] = requestData
        request["requestPath"] = path

        requestReference.setValue(request) { (requestSentError, ref) in
            //📘(ref)
        }
        
        /*
         
         The NodeJS code that handles this "POST request" in FCF style:
         
         /**
         * Triggered from a message on a Cloud Pub/Sub topic.
         *
         * @param {!Object} event The Cloud Functions event.
         * @param {!Function} The callback function.
         */
         exports.requests = functions.database.ref('/Requests/{requestId}').onWrite(event => {
         // Only edit data when it is first created.
         if (event.data.previous.exists()) return false;
         // Exit when the data is deleted.
         if (!event.data.exists()) return false;
         
         const dataSnapshot = event.data.val();
         if (!event || !event.params || !event.params.requestId) {
         console.error("missing some parameters in " + (event ? JSON.stringify(event) : "event"));
         return false;
         }
         
         //dataSnapshot.requestData |= {}; ??
         if (!dataSnapshot.requestData) {
         dataSnapshot.requestData = {};
         }
         if (!dataSnapshot.requestPath) {
         dataSnapshot.requestPath = "";
         }
         return handleRequest(event.data.key, dataSnapshot.requestPath, dataSnapshot.requestData, event.data.ref);
         });
         
         function handleRequest(requestId, path, requestData, reference) {
         function respond(data) {
         let timestampString = generateTimestamp() + "";
         reference.child("responseData").set({"data": data, "receivedPath": path, "timstamp": timestampString})
         //admin.database().ref().child("requests").child(requestId).set(dataSnapshotValue);
         }
         
         // Send response
         switch (path) {
         case "sendNotification":
         break;
         case "fetchContacts": {
         let numbers = {"+972501234567":"perrchick"};
         respond({"results":numbers});
         break;
         }
         }
         
         return true;
         }
         */
    }

}
