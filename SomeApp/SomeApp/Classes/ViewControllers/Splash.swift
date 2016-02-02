//
//  Splash.swift
//  SomeApp
//
//  Created by Perry on 2/2/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class SplashScreenViewController : UIViewController {

    @IBOutlet weak var swiftLogo: UIImageView!
    @IBOutlet weak var swiftLabel: UILabel!

    override func viewDidAppear(animated: Bool) {
        swiftLogo.animateFlyTo(x: self.view.center.x, y: self.view.center.y)
        swiftLogo.animateZoom(true) { (finished) -> Void in
            self.swiftLabel.animateBump { [weak self] (finished) -> Void in
                guard let strongSelf = self else { return }
                
                //strongSelf.pushViewController(StarterViewController.instantiate(), animated: true)
                runBlockAfterDelay(afterDelay: 1.0, block: { () -> Void in
                    strongSelf.performSegueWithIdentifier(className(StarterViewController), sender: self)
                })
            }
        }
    }
}

extension UIView {
    public func animateBump(completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion: completion)
    }

    public func animateFlyTo(x x: CGFloat, y: CGFloat, completion: ((Bool) -> Void)? = nil) {
        self.center.x = -self.center.x
        self.center.y = -self.center.y

        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.center.x = x
            self.center.y = y
            }, completion: completion)
    }

    public func animateZoom(zoomIn: Bool, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransformMakeScale(0.0, 0.0)
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }, completion: completion)
    }
}