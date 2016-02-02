//
//  Splash.swift
//  SomeApp
//
//  Created by Perry on 2/2/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class SplashScreenViewController : UIViewController {

    override func viewDidAppear(animated: Bool) {
        UIAlertController.alert(title: "appeared", message: "yo") {
            runOnUiThread(afterDelay: 1.0, block: { [weak self] () -> Void in
                guard let strongSelf = self else { return }
                
                //strongSelf.pushViewController(StarterViewController.instantiate(), animated: true)
                strongSelf.performSegueWithIdentifier("StarterViewController", sender: self)
            })
        }
    }
}

extension UIViewController {
    public func className() -> String {
        return ""
    }
}