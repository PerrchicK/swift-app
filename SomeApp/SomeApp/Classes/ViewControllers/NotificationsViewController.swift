//
//  NotificationsViewController.swift
//  SomeApp
//
//  Created by Perry on 3/6/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class NotificationsViewController: UIViewController {

    @IBOutlet weak var keyboardPresenterTextField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        //MARK:- dispach delayed notifications
        let shortLength = dispatch_time_t.timeWithSeconds(ToastMessage.ToastMessageLength.SHORT.rawValue)

        dispatch_after(shortLength, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("yo1", object: nil)

            dispatch_after(shortLength, dispatch_get_main_queue()) { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("yo2", object: self.keyboardPresenterTextField, userInfo: ["msgKey":"PSST..."])
            }
        }

        //MARK:- create observers
        let notificationCenter = NSNotificationCenter.defaultCenter()

        notificationCenter.addObserverForName("yo1", object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            
            ToastMessage.show(messageText: "yo1 has been posted, 'self' \(self == nil ? "released" : "still exist")")
        }

        notificationCenter.addObserver(self, selector: "yoOccured:", name: "yo2", object: nil)

        notificationCenter.addObserver(self, selector: "keyboardAppeared:", name: UIKeyboardDidShowNotification, object: nil)
        

        let soon = NSDate(timeIntervalSinceNow: 5)
        if !startLocalNotification("Local notification example", title: "yo3", popTime: soon) {
            ToastMessage.show(messageText: "confirm user notification first")
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func startLocalNotification(message: String,
        title: String,
        popTime: NSDate,
        sound: String? = nil,
        additionalInfo: [String:String]? = nil) -> Bool {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
            where settings.types != .None else {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil))

            return false
        }
        
        let notification = UILocalNotification()
        notification.alertTitle = title
        notification.alertBody = message
        notification.fireDate = popTime
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = additionalInfo
        UIApplication.sharedApplication().scheduleLocalNotification(notification)

        return true
    }

    func keyboardAppeared(notification: NSNotification) {
        📘("\(notification.object)")
        ToastMessage.show(messageText: "keyboard appeard")
    }
    
    func yoOccured(notification: NSNotification) {
        📘("notification posted: \(notification)\nassociated object:\(notification.object)\nuser info:\(notification.userInfo)")
        if let textField = notification.object as? UITextField {
            textField.text = "yo2 has been posted"
        }
    }
}

extension dispatch_time_t {
    static func timeWithSeconds(seconds: Double) -> dispatch_time_t {
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        return dispatchTime
    }
}