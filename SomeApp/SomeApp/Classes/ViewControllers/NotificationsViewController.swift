//
//  NotificationsViewController.swift
//  SomeApp
//
//  Created by Perry on 3/6/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var keyboardPresenterTextField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //MARK:- dispach delayed notifications
        let shortLength = DispatchTime.timeWithSeconds(ToastMessage.ToastMessageLength.short.rawValue)

        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).asyncAfter(deadline: shortLength) { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "yo1"), object: nil)

            DispatchQueue.main.asyncAfter(deadline: shortLength) { () -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "yo2"), object: self.keyboardPresenterTextField, userInfo: ["msgKey":"PSST..."])
            }
        }

        //MARK:- create observers
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "yo1"), object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            
            ToastMessage.show(messageText: "yo1 has been posted, 'self' \(self == nil ? "released" : "still exist")")
        }

        notificationCenter.addObserver(self, selector: #selector(NotificationsViewController.yoOccured(_:)), name: NSNotification.Name(rawValue: "yo2"), object: nil)

        notificationCenter.addObserver(self, selector: #selector(NotificationsViewController.keyboardAppeared(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        

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

    func keyboardAppeared(_ notification: Notification) {
        📘("\(notification.object)")
        ToastMessage.show(messageText: "keyboard appeard")
    }
    
    func yoOccured(_ notification: Notification) {
        📘("notification posted: \(notification)\nassociated object:\(notification.object)\nuser info:\(notification.userInfo)")
        if let textField = notification.object as? UITextField {
            textField.text = "yo2 has been posted"
        }
    }
}

extension DispatchTime {
    static func timeWithSeconds(_ seconds: Double) -> DispatchTime {
        let dispatchTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        return dispatchTime
    }
}
