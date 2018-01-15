//
//  LeftMenuViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

protocol LeftMenuViewControllerDelegate: class {
    func leftMenuViewController(_ leftMenuViewController: LeftMenuViewController, selectedOption: String)
}

class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: LeftMenuViewControllerDelegate?
    let distanceFromTopMargin: CGFloat = 20.0
    lazy var distanceFromTop: CGFloat = {
        let distanceFromTop = HEIGHT(UINavigationController().navigationBar.frame) + HEIGHT(UIApplication.shared.statusBarFrame) + self.distanceFromTopMargin
        return distanceFromTop
    }()

    @IBOutlet weak var distanceFromTopConstraint: NSLayoutConstraint!
    let menuItems =
    [LeftMenuOptions.iOS.title:
        [LeftMenuOptions.iOS.Data, LeftMenuOptions.iOS.CommunicationLocation, LeftMenuOptions.iOS.Notifications, LeftMenuOptions.iOS.ImagesCoreMotion],
    LeftMenuOptions.UI.title:
        [LeftMenuOptions.UI.Views_Animations, LeftMenuOptions.UI.CollectionView],
    LeftMenuOptions.SwiftStuff.title:
        [LeftMenuOptions.SwiftStuff.OperatorsOverloading],
    LeftMenuOptions.Concurrency.title:
        [LeftMenuOptions.Concurrency.GCD]]
    //LeftMenuOptions.PersonalDevelopment.title:
//        [LeftMenuOptions.PersonalDevelopment.CrazyWhack]]

    let leftMenuCellReuseIdentifier = PerrFuncs.className(LeftMenuCell.self)

    @IBOutlet weak var itemsTableView: UITableView!

    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Should be called only if you're using a XIB file, not Storyboard
        //self.itemsTableView.registerClass(LeftMenuCell.self, forCellReuseIdentifier: leftMenuCellReuseIdentifier)

        self.itemsTableView.alwaysBounceVertical = false
        self.itemsTableView.separatorStyle = .none
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.distanceFromTopConstraint.constant = distanceFromTop
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        distanceFromTop = self.distanceFromTopMargin
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuItemSectionTitle(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // http://stackoverflow.com/questions/25826383/when-to-use-dequeuereusablecellwithidentifier-vs-dequeuereusablecellwithidentifi
        let cell = tableView.dequeueReusableCell(withIdentifier: leftMenuCellReuseIdentifier, for: indexPath) as! LeftMenuCell

        if let tuple = menuItemTitle(indexPath) {
            cell.configureCell(tuple.itemTitle, cellIcon: tuple.itemIcon)
        } else {
            📘("Error: damaged tuple returned")
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionRows = menuItems[menuItemSectionTitle(section)] else { return 0 }

        return sectionRows.count
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = menuItems[menuItemSectionTitle(indexPath.section)]![indexPath.row]
        📘("selected \(selectedOption)")
        delegate?.leftMenuViewController(self, selectedOption: selectedOption)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Other helper methods

    func menuItemSectionTitle(_ section: Int) -> String {
        let sectionIndex = menuItems.index(menuItems.startIndex, offsetBy: section)
        let sectionTitle = menuItems.keys[sectionIndex]

        return sectionTitle
    }

    /**
     Returns a tuple of 2 strings as (title, icon) for a gicen index path
     */
    func menuItemTitle(_ indexPath: IndexPath) -> (itemTitle: String, itemIcon: String)? {
        let sectionIndex = menuItems.index(menuItems.startIndex, offsetBy: indexPath.section)
        let sectionTitle = menuItems.keys[sectionIndex]

        guard let itemsArray = menuItems[sectionTitle], itemsArray.count > 0 else {
            return nil
        }

        let itemTitle = itemsArray[indexPath.row]

        // Return tuple
        return (itemTitle, itemTitle.toEmoji())
    }
}

class LeftMenuCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellIcon: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Shouldn't be called, unless there's an instantiation from a XIB file
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(_ cellTitle: String, cellIcon: String) {
        self.cellTitle.text = cellTitle
        self.cellIcon.text = cellIcon
    }
    
}
