//
//  DataViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SyncedUserDefaultsDelegate, UITextFieldDelegate {
    let UserDefaultsStringKey = "MyKeyToSaveObjectInUSerDefaults"
    let UserDefaultsUserKey = "MyKeyToSaveEncodedObjectInUSerDefaults"
    enum TableViewType: String {
        case firebase
        case coreData
    }

    @IBOutlet weak var firebaseStateTableView: UITableView!
    var presentedAlert: UIAlertController?

    @IBOutlet weak var dbStateTableView: UITableView!

    /* Saved in Core Data */
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    /* Saved in Core Data */
    fileprivate var isScreenUp = false

    @IBOutlet weak var userDefaultsTextField: UITextField!

    fileprivate var users:[User]!
    fileprivate var firebaseKeys = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshUsersArray()

        self.dbStateTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellReuseIdentifier")
        self.dbStateTableView.isHidden = true

        userDefaultsTextField.text = UserDefaults.standard.object(forKey: UserDefaultsStringKey) as? String
        self.view.onClick {_ in 
            self.view.endEditing(true)
        }

        dbStateTableView.layer.cornerRadius = 5

        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        nicknameTextField.delegate = self
        emailTextField.delegate = self
        
        if let encodedUser = UserDefaults.standard.object(forKey: UserDefaultsUserKey) as? PersistableUser {
            📘(encodedUser)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(DataViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(DataViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        DataManager.syncedUserDefaults().delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let encodedUser = UserDefaults.standard.object(forKey: UserDefaultsUserKey) as? PersistableUser {
            📘(encodedUser)
        }

        guard (emailTextField.text?.length() ?? 0) > 0 &&
            (firstNameTextField.text?.length() ?? 0) > 0 &&
            (lastNameTextField.text?.length() ?? 0) > 0 &&
            (nicknameTextField.text?.length() ?? 0) > 0 else { return }
        
        //let user = PersistableUser(email: emailTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, nickname: nicknameTextField.text!)
        //NSKeyedArchiver.archivedData(withRootObject: user).
        self.view.endEditing(true)
    }

    @IBAction func showFirebaseButtonPressed(_ sender: AnyObject) {
        if !dbStateTableView.😘(huggedObject: TableViewType.firebase as AnyObject) {
            📘("Failed to attach extra data to table view")
        }
        presentTableView()
    }

    // MARK: - SyncedUserDefaultsDelegate
    func syncedUserDefaults(_ syncedUserDefaults: SyncedUserDefaults, dbKey key: String, dbValue value: String, changed changeType: SyncedUserDefaults.ChangeType) {
        ToastMessage.show(messageText: "data changed:\nchange type: \(changeType)\nkey: \(key)\nvalue: \(value)")
        switch changeType {
        case .added:
            firebaseKeys.append(key)
        case .removed:
            if let idx = firebaseKeys.index(where: { return $0 == key }) {
                firebaseKeys.remove(at: idx)
            }
        default:
            break
        }
    }

    @IBAction func addKeyValueToFirebaseButtonPressed(_ sender: AnyObject) {
        presentedAlert = UIAlertController.makeAlert(title: "Add value to firebase", message: "put key & value")
            .withAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            .withAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] (alertAction) -> Void in
                guard let key = self?.presentedAlert?.textFields?[safe: 0]?.text, let value = self?.presentedAlert?.textFields?[safe: 1]?.text else { return }

                DataManager.syncedUserDefaults().putString(key: key, value: value)
            }))
            .withInputText(configurationBlock: { (textField) in
                textField.placeholder = "key"
                textField.textAlignment = .center
                textField.😘(huggedObject: TableViewType.firebase)
            })
            .withInputText(configurationBlock: { (textField) in
                textField.placeholder = "value"
                textField.textAlignment = .center
                textField.😘(huggedObject: TableViewType.coreData)
            })
            .show()
    }
    
    @IBAction func showCoreDataButtonPressed(_ sender: AnyObject) {
        if !dbStateTableView.😘(huggedObject: TableViewType.coreData) {
            📘("Failed to attach extra data to table view")
        }
        presentTableView()
    }

    func presentTableView() {
        let bgView = UIView(frame: UIScreen.main.bounds)
        bgView.alpha = 0.0
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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

    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        guard (emailTextField.text?.length() ?? 0) > 0 &&
            (firstNameTextField.text?.length() ?? 0) > 0 &&
            (lastNameTextField.text?.length() ?? 0) > 0 &&
            (nicknameTextField.text?.length() ?? 0) > 0 else { return }

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

    @IBAction func synchronizeButtonPressed(_ sender: AnyObject) {
        UserDefaults.standard.set(userDefaultsTextField.text, forKey: UserDefaultsStringKey)
        UserDefaults.standard.synchronize()
    }

    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, presentedAlert == nil else { return }

        if /*let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,*/
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            let keyboardSize = keyboardFrame.size
            self.view.frame.origin.y = -keyboardSize.height
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellReuseIdentifier", for: indexPath)

        let index = indexPath.row
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                cell.textLabel?.text = firebaseKeys[index]
            case TableViewType.coreData:
                cell.textLabel?.text = users[index].nickname
            }
        }
        
        cell.onLongPress({ [weak self] (longPressGestureRecognizer) in
            self?.tableView(tableView, didLongTapOnRowAtIndex: index)
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                return DataManager.syncedUserDefaults().currentDictionary.count
            case TableViewType.coreData:
                return users.count
            }
        }

        return 0
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        var toastMessage = ""
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                if let key = tableView.cellForRow(at: indexPath)?.textLabel?.text,
                    let value = DataManager.syncedUserDefaults().currentDictionary[key] {
                    toastMessage = value
                }
            case TableViewType.coreData:
                toastMessage = users[selectedIndex].description //users[selectedIndex].firstName + " " + users[selectedIndex].lastName
            }
        }

        ToastMessage.show(messageText: toastMessage)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didLongTapOnRowAtIndex longTappedIndex: Int) {
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                let key = firebaseKeys[longTappedIndex]
                presentedAlert = UIAlertController.makeAlert(title: "Edit '\(key)'", message: "enter a new string:")
                    .withInputText(configurationBlock: { (textField) in
                        textField.placeholder = "new value"
                        textField.text = SyncedUserDefaults.sharedInstance.currentDictionary[key]
                        textField.😘(huggedObject: tableViewType)
                    }).withAction(UIAlertAction(title: "Change", style: .destructive, handler: { [weak self] (alertAction) in
                        guard let newValue = self?.presentedAlert?.textFields?.first?.text else { return }
                        SyncedUserDefaults.sharedInstance.putString(key: key, value: newValue)
                        self?.refreshUsersArray()
                        tableView.reloadData()
                    }))
                    .withAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    .show()
            case TableViewType.coreData:
                let modifiedUser = self.users[longTappedIndex]
                presentedAlert = UIAlertController.makeAlert(title: "Edit '\(modifiedUser.nickname ?? "")'", message: "enter a new nickname:")
                    .withInputText(configurationBlock: { (textField) in
                        textField.placeholder = "nickname"
                        textField.😘(huggedObject: tableViewType)
                    }).withAction(UIAlertAction(title: "Change", style: .destructive, handler: { [weak self] (alertAction) in
                        modifiedUser.nickname = self?.presentedAlert?.textFields?.first?.text
                        modifiedUser.save()
                        self?.refreshUsersArray()
                        tableView.reloadData()
                    }))
                    .withAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    .show()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                if let key = tableView.cellForRow(at: indexPath)?.textLabel?.text {
                    DataManager.syncedUserDefaults().removeString(key: key)
                    firebaseKeys.remove(where: { return $0 == key })
                }
            case TableViewType.coreData:
                let selectedUser = users[indexPath.row]
                let selectedUserName = selectedUser.firstName
                
                if selectedUser.remove() && selectedUser.save() {
                    ToastMessage.show(messageText: "Deleted \(String(describing: selectedUserName))")
                }
                
                refreshUsersArray()
            }
        }

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        tableView.endUpdates()
    }

    func refreshUsersArray() {
        users = DataManager.fetchUsers()
    }
}

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard count > index else {return nil }
        return self[index]
    }

    @discardableResult
    mutating func remove(where predicate: (Array.Iterator.Element) throws -> Bool) -> Element? {
        if let indexToRemove = try? self.index(where: predicate), let _indexToRemove = indexToRemove {
            return self.remove(at: _indexToRemove)
        }

        return nil
    }
}
