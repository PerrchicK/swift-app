//
//  ToastMessage.swift
//  SomeApp
//
//  Created by Perry on 2/18/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class ToastMessage: NibView {
    @IBOutlet weak var messageLabel: UILabel!

    static func show(messageText messageText: String, inView view: UIView) {
        let width = view.frame.width
        let frame = CGRectMake(0.0, 0.0, width, width / 2.0)
        let toastMessage = ToastMessage(frame: frame)

        toastMessage.show(show: false)
        view.addSubview(toastMessage)
        toastMessage.animateFade(fadeIn: true, duration: 0.5)
        toastMessage.center = CGPoint(x: view.center.x, y: view.center.y * 1.5)
        toastMessage.messageLabel.text = messageText
        toastMessage.backgroundColor = UIColor.grayColor()
        toastMessage.bumpAndFade()
        toastMessage.layer.cornerRadius = 5
        toastMessage.layer.masksToBounds = true
    }

    private func bumpAndFade() {
        self.transform = CGAffineTransformMakeScale(0.8, 0.8)
        self.alpha = 0.8
        
        UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            self.alpha = 0.0
            }, completion: { [weak self] (completed) -> Void in
                self?.messageLabel.text = ""
                self?.removeFromSuperview()
        })
    }
}