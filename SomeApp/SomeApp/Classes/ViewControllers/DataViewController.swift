//
//  DataViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SyncedUserDefaultsDelegate {
    let UserDefaultsKey = "MyKeyToSaveObjectInNSUSerDefaults"

    @IBOutlet weak var firebaseStateTableView: UITableView!
    var firebaseKeyTextField = UITextField() // Had to allocate an instance so this could be passed by reference
    var firebaseValueTextField = UITextField()

    @IBOutlet weak var dbStateTableView: UITableView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var distanceFromBottomConstraint: NSLayoutConstraint!
    var originalDistanceFromBottomConstraint: CGFloat! = 0

    @IBOutlet weak var userDefaultsTextField: UITextField!

    var keyboardObserver: NSObjectProtocol?
    var users:[User]!

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshUsersArray()

        self.dbStateTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellReuseIdentifier")
        self.dbStateTableView.hidden = true

        originalDistanceFromBottomConstraint = distanceFromBottomConstraint.constant
        userDefaultsTextField.text = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKey) as? String
        self.view.onClick {
            self.view.firstResponder()?.resignFirstResponder()
        }

        dbStateTableView.layer.cornerRadius = 5
        dbStateTableView.bounces = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        runBlockAfterDelay(afterDelay: 3.0) {
            self.keyboardObserver = nil
        }

        DataManager.syncedUserDefaults().delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver = nil

    }

    @IBAction func showFirebaseButtonPressed(sender: AnyObject) {
        ToastMessage.show(messageText: "comming soon...")
    }

    // MARK: - SyncedUserDefaultsDelegate
    func syncedUserDefaults(syncedUserDefaults: SyncedUserDefaults, dbKey key: String, dbValue value: String, changed changeType: SyncedUserDefaults.ChangeType) {
        ToastMessage.show(messageText: "data changed:\nchange type: \(changeType)\nkey: \(key)\nvalue: \(value)")
    }

    @IBAction func addKeyValueToFirebaseButtonPressed(sender: AnyObject) {
        UIAlertController.make(title: "Add value to firebase", message: "put key & value")
            .withAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            .withAction(UIAlertAction(title: "Add", style: .Default, handler: { [weak self] (alertAction) -> Void in
                guard let firebaseKeyTextField = self?.firebaseKeyTextField, firebaseValueTextField = self?.firebaseValueTextField,
                let key = firebaseKeyTextField.text, value = firebaseValueTextField.text else { return }

                DataManager.syncedUserDefaults().putString(key, value: value)
            }))
            .withInputText(&firebaseKeyTextField).withInputText(&firebaseValueTextField)
            .show()
    }
    
    @IBAction func showDbButtonPressed(sender: AnyObject) {
        refreshUsersArray()

        let bgView = UIView(frame: UIScreen.mainScreen().bounds)
        bgView.alpha = 0.0
        bgView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        dbStateTableView.superview?.insertSubview(bgView, belowSubview: dbStateTableView)
        bgView.stretchToSuperViewEdges()

        let prettyFast = 0.3
        bgView.animateFade(fadeIn: true, duration: prettyFast)
        dbStateTableView.animateFade(fadeIn: true, duration: prettyFast)
        bgView.onClick { () -> () in
            bgView.animateFade(fadeIn: false, duration: prettyFast, completion: { (done) -> Void in
                bgView.removeFromSuperview()
            })
            self.dbStateTableView.animateFade(fadeIn: false, duration: prettyFast)
        }
    }

    @IBAction func saveButtonPressed(sender: AnyObject) {
        guard emailTextField.text?.length() > 0 &&
            firstNameTextField.text?.length() > 0 &&
            lastNameTextField.text?.length() > 0 &&
            nicknameTextField.text?.length() > 0 else { return }

        let user = DataManager.createUser()

        user.firstName = firstNameTextField.text
        user.lastName = lastNameTextField.text
        user.nickname = nicknameTextField.text
        user.email = emailTextField.text

        ToastMessage.show(messageText: "Managed object (User \(user.nickname)) \(user.save() ? "saved" : "failed to be saved") in Core Data.")

        firstNameTextField.text = ""
        lastNameTextField.text = ""
        nicknameTextField.text = ""
        emailTextField.text = ""
        view.firstResponder()?.resignFirstResponder()

        refreshUsersArray()
        dbStateTableView.reloadData()
    }

    @IBAction func synchronizeButtonPressed(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(userDefaultsTextField.text, forKey: UserDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo where view.firstResponder() != userDefaultsTextField else { return }

        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval, let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardSize:CGSize = keyboardFrame.CGRectValue().size
            self.distanceFromBottomConstraint.constant = self.originalDistanceFromBottomConstraint + keyboardSize.height
            UIView.animateWithDuration(duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval {
            self.distanceFromBottomConstraint.constant = self.originalDistanceFromBottomConstraint
            UIView.animateWithDuration(duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellReuseIdentifier", forIndexPath: indexPath)

        cell.textLabel?.text = users[indexPath.row].nickname
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let selectedUser = users[indexPath.row]
        let selectedUserName = selectedUser.firstName

        if selectedUser.remove() && selectedUser.save() {
            ToastMessage.show(messageText: "Deleted \(selectedUserName)")
        }

        refreshUsersArray()

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        tableView.endUpdates()
    }

    func refreshUsersArray() {
        users = DataManager.fetchUsers()
    }
}