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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        swiftLogo.show(show: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        swiftLogo.animateFade(fadeIn: true)
        // Place the logo outside the container
        swiftLogo.center.x = -swiftLogo.center.x
        swiftLogo.center.y = -swiftLogo.center.y
        swiftLogo.animateMoveCenterTo(x: self.view.center.x, y: self.view.center.y)
        swiftLogo.animateZoom(zoomIn: true) { (finished) -> Void in
            self.swiftLabel.animateBounce { [weak self] (finished) -> Void in
                guard let strongSelf = self else { return }
                
                //strongSelf.pushViewController(StarterViewController.instantiate(), animated: true)
                runBlockAfterDelay(afterDelay: 1.0, block: { () -> Void in
                    strongSelf.performSegue(withIdentifier: className(StarterViewController), sender: self)
                })
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // After segue (1)
        📘(" ... ")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // After segue (2)
        📘(" ... ")
    }
}
