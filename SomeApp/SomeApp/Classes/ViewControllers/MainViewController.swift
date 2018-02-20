//
//  MainViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController, LeftMenuViewControllerDelegate, UITextViewDelegate {
    static let projectLocationInsideGitHub = "https://github.com/PerrchicK/swift-app"

    //lazy var utilsObjC: UtilsObjC = UtilsObjC()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        try? Reachability.shared?.startNotifier()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let lastCrashCallStack: [String] = UserDefaults.load(key: "last crash") {
            UIAlertController.makeAlert(title: "last crash", message: "\(lastCrashCallStack)")
            .withAction(UIAlertAction(title: "fine", style: .cancel, handler: nil))
            .withAction(UIAlertAction(title: "delete", style: .destructive, handler: { (alertAction) in
                UserDefaults.remove(key: "last crash").synchronize()
            }))
            .show()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange), name: Notification.Name.ReachabilityDidChange, object: nil)

        // Just for Objective-C demonstrations
        let utilsObjC = UtilsObjC()
        //📘(utilsObjC.supportedDimensions)
        //utilsObjC.alert(withTitle: "presented", andMessage: "some message", in: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: InAppNotifications.CloseDrawer), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    @objc func reachabilityDidChange(notification: Notification) {
        guard let status = Reachability.shared?.currentReachabilityStatus else { return }
        📘("Network reachability status changed: \(status)")

        switch status {
        case .notReachable:
            navigationController?.navigationBar.barTintColor = UIColor.red
        case .reachableViaWiFi: fallthrough
        case .reachableViaWWAN:
            navigationController?.navigationBar.barTintColor = nil
        }
    }

    // MARK: - LeftMenuViewControllerDelegate
    func leftMenuViewController(_ leftMenuViewController: LeftMenuViewController, selectedOption: String) {
        switch selectedOption {
        case LeftMenuOptions.SwiftStuff.OperatorsOverloading:
            navigationController?.pushViewController(OperatorsViewController.instantiate(), animated: true)
        case LeftMenuOptions.Concurrency.GCD:
            navigationController?.pushViewController(ConcurrencyViewController.instantiate(), animated: true)
        case LeftMenuOptions.UI.Views_Animations:
            navigationController?.pushViewController(AnimationsViewController.instantiate(), animated: true)
        case LeftMenuOptions.UI.CollectionView:
            let gameNavigationController = GameNavigationController(rootViewController: CollectionViewController.instantiate())
            gameNavigationController.isNavigationBarHidden = true
            navigationController?.present(gameNavigationController, animated: true, completion: nil)
        case LeftMenuOptions.iOS.Data:
            navigationController?.pushViewController(DataViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.CommunicationLocation:
            navigationController?.pushViewController(CommunicationMapLocationViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.Notifications:
            navigationController?.pushViewController(NotificationsViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.ImagesCoreMotion:
            navigationController?.present(ImagesAndMotionViewController.instantiate(), animated: true, completion: nil)
//        case LeftMenuOptions.PersonalDevelopment.CrazyWhack:
//            navigationController?.present(CrazyWhackViewController(), animated: true, completion: nil)
        default:
            UIAlertController.alert(title: "Under contruction 🔨", message: "to be continued... 😉")
            📘("to be continued...")
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: Foundation.URL, in characterRange: NSRange) -> Bool {
        📘("interacting with URL: \(URL)")
        return URL.absoluteString == MainViewController.projectLocationInsideGitHub
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
