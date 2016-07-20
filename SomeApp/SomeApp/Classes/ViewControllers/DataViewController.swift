//
//  DataViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SyncedUserDefaultsDelegate, UITextFieldDelegate {
    let UserDefaultsKey = "MyKeyToSaveObjectInNSUSerDefaults"

    @IBOutlet weak var firebaseStateTableView: UITableView!
    var firebaseKeyTextField = UITextField() // Had to allocate an instance so this could be passed by reference
    var firebaseValueTextField = UITextField()
    var coreDataNewNicknameTextField = UITextField()

    @IBOutlet weak var dbStateTableView: UITableView!

    /* Saved in Core Data */
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    /* Saved in Core Data */
    private var isScreenUp = false

    @IBOutlet weak var userDefaultsTextField: UITextField!

    private var users:[User]!
    private var firebaseKeys = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshUsersArray()

        self.dbStateTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellReuseIdentifier")
        self.dbStateTableView.hidden = true

        userDefaultsTextField.text = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKey) as? String
        self.view.onClick {_ in 
            self.view.endEditing(true)
        }

        dbStateTableView.layer.cornerRadius = 5

        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        nicknameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(DataViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(DataViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        DataManager.syncedUserDefaults().delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.view.endEditing(true)
    }

    @IBAction func showFirebaseButtonPressed(sender: AnyObject) {
        do {
            try dbStateTableView.😘(belovedObject: "firebase")
        } catch {
            📘("Failed to attach extra data to table view")
        }
        presentTableView()
    }

    // MARK: - SyncedUserDefaultsDelegate
    func syncedUserDefaults(syncedUserDefaults: SyncedUserDefaults, dbKey key: String, dbValue value: String, changed changeType: SyncedUserDefaults.ChangeType) {
        ToastMessage.show(messageText: "data changed:\nchange type: \(changeType)\nkey: \(key)\nvalue: \(value)")
        switch changeType {
        case .Added:
            firebaseKeys.append(key)
        case .Removed:
            if let idx = firebaseKeys.indexOf({ return $0 == key }) {
                firebaseKeys.removeAtIndex(idx)
            }
        default:
            break
        }
    }

    @IBAction func addKeyValueToFirebaseButtonPressed(sender: AnyObject) {
        UIAlertController.makeAlert(title: "Add value to firebase", message: "put key & value")
            .withAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            .withAction(UIAlertAction(title: "Add", style: .Default, handler: { [weak self] (alertAction) -> Void in
                guard let firebaseKeyTextField = self?.firebaseKeyTextField, firebaseValueTextField = self?.firebaseValueTextField,
                let key = firebaseKeyTextField.text, value = firebaseValueTextField.text else { return }

                DataManager.syncedUserDefaults().putString(key: key, value: value)
            }))
            .withInputText(&firebaseKeyTextField, configurationBlock: { (textField) in
                textField.placeholder = "key"
                textField.textAlignment = .Center
            })
            .withInputText(&firebaseValueTextField, configurationBlock: { (textField) in
                textField.placeholder = "value"
                textField.textAlignment = .Center
            })
            .show()
    }
    
    @IBAction func showCoreDataButtonPressed(sender: AnyObject) {
        do {
            try dbStateTableView.😘(belovedObject: "core-data")
        } catch {
            📘("Failed to attach extra data to table view")
        }
        presentTableView()
    }

    func presentTableView() {
        let bgView = UIView(frame: UIScreen.mainScreen().bounds)
        bgView.alpha = 0.0
        bgView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        dbStateTableView.superview?.insertSubview(bgView, belowSubview: dbStateTableView)
        dbStateTableView.reloadData()
        bgView.stretchToSuperViewEdges()
        
        let prettyFast = 0.3
        bgView.animateFade(fadeIn: true, duration: prettyFast)
        dbStateTableView.animateFade(fadeIn: true, duration: prettyFast)
        bgView.onClick { [weak self] (tapGestureRecognizer) -> () in
            bgView.animateFade(fadeIn: false, duration: prettyFast, completion: { (done) -> Void in
                bgView.removeFromSuperview()
            })
            self?.dbStateTableView.animateFade(fadeIn: false, duration: prettyFast)
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
        view.endEditing(true)

        refreshUsersArray()
        dbStateTableView.reloadData()
    }

    @IBAction func synchronizeButtonPressed(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(userDefaultsTextField.text, forKey: UserDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let firstResponder = view.firstResponder()
            where firstResponder != userDefaultsTextField &&
            firstResponder != firebaseKeyTextField else { return }

        if /*let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,*/
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.CGRectValue()
            let keyboardSize = keyboardFrame.size
            self.view.frame.origin.y = -keyboardSize.height
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellReuseIdentifier", forIndexPath: indexPath)

        let index = indexPath.row
        if let belovedString = tableView.😍() as? String {
            switch belovedString {
            case "firebase":
                cell.textLabel?.text = firebaseKeys[index]
            case "core-data":
                cell.textLabel?.text = users[index].nickname
            default:
                break
            }
        }
        
        cell.onLongPress({ [weak self] (longPressGestureRecognizer) in
            self?.tableView(tableView, didLongTapOnRowAtIndex: index)
        })
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let belovedString = tableView.😍() as? String {
            switch belovedString {
            case "firebase":
                return DataManager.syncedUserDefaults().currentDictionary.count
            case "core-data":
                return users.count
            default:
                break
            }
        }

        return 0
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView(tableView, didTapOnRowAtIndex: indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, didTapOnRowAtIndex tappedIndex: Int) {
        var toastMessage = ""
        if let belovedString = tableView.😍() as? String {
            switch belovedString {
            case "firebase":
                if let key = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tappedIndex, inSection: 0))?.textLabel?.text,
                    let value = DataManager.syncedUserDefaults().currentDictionary[key] {
                    toastMessage = value
                }
            case "core-data":
                toastMessage = users[tappedIndex].firstName + " " + users[tappedIndex].lastName
            default:
                break
            }
        }

        ToastMessage.show(messageText: toastMessage)
    }
    
    func tableView(tableView: UITableView, didLongTapOnRowAtIndex longTappedIndex: Int) {
        if let belovedString = tableView.😍() as? String {
            switch belovedString {
            case "firebase":
                let key = firebaseKeys[longTappedIndex]
                UIAlertController.makeAlert(title: "Edit '\(key)'", message: "enter a new string:")
                    .withInputText(&firebaseValueTextField) { (textField) in
                        textField.placeholder = "new value"
                        textField.text = SyncedUserDefaults.sharedInstance.currentDictionary[key]
                    }.withAction(UIAlertAction(title: "Change", style: .Destructive, handler: { [weak self] (alertAction) in
                        guard let newValue = self?.firebaseValueTextField.text else { return }
                        SyncedUserDefaults.sharedInstance.putString(key: key, value: newValue)
                        self?.refreshUsersArray()
                        tableView.reloadData()
                    }))
                    .withAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    .show()
            case "core-data":
                let modifiedUser = self.users[longTappedIndex]
                UIAlertController.makeAlert(title: "Edit '\(modifiedUser.nickname)'", message: "enter a new nickname:")
                    .withInputText(&coreDataNewNicknameTextField) { (textField) in
                        textField.placeholder = "nickname"
                    }.withAction(UIAlertAction(title: "Change", style: .Destructive, handler: { (alertAction) in
                        modifiedUser.nickname = self.coreDataNewNicknameTextField.text
                        modifiedUser.save()
                        self.refreshUsersArray()
                        tableView.reloadData()
                    }))
                    .withAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    .show()
            default:
                break
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if let belovedString = tableView.😍() as? String {
            switch belovedString {
            case "firebase":
                if let key = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text {
                    DataManager.syncedUserDefaults().removeString(key: key)
                }
            case "core-data":
                let selectedUser = users[indexPath.row]
                let selectedUserName = selectedUser.firstName
                
                if selectedUser.remove() && selectedUser.save() {
                    ToastMessage.show(messageText: "Deleted \(selectedUserName)")
                }
                
                refreshUsersArray()
            default:
                break
            }
        }

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        tableView.endUpdates()
    }

    func refreshUsersArray() {
        users = DataManager.fetchUsers()
    }
}