//
//  StarterViewController.swift
//  SomeApp
//
//  Created by Perry on 1/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import FLEX
import MMDrawerController

class StarterViewController: UIViewController {

    // Lazy instantiation variable - will be allocated (and initialized) only once
    lazy var drawer:MMDrawerController = {
        // Configure:
        let mainViewController = MainViewController.instantiate()
        let leftMenuViewController = LeftMenuViewController.instantiate()
        leftMenuViewController.delegate = mainViewController
        let leftMenuViewNavigationController: UINavigationController = UINavigationController(rootViewController: leftMenuViewController)
        leftMenuViewNavigationController.isNavigationBarHidden = true
        let drawerController = MMDrawerController(center: mainViewController, leftDrawerViewController: leftMenuViewNavigationController)
        drawerController?.openDrawerGestureModeMask = .all
        drawerController?.closeDrawerGestureModeMask = .all
        drawerController?.title = "Swift Course"

        return drawerController!
    }()

    // MARK: - Lifcycle

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: InAppNotifications.CloseDrawer), object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            guard let strongSelf = self else { return }

            strongSelf.drawer.closeDrawer(animated: true, completion: nil)
        }

        //📘(" ... ")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //📘(" ... ")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Will run only once
        let navigationController = UINavigationController(rootViewController: drawer)
        navigationController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "open", style: .done, target: self, action: #selector(openLeftMenu))
        present(navigationController, animated: true, completion: nil)

        //📘(" ... ")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        📘("didReceiveMemoryWarning!")
    }
    
    // MARK: - Other super class methods
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Show local UI live debugging tool
            FLEXManager.shared().showExplorer() // Delete if it doesn't exist
        }
    }

    // MARK: - Other super class methods

    @objc func openLeftMenu () {
        drawer.open(.left, animated: true, completion: nil)
    }
}
