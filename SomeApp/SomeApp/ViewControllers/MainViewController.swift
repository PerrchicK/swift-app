//
//  MainViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import MMDrawerController

class MainViewController: UIViewController, LeftMenuViewControllerDelegate, UITextViewDelegate {
    static let projectLocationInsideGitHub = "https://github.com/PerrchicK/swift-app"

    //lazy var utilsObjC: UtilsObjC = UtilsObjC()
    var drawer: MMDrawerController {
        return navigationController!.viewControllers.first as! MMDrawerController
    }
    
    weak static var shared: MainViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        📘("Segue 👉 \(segue.identifier!)")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        MainViewController.shared = self
        // From: https://stephenradford.me/quick-tip-globally-changing-tint-color-application-wide/
        UIApplication.shared.keyWindow?.tintColor = UIColor.appMainColor

        try? Reachability.shared?.startNotifier()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: InAppNotifications.CloseDrawer), object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            guard let strongSelf = self, strongSelf.drawer.openSide != .none else { return }

            strongSelf.drawer.closeDrawer(animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if drawer.navigationItem.leftBarButtonItem == nil {
            let navigationBarHeight = drawer.navigationController?.navigationBar.frame.height ?? 30
            var hamburgerImage: UIImage? = UIImage(named: "hamburger")// // From: https://stackoverflow.com/questions/25818845/how-do-vector-images-work-in-xcode-i-e-pdf-files/25818846#25818846
            hamburgerImage = hamburgerImage?.resized(toSize: CGSize(width: navigationBarHeight, height: navigationBarHeight))
            let btnMenu = UIBarButtonItem(image: hamburgerImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(onMenuPressed))
            drawer.navigationItem.leftBarButtonItem = btnMenu
        }
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
        //let utilsObjC = UtilsObjC()
        //📘(utilsObjC.supportedDimensions)
        //utilsObjC.alert(withTitle: "presented", andMessage: "some message", in: self)
        
//        PerrFuncs.runBlockAfterDelay(afterDelay: 2) {
//            let img = DataManager.downloadImage(fromUrl: "https://pre00.deviantart.net/6c76/th/pre/f/2017/264/6/9/avengers____infinity_war_by_themadbutcher-dbo60d8.jpg")
//            
//            let imageView: UIImageView = UIImageView()
//            imageView.image = img
//            imageView.contentMode = .scaleAspectFit
//            UIApplication.mostTopViewController()?.view.addSubview(imageView)
//            imageView.stretchToSuperViewEdges()
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: InAppNotifications.CloseDrawer), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Other super class methods

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        📘("didReceiveMemoryWarning!")
    }
    
    @objc func onMenuPressed() {
        if drawer.openSide == .none {
            drawer.open(MMDrawerSide.left, animated: true, completion: nil)
        } else {
            drawer.closeDrawer(animated: true, completion: nil)
        }
    }

    func navigateToNotifications() {
        //(drawer.leftDrawerViewController as? LeftMenuViewController).or
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
    
    func onSelected(menuOption selectedOption: String) { // TODO: Replace `selectedOption` String to an enum / struct / class.
        onMenuOptionSelected(optionSelected: selectedOption)
    }
    
    // MARK: - LeftMenuViewControllerDelegate

    func onMenuOptionSelected(optionSelected selectedOption: String) {
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
        //            navigationController?.pushViewController(gameNavigationController, animated: true) // This will crash
        case LeftMenuOptions.iOS.Data:
            navigationController?.pushViewController(DataViewController.instantiate(), animated: true)
        case LeftMenuOptions.iOS.CommunicationLocation:
            navigationController?.pushViewController(MapLocationAndCommunicationViewController.instantiate(), animated: true)
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

    func leftMenuViewController(_ leftMenuViewController: LeftMenuViewController, selectedOption: String) {
        onSelected(menuOption: selectedOption)
    }

    func onMenuOptionSelected(_ leftMenuViewController: LeftMenuViewController, selectedOption: String) {
        onSelected(menuOption: selectedOption)
    }

    // MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldInteractWith URL: Foundation.URL, in characterRange: NSRange) -> Bool {
        📘("interacting with URL: \(URL)")
        return URL.absoluteString == MainViewController.projectLocationInsideGitHub
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
