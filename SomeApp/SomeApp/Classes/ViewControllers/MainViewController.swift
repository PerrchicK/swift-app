//
//  MainViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class MainViewController: UIViewController, LeftMenuViewControllerDelegate {
    func leftMenuViewController(leftMenuViewController: LeftMenuViewController, selectedOption: String) {
        switch selectedOption {
        case LeftMenuOptions.UI.Animations:
            navigationController?.pushViewController(AnimationsViewController.instantiate(), animated: true)
        case LeftMenuOptions.SwiftStuff.OperatorsOverloading:
            navigationController?.pushViewController(OperatorsViewController.instantiate(), animated: true)
        default:
            UIAlertController.alert(title: "Under contruction 🔨", message: "to be continued... 😉")
            print("to be continued...")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CloseDrawer, object: nil)
    }
}