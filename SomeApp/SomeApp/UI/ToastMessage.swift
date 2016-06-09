//
//  ToastMessage.swift
//  SomeApp
//
//  Created by Perry on 2/18/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class ToastMessage: NibView {

    enum ToastMessageLength: NSTimeInterval {
        case LONG = 5.0
        case SHORT = 3.0
    }

    @IBOutlet weak var messageLabel: UILabel!
    private(set) var delay: NSTimeInterval = 1.0

    static func show(messageText messageText: String, delay: ToastMessageLength = ToastMessageLength.SHORT, onGone: (() -> ())? = nil) {
        guard let appWindow = UIApplication.sharedApplication().keyWindow else { fatalError("cannot use keyWindow") }

        let width = UIScreen.mainScreen().bounds.width
        let frame = CGRectMake(0.0, 0.0, width, width / 2.0)
        let toastMessage = ToastMessage(frame: frame)

        toastMessage.delay = delay.rawValue
        toastMessage.show(show: false)
        appWindow.addSubview(toastMessage)
        toastMessage.messageLabel.text = messageText
        toastMessage.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.8)
        toastMessage.layer.cornerRadius = 5
        toastMessage.layer.masksToBounds = true
        toastMessage.userInteractionEnabled = false
        // Irrelevant due to the following constraints...
//        toastMessage.center = CGPoint(x: appWindow.center.x, y: appWindow.center.y * 1.5)
        toastMessage.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = NSLayoutConstraint(item: toastMessage, attribute: .Bottom, relatedBy: .Equal, toItem: toastMessage.superview, attribute: .Bottom, multiplier: 1, constant: -30.0)
        let leftConstraint = NSLayoutConstraint(item: toastMessage, attribute: .Left, relatedBy: .Equal, toItem: toastMessage.superview, attribute: .Left, multiplier: 1, constant: 10.0)
        let rightConstraint = NSLayoutConstraint(item: toastMessage, attribute: .Right, relatedBy: .Equal, toItem: toastMessage.superview, attribute: .Right, multiplier: 1, constant: -10.0)
        appWindow/* which is: toastMessage.superview */.addConstraints([bottomConstraint, leftConstraint, rightConstraint])

        let heightConstraint = NSLayoutConstraint(item: toastMessage, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.3 * max(appWindow.frame.height, appWindow.frame.width))
        toastMessage.addConstraint(heightConstraint)
        toastMessage.animateFade(fadeIn: true, duration: 0.5)
        toastMessage.animateBounce()

        runBlockAfterDelay(afterDelay: toastMessage.delay) {
            toastMessage.animateScaleAndFadeOut { [weak toastMessage] (completed) in
                toastMessage?.messageLabel.text = ""
                toastMessage?.removeFromSuperview()
                onGone?()
            }
        }
    }
}