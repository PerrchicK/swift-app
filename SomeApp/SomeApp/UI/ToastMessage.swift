//
//  ToastMessage.swift
//  SomeApp
//
//  Created by Perry on 2/18/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

enum ToastMessageLength: NSTimeInterval {
    case LONG = 5.0
    case SHORT = 3.0
}

class ToastMessage: NibView {

    @IBOutlet weak var messageLabel: UILabel!
    private(set) var delay: NSTimeInterval = 1.0

    static func show(messageText messageText: String, inView view: UIView, delay: ToastMessageLength = ToastMessageLength.SHORT) {
        let width = view.frame.width
        let frame = CGRectMake(0.0, 0.0, width, width / 2.0)
        let toastMessage = ToastMessage(frame: frame)

        toastMessage.delay = delay.rawValue
        toastMessage.show(show: false)
        view.addSubview(toastMessage)
        toastMessage.animateFade(fadeIn: true, duration: 0.5)
        toastMessage.center = CGPoint(x: view.center.x, y: view.center.y * 1.5)
        toastMessage.messageLabel.text = messageText
        toastMessage.backgroundColor = UIColor.grayColor()
        toastMessage.layer.cornerRadius = 5
        toastMessage.layer.masksToBounds = true
        toastMessage.userInteractionEnabled = false
//        toastMessage.translatesAutoresizingMaskIntoConstraints = false
//        toastMessage.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: toastMessage, attribute: .Bottom, multiplier: 1.0, constant: 30.0))

        toastMessage.bumpAndFade()
    }

    private func bumpAndFade() {
        self.transform = CGAffineTransformMakeScale(0.8, 0.8)
        self.alpha = 0.8
        
        UIView.animateWithDuration(0.5, delay: self.delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            self.alpha = 0.0
            }, completion: { [weak self] (completed) -> Void in
                self?.messageLabel.text = ""
                self?.removeFromSuperview()
        })
    }
}