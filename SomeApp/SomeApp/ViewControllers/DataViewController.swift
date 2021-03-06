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
    let PersistableUserFileName = "PersistableUserFileName"
    enum TableViewType: String {
        case firebase
        case coreData
    }

    private var presentedAlert: UIAlertController?

    lazy var dbStateTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)

        tableView.stretchToSuperViewEdges(UIEdgeInsets(top: navigationBarHeight + 40, left: 20, bottom: -20, right: -20))

        tableView.isPresented = false
        return tableView
    }()

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var btnSave: UIButton!

    /* Saved in Core Data */
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    /* Saved in Core Data */

    @IBOutlet weak var userDefaultsTextField: UITextField!

    fileprivate var users:[SomeApp.AppUser]!
    fileprivate lazy var syncedUserDefaults: SyncedUserDefaults = DataManager.generateSyncedUserDefaults()

    fileprivate lazy var firebaseKeys: [String] = {
        return []
    }()

    lazy var navigationBarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 0 + 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshUsersArray()

        self.dbStateTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellReuseIdentifier")
        self.dbStateTableView.isHidden = true
        scrollView.keyboardDismissMode = .interactive

//        let contentInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.alwaysBounceVertical = true

        userDefaultsTextField.text = UserDefaults.standard.object(forKey: UserDefaultsStringKey) as? String
        view.onClick { [weak self] _ in
            self?.view.endEditing(true)
        }

        dbStateTableView.layer.cornerRadius = 5

        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        nicknameTextField.delegate = self
        emailTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let encodedUserFilePath = URL(fileURLWithPath: DataManager.applicationLibraryPath.appendingPathComponent(PersistableUserFileName))
        do {
            let encodedUserData = try Data(contentsOf: encodedUserFilePath)
            if let encodedUsers = NSKeyedUnarchiver.unarchiveObject(with: encodedUserData) as? [PersistableUser] {
                📘(encodedUsers)
            } else {
                📘("Failed to create user object from data object")
            }
        } catch {
            📘("Failed to load user data from file, error: \(error)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(DataViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(DataViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        syncedUserDefaults.delegate = self
        
        if let persistableUsersData = UserDefaults.standard.object(forKey: PerrFuncs.className(PersistableUser.self)) as? Data,
            let persistableUsers = NSKeyedUnarchiver.unarchiveObject(with: persistableUsersData) as? [PersistableUser] {
            📘(persistableUsers)
        }
        
        if !(FirebaseHelper.isActivated ?? false) {
            ToastMessage.show(messageText: "Firebase is not integrated")
        }

        //UserDefaults.saveForever(value: "cool forever", forKey: "Perry")
        let valueFromKeychain = UserDefaults.loadFromEternity(fromKey: "Perry") ?? "<empty>"
        
        //localStorage["Perry"] = "cool for a lifetime"
        let valueFromUserDefaults: String = localStorage["Perry"] ?? "<empty>"
        
        📘("valueFromKeychain == \(valueFromKeychain)")
        📘("valueFromUserDefaults == \(valueFromUserDefaults)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard (emailTextField.text?.length()).or(0) > 0 &&
            (firstNameTextField.text?.length()).or(0) > 0 &&
            (lastNameTextField.text?.length() ?? 0) > 0 &&
            (nicknameTextField.text?.length() ?? 0) > 0 else { return }
        
        let user1 = PersistableUser(email: "1", firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, nickname: nicknameTextField.text!)
        let user2 = PersistableUser(email: "2", firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, nickname: nicknameTextField.text!)

        let encodedUserFilePath = URL(fileURLWithPath: DataManager.applicationLibraryPath.appendingPathComponent(PersistableUserFileName))

        let usersData = NSKeyedArchiver.archivedData(withRootObject: [user1, user2])
        try? usersData.write(to: encodedUserFilePath)

        self.view.endEditing(true)
        
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func showFirebaseButtonPressed(_ sender: AnyObject) {
        dbStateTableView.😘(huggedObject: TableViewType.firebase)
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

                self?.syncedUserDefaults.putString(key: key, value: value)
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
        dbStateTableView.😘(huggedObject: TableViewType.coreData)
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

        ToastMessage.show(messageText: "Managed object (User \(user)) \(user.save() ? "saved" : "failed to be saved") in Core Data.")

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

        let user1 = PersistableUser(email: "user1@from.defaults", firstName: "from", lastName: "defaults", nickname: "defaulty1")
        let user2 = PersistableUser(email: "user2@from.defaults", firstName: "from", lastName: "defaults", nickname: "defaulty2")
        let usersData = NSKeyedArchiver.archivedData(withRootObject: [user1, user2])
        UserDefaults.standard.set(usersData, forKey: PerrFuncs.className(PersistableUser.self))
        UserDefaults.standard.synchronize()
    }

    // https://stackoverflow.com/questions/1983463/whats-the-uiscrollview-contentinset-property-for
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, presentedAlert == nil else { return }

        if /*let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,*/
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            let keyboardSize = keyboardFrame.size

            let screenLeftOver = UIScreen.main.bounds.height - keyboardSize.height
            let diff = screenLeftOver - (btnSave.frame.origin.y + btnSave.frame.height)
            if diff < 0 {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame = self.view.frame.withY(y: diff)
                }
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let windowFrame = self.view.window?.frame else { return }

        if /*let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,*/
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            let keyboardSize = keyboardFrame.size
        }
        
//        scrollView.contentInset = UIEdgeInsets(top: navigationBarHeight + 40, left: 0, bottom: 0, right: 0)
//        scrollView.scrollIndicatorInsets = scrollView.contentInset
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.frame = self.view.frame.withY(y: 0)
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellReuseIdentifier", for: indexPath)

        let index = indexPath.row
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                cell.textLabel?.text = firebaseKeys[safe: index]
            case TableViewType.coreData:
                cell.textLabel?.text = users[index].nickname
            }
        }
        
        cell.onLongPress({ [weak self] (longPressGestureRecognizer) in
            if longPressGestureRecognizer.state == .began {
                self?.tableView(tableView, didLongTapOnRowAtIndex: index)
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                return syncedUserDefaults.currentDictionary.count
            case TableViewType.coreData:
                return users.count
            }
        }

        return 0
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        if let tableViewType = tableView.😍() as? TableViewType {
            var toastMessage: String = ""
            switch tableViewType {
            case TableViewType.firebase:
                if let key = tableView.cellForRow(at: indexPath)?.textLabel?.text,
                    let value = syncedUserDefaults.currentDictionary[key] {
                    toastMessage = value
                }
            case TableViewType.coreData:
                toastMessage = users[selectedIndex].description //users[selectedIndex].firstName + " " + users[selectedIndex].lastName
            }
            ToastMessage.show(messageText: toastMessage)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didLongTapOnRowAtIndex longTappedIndex: Int) {
        if let tableViewType = tableView.😍() as? TableViewType {
            switch tableViewType {
            case TableViewType.firebase:
                let key = firebaseKeys[longTappedIndex]
                presentedAlert = UIAlertController.makeAlert(title: "Edit '\(key)'", message: "enter a new string:")
                    .withInputText(configurationBlock: { [weak self] (textField) in
                        textField.placeholder = "new value"
                        textField.text = self?.syncedUserDefaults.currentDictionary[key]
                        textField.😘(huggedObject: tableViewType)
                    }).withAction(UIAlertAction(title: "Change", style: .destructive, handler: { [weak self] (alertAction) in
                        guard let newValue = self?.presentedAlert?.textFields?.first?.text else { return }
                        self?.syncedUserDefaults.putString(key: key, value: newValue)
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
                    syncedUserDefaults.removeString(key: key)
                    firebaseKeys.remove(where: { return $0 == key })
                }
            case TableViewType.coreData:
                let selectedUser = users[indexPath.row]
                let selectedUserDescription = selectedUser.description
                
                if selectedUser.remove() && selectedUser.save() {
                    ToastMessage.show(messageText: "Deleted: [\(selectedUserDescription)])")
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
