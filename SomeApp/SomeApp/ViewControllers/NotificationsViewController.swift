//
//  NotificationsViewController.swift
//  SomeApp
//
//  Created by Perry on 3/6/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotificationsViewController: UIViewController {

    @IBOutlet weak var keyboardPresenterTextField: UITextField!
    lazy var anyObjectThatWillFilterNotifications = UIFont(name: "Arial", size: 32)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.onClick { [weak self] _ in
            self?.view.firstResponder()?.resignFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AppDelegate.shared.setupNotifications()

        //MARK:- dispatch delayed notifications
        let shortLength = DispatchTime.timeWithSeconds(ToastMessage.ToastMessageLength.short.rawValue)

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: shortLength) { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "yo1"), object: nil)

            DispatchQueue.main.asyncAfter(deadline: shortLength) { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                NotificationCenter.default.post(name: Notification.Name.yo, object: strongSelf.anyObjectThatWillFilterNotifications, userInfo: ["msgKey":"PSST..."])
                NotificationCenter.default.post(name: Notification.Name.yo, object: nil, userInfo: ["msgKey":"PSST..."])
            }
        }

        //MARK:- create observers
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "yo1"), object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            
            ToastMessage.show(messageText: "yo1 has been posted, 'self' \(self == nil ? "released" : "still exist")")
        }

        // What is the difference between this:
        notificationCenter.addObserver(self, selector: #selector(NotificationsViewController.filteredYoOccurred(_:)), name: NSNotification.Name.yo, object: anyObjectThatWillFilterNotifications)
        // And this:
        notificationCenter.addObserver(self, selector: #selector(NotificationsViewController.yoOccurred(_:)), name: NSNotification.Name.yo, object: nil)

        notificationCenter.addObserver(self, selector: #selector(NotificationsViewController.keyboardFrameChanged(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        let soon = Date(timeIntervalSinceNow: 5)
        if !startLocalNotification("Local notification example", title: "yo3", popTime: soon) {
            ToastMessage.show(messageText: "confirm user notification first")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    func startLocalNotification(_ message: String,
        title: String,
        popTime: Date,
        sound: String? = nil,
        additionalInfo: [String:String]? = nil) -> Bool {
        guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != UIUserNotificationType() else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil))

            return false
        }
        
        let notification = UILocalNotification()
        notification.alertTitle = title
        notification.alertBody = message
        notification.fireDate = popTime
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = additionalInfo
        UIApplication.shared.scheduleLocalNotification(notification)

        return true
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else { return }
        
        if let keyboardAnimationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            handleNewKeyboardHeight(0, withAnimationDuration: keyboardAnimationDuration)
        } else {
            📘("Failed to extract keyboard frame!")
        }
    }

    @objc func applicationDidEnterBackground(_ notification: Notification) {
        PerrFuncs.runBackgroundTask { [weak self](onDone) in
            guard let strongSelf = self else { return }

            if let fcmToken = AppDelegate.shared.fcmToken {
                let registrationIds: [String] = [fcmToken]
                self?.sendFcmNotificationUsingUrlRequest(notificationDictionary: strongSelf.generateNotificationPayload(withAlertTitle: "Remote notification example", andBody: "push notification's body"), dataDictionary: ["more data":"some ID"], toRegistrationIds: registrationIds) { succeeded in
                    📘("did push notification request succeeded? - \(succeeded)")
                    onDone()
                }
            }
        }
    }

    @objc func keyboardFrameChanged(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else { return }
        
        if let keyboardAnimationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            let keyboardHeight = keyboardFrame.height

            handleNewKeyboardHeight(keyboardHeight, withAnimationDuration: keyboardAnimationDuration)
        } else {
            📘("Failed to extract keyboard frame!")
        }
    }
    
    func handleNewKeyboardHeight(_ keyboardHeight: CGFloat, withAnimationDuration keyboardAnimationDuration: TimeInterval) {
        UIView.animate(withDuration: keyboardAnimationDuration, animations: { [weak self] in
            self?.view.frame.origin.y = -keyboardHeight
        }, completion: nil)
    }
    
    @objc func yoOccurred(_ notification: Notification) {
        📘("notification posted: \(notification)\nassociated object:\(String(describing: notification.object))\nuser info:\(String(describing: notification.userInfo))")
        if let textField = notification.object as? UITextField {
            textField.text = "yo2 has been posted"
        }
    }

    @objc func filteredYoOccurred(_ notification: Notification) {
        📘("notification posted: \(notification)\nassociated object:\(String(describing: notification.object))\nuser info:\(String(describing: notification.userInfo))")
        if let textField = notification.object as? UITextField {
            textField.text = "yo2 has been posted"
        }
    }

    private func generateNotificationPayload(withAlertTitle title: String, andBody body: String) -> [String:String] {
        var notificationDictionary = [String:String]()
        notificationDictionary["alert"] = title
        notificationDictionary["body"] = body
        notificationDictionary["icon"] = "app-icon"
        notificationDictionary["title"] = title
        notificationDictionary["sound"] = "default.aiff"
        
        return notificationDictionary
    }

    func sendFcmNotificationUsingUrlRequest(notificationDictionary: [String:String], dataDictionary: [String:String], toRegistrationIds registrationIds: [String], completion: @escaping (Bool) -> ()) {
        guard registrationIds.count > 0 else { completion(false); return }

        var jsonDictionary = [String:Any]()
        jsonDictionary["registration_ids"] = registrationIds // or use 'to' for a single device
        jsonDictionary["notification"] = notificationDictionary
        jsonDictionary["data"] = dataDictionary
        
        let secretApiKey: String = "AAAAQ_UBwaU:APA91bHap420yZr1gH9xq__jyiYHI86SINQhuYJbeITdd3W5iADL5Bh-oHas1KyE6GNMjLTDXKVU4953NkhJ_o5h3oxYr9XWh0z_htRQpVpCB5rGD-Tam4dCees7jf-I2CbpzMh3yFTx"

        PerrFuncs.postRequest(urlString: "https://fcm.googleapis.com/fcm/send", jsonDictionary: jsonDictionary, httpHeaders: ["Authorization":"key= \(secretApiKey)"]) { (responseDataJson) in
            guard let succeededCount = responseDataJson?["success"] as? Int else { completion(false); return }
            
            📘("responseDataJson: \(String(describing: responseDataJson))")
            completion(succeededCount > 0)
        }
    }
}

extension DispatchTime {
    static func timeWithSeconds(_ seconds: Double) -> DispatchTime {
        let dispatchTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        return dispatchTime
    }
}

extension Notification.Name {
    static let yo = Notification.Name(rawValue: "yo2")
}
