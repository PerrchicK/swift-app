//
//  MainViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class MainViewController: UIViewController, LeftMenuViewControllerDelegate, UITextViewDelegate {
    static let projectLocationInsideGitHub = "https://github.com/PerrchicK/swift-app"

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().postNotificationName(InAppNotifications.CloseDrawer, object: nil)
    }

    // MARK: - LeftMenuViewControllerDelegate
    func leftMenuViewController(leftMenuViewController: LeftMenuViewController, selectedOption: String) {
        switch selectedOption {
        case LeftMenuOptions.SwiftStuff.OperatorsOverloading:
            navigationController?.pushViewController(OperatorsViewController.instantiate(), animated: true)
        case LeftMenuOptions.Concurrency.GCD:
            navigationController?.pushViewController(ConcurrencyViewController.instantiate(), animated: true)
        case LeftMenuOptions.UI.Views_Animations:
            navigationController?.pushViewController(AnimationsViewController.instantiate(), animated: true)
        case LeftMenuOptions.UI.CollectionView:
            navigationController?.pushViewController(CollectionContainerViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.Data:
            navigationController?.pushViewController(DataViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.CommunicationLocation:
            navigationController?.pushViewController(CommunicationViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.Notifications:
            navigationController?.pushViewController(NotificationsViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.ImagesCoreMotion:
            navigationController?.presentViewController(ImagesAndMotionViewController.instantiate(), animated: true, completion: nil)
        default:
            UIAlertController.alert(title: "Under contruction 🔨", message: "to be continued... 😉")
            📘("to be continued...")
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        📘("interacting with URL: \(URL)")
        return URL.absoluteString == MainViewController.projectLocationInsideGitHub
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return false
    }
}