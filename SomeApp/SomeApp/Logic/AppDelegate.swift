//
//  AppDelegate.swift
//  SomeApp
//
//  Created by Perry on 1/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseMessaging
import UserNotifications

enum ShortcutItemType: String {
    case OpenImageExamples
    case OpenMultiTaskingExamples
    case OpenMapExamples
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var signInHolder: Synchronizer.Holder?
    var tokenHolder: Synchronizer.Holder?

    var loggedInUser: User?
    private(set) var fcmToken: String? {
        didSet {
            self.tokenHolder?.release()
        }
    }
    var window: UIWindow?
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let loggedInTokenSynchronizer: Synchronizer = Synchronizer(finalOperationClosure: { [weak self] in
            guard let user = self?.loggedInUser else { return }
            FirebaseHelper.createUserNode(user: user)
        })

        tokenHolder = loggedInTokenSynchronizer.createHolder()
        signInHolder = loggedInTokenSynchronizer.createHolder()

//        FirebaseHelper.loggedInUser { [weak self] (user) in
//            self?.loggedInUser = user
//            self?.signInHolder?.release()
//        }

        if let deepLinkDictionary = launchOptions {
            📘("launch options dictionary: \(deepLinkDictionary)")
            
            if let deepLinkDictionaryFromUrl = deepLinkDictionary[UIApplicationLaunchOptionsKey.url] as? URL {
                handleDeepLink(deeplinkUrl: deepLinkDictionaryFromUrl)
            }

            if let deepLinkDictionaryFromLocalNotification = deepLinkDictionary[UIApplicationLaunchOptionsKey.localNotification] {
                📘("Local notification params: \(deepLinkDictionaryFromLocalNotification)")
            }

            if let deepLinkDictionaryFromRemoteNotification = deepLinkDictionary[UIApplicationLaunchOptionsKey.remoteNotification] {
                📘("Remote notification params: \(deepLinkDictionaryFromRemoteNotification)")
            }
        }

        let rootViewController = SplashScreenViewController.instantiate()
        self.window?.rootViewController = rootViewController

        CrashOps.shared().previousCrashReports = { reports in
            📘(reports)
        }

//        NSSetUncaughtExceptionHandler { (exception) in
//            UserDefaults.save(value: exception.callStackSymbols, forKey: "last crash").synchronize()
//        }

        CrashOps.shared().appExceptionHandler = { exception in
            UserDefaults.save(value: exception.callStackSymbols, forKey: "last crash").synchronize()
        }

        // Another (programmatic) way to determine the window
        //        window = UIWindow(frame: UIScreen.main.bounds)
        //        window?.rootViewController = UINavigationController(rootViewController: _)
        //        window?.makeKeyAndVisible()

        return true
    }

    @discardableResult
    func handleDeepLink(deeplinkUrl: URL) -> Bool {
        📘("Deep Link URL: \(deeplinkUrl)")
        return true
    }

    func setupNotifications() {
        setupNotifications(application: UIApplication.shared)
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        📘(shortcutItem.type)
        ToastMessage.show(messageText: "3D Touched! User chose quick action: \(shortcutItem.localizedTitle)")
        guard let shortcutItemType = ShortcutItemType.init(rawValue: shortcutItem.type) else { 📘("Error: Failed to instatiate ShortcutItemType enum from: '\(shortcutItem.type)'"); return }
        switch shortcutItemType {
        case .OpenImageExamples:
            MainViewController.shared?.onSelected(menuOption: LeftMenuOptions.iOS.ImagesCoreMotion)
        case .OpenMultiTaskingExamples:
            MainViewController.shared?.onSelected(menuOption: LeftMenuOptions.Concurrency.GCD)
        case .OpenMapExamples:
            MainViewController.shared?.onSelected(menuOption: LeftMenuOptions.iOS.CommunicationLocation)
        default:
            📘("Error: Unhandled shortcut item type: \(shortcutItemType.rawValue)")
        }
        completionHandler(true)
    }

    private func setupNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if  let title = notification.alertTitle,
            let message = notification.alertBody, application.applicationState == .active {
                UIAlertController.makeAlert(title: title, message: message).withAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)).show()
        }
        📘("Received a local notification: \(notification)")
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        📘("Registered: \(notificationSettings)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        📘("Received a remote notification: \(userInfo)")
        completionHandler(.noData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        📘("FCM (refreshed) token string: \(fcmToken)")
        self.fcmToken = fcmToken
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        // Sets the notification as "acknowledged"
        Messaging.messaging().appDidReceiveMessage(remoteMessage.appData)
        📘("Received a FCM notification: \(remoteMessage.appData)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        📘("Received a remote notification: \(userInfo)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let apnsTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        
        📘("APNs token string: \(apnsTokenString.uppercased())")

        //InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
        Messaging.messaging().apnsToken = deviceToken

        if let fcmToken = Messaging.messaging().fcmToken {
            📘("FCM token string: \(fcmToken)")
            self.fcmToken = fcmToken
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        📘(error)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return handleDeepLink(deeplinkUrl: url)
    }

    // MARK: - Core Data stack

    // Lazy instantiation variable - will be allocated (and initialized) only once
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.perrchick.SomeApp" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "SomeApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            // Report any error we got.
            let wrappedError = NSError.create(errorDomain: "YOUR_ERROR_DOMAIN", errorCode: 9999, description: "Failed to initialize the application's saved data", failureReason: "There was an error creating or loading the application's saved data.", underlyingError: error)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator: NSPersistentStoreCoordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

@available(iOS 10.0, *)
extension AppDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

    // User did tap on notification... hallelujah, thank you iOS10!
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let notificationAddress = userInfo["address"] as? String, notificationAddress == "/main/notifications" {
            //MainViewController?.shared?.navigateToNotifications()
        }
        completionHandler()
    }
}

extension UIWindow { // Solution from: https://stackoverflow.com/questions/39518529/motionbeganwithevent-not-called-in-appdelegate-in-ios-10
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Show local UI live debugging tool
            FLEXManager.shared().showExplorer() // Delete if it doesn't exist
        }
    }
}
