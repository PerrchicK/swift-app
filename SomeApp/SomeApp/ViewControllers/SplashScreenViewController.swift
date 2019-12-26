//
//  SplashScreenViewController.swift
//  SomeApp
//
//  Created by Perry on 2/2/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class SplashScreenViewController : UIViewController {

    var isPresented: Bool = false
    @IBOutlet weak var swiftLogo: UIImageView!
    @IBOutlet weak var swiftLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        swiftLogo.onClick { [weak self] _ in
            self?.beGone()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        swiftLabel.text = NSLocalizedString("welcome_phrase", comment: "")

        swiftLogo.show(show: false)
        foo()
        fighters()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isPresented = true

        swiftLogo.animateFade(fadeIn: true)
        // Place the logo outside the container
        swiftLogo.center.x = -swiftLogo.center.x
        swiftLogo.center.y = -swiftLogo.center.y
        swiftLogo.animateMoveCenterTo(x: self.view.center.x, y: self.view.center.y)
        swiftLogo.animateZoom(zoomIn: true) { [weak self] (finished) -> Void in
            self?.swiftLabel.animateBounce { (finished) -> Void in
                self?.swiftLogo.animateBreath(duration: 2)

                //strongSelf.pushViewController(StarterViewController.instantiate(), animated: true)
                PerrFuncs.runBlockAfterDelay(afterDelay: 5.0, block: { () -> Void in
                    guard let strongSelf = self else { return }
                    guard strongSelf.isPresented else { return }
                    strongSelf.beGone()
                })
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPresented = false

        // After segue (1)
        📘(" ... ")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // After segue (2)
        📘(" ... ")
    }
    
    /// The `defer` command is taken from Python: https://pythonhosted.org/defer/defer.html
    func foo() {
        defer {
            defer {
                print(1)
            }
            print(2)
        }
        
        print("foo method is running")
        
        defer {
            print(3)
        }
    }
    
    func fighters() {
        print("fighters method is running")
    }

    func beGone() {
        //present(StarterViewController(), animated: true, completion: nil)
        performSegue(withIdentifier: PerrFuncs.className(StarterViewController.self), sender: self)
    }
}
