//
//  SplashScreenViewController.swift
//  SomeApp
//
//  Created by Perry on 2/2/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class SplashScreenViewController : UIViewController {

    @IBOutlet weak var swiftLogo: UIImageView!
    @IBOutlet weak var swiftLabel: UILabel!

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        swiftLogo.show(show: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        swiftLogo.animateFade(fadeIn: true)
        swiftLogo.animateMoveCenterTo(x: self.view.center.x, y: self.view.center.y)
        swiftLogo.animateZoom(zoomIn: true) { (finished) -> Void in
            self.swiftLabel.animateBounce { [weak self] (finished) -> Void in
                guard let strongSelf = self else { return }
                
                //strongSelf.pushViewController(StarterViewController.instantiate(), animated: true)
                runBlockAfterDelay(afterDelay: 1.0, block: { () -> Void in
                    strongSelf.performSegueWithIdentifier(className(StarterViewController), sender: self)
                })
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // After segue (1)
        📘(" ... ")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // After segue (2)
        📘(" ... ")
    }
}