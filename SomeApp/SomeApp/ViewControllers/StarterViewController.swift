//
//  StarterViewController.swift
//  SomeApp
//
//  Created by Perry on 1/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import MMDrawerController

class StarterViewController: UIViewController {

    // Will run only once in this app
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Configure:
        let mainViewController = MainViewController.instantiate()
        let leftMenuViewController = LeftMenuViewController.instantiate()
        leftMenuViewController.delegate = mainViewController
        let leftMenuViewNavigationController: UINavigationController = UINavigationController(rootViewController: leftMenuViewController)
        leftMenuViewNavigationController.isNavigationBarHidden = true
        let drawerController = MMDrawerController(center: mainViewController, leftDrawerViewController: leftMenuViewNavigationController)!
        drawerController.openDrawerGestureModeMask = .all
        drawerController.closeDrawerGestureModeMask = .all
        drawerController.title = "Swift Course".localized()

        let drawerNavigationController = UINavigationController(rootViewController: drawerController)
        drawerNavigationController.modalTransitionStyle = .crossDissolve

        let shouldBeTheLabel = view.subviews.filter( { $0 is UILabel } ).first // Because it's the label
        shouldBeTheLabel?.animateFade(fadeIn: false, duration: 0.3, completion: { _ in
            UIApplication.shared.keyWindow?.rootViewController = drawerNavigationController
        })
    }
}
