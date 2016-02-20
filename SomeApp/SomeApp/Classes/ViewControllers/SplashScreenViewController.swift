//
//  SplashScreenViewController.swift
//  SomeApp
//
//  Created by Perry on 2/2/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

public func log(log: String, file:String = __FILE__, function:String = __FUNCTION__, line:Int = __LINE__) {
    print("〈INFO〉\(file.componentsSeparatedByString("/").last!) ➤ \(function.componentsSeparatedByString("(").first!) (\(line)): \(log)")
}

class SplashScreenViewController : UIViewController {

    @IBOutlet weak var swiftLogo: UIImageView!
    @IBOutlet weak var swiftLabel: UILabel!

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        log("Segue 👉 \(segue.identifier!)")
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
            self.swiftLabel.animateBump { [weak self] (finished) -> Void in
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
        
        // Before segue
        log(" ... ")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Before segue
        log(" ... ")
    }
}