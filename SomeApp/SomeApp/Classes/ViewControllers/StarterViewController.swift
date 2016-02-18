//
//  StarterViewController.swift
//  SomeApp
//
//  Created by Perry on 1/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class StarterViewController: UIViewController {

    // Lazy variable - will be allocated (and initialized) only once
    lazy var drawer:MMDrawerController = {
        // Configure:
        let mainViewController = MainViewController.instantiate()
        let leftMenuViewController = LeftMenuViewController.instantiate()
        leftMenuViewController.delegate = mainViewController
        let drawerController = MMDrawerController(centerViewController: mainViewController, leftDrawerViewController: leftMenuViewController)
        drawerController.openDrawerGestureModeMask = .All
        drawerController.closeDrawerGestureModeMask = .All
        drawerController.title = "Swift Course"
        return drawerController
    }()

    // MARK: - Lifcycle

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserverForName(Notifications.CloseDrawer, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            guard let strongSelf = self else { return }

            strongSelf.drawer.closeDrawerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Will run only once
        let navigationController = UINavigationController(rootViewController: drawer)
        navigationController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "open", style: .Done, target: self, action: "openLeftMenu")
        presentViewController(navigationController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Other super class methods
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            // Show local UI live debugging tool
            FLEXManager.sharedManager().showExplorer() // Delete if it doesn't exist
        }
    }

    // MARK: - Other super class methods

    private func openLeftMenu () {
        drawer.openDrawerSide(.Left, animated: true, completion: nil)
    }

}