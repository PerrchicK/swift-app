//
//  MainViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController, UITextViewDelegate {
    static let projectLocationInsideGitHub = "https://github.com/PerrchicK/swift-app"
//    var reachabilityManager: NetworkReachabilityManager?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        reachabilityManager = reachabilityManager()
//        reachabilityManager?.listener = { [weak self] (status: NetworkReachabilityManager.NetworkReachabilityStatus) -> () in
//            📘("Network reachability status changed: \(status)")
//            switch status {
//            case .NotReachable:
//                self?.navigationController?.navigationBar.barTintColor = UIColor.redColor()
//            case .Reachable(NetworkReachabilityManager.ConnectionType.EthernetOrWiFi): fallthrough
//            case .Reachable(NetworkReachabilityManager.ConnectionType.WWAN):
//                self?.navigationController?.navigationBar.barTintColor = nil
//            default:
//                break
//            }
//        }
//        reachabilityManager?.startListening()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let lastCrashCallStack = UserDefaults.load(key: "last crash") as? [String] {
            UIAlertController.makeAlert(title: "last crash", message: "\(lastCrashCallStack)")
                .withAction(UIAlertAction(title: "fine", style: .cancel, handler: nil))
                .withAction(UIAlertAction(title: "delete", style: .default, handler: { (alertAction) in
                    UserDefaults.remove(key: "last crash").synchronize()
                }))
                .show()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: InAppNotifications.CloseDrawer), object: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: Foundation.URL, in characterRange: NSRange) -> Bool {
        📘("interacting with URL: \(URL)")
        return URL.absoluteString == MainViewController.projectLocationInsideGitHub
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
