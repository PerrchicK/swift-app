//
//  CollectionContainerViewController.swift
//  SomeApp
//
//  Created by Perry on 2/21/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class CollectionContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let RowsCount = 5
    let ColsCount = 5
    let TileMargin = CGFloat(5.0)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // This will: (1) dequeue the cell, if it doesn't exist it will create one. (2) will cast it to our custom cell. (3) will assert that the casting is legal.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(className(CollectionContainerCell), forIndexPath: indexPath) as! CollectionContainerCell

        cell.configCell()

        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.backgroundColor = UIColor.clearColor()
        return ColsCount
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return RowsCount
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        ToastMessage.show(messageText: "(\(indexPath.section),\(indexPath.row))", inView: self.view)
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        collectionView.invalidateLayout() performBatch...
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let rowsCount = CGFloat(RowsCount)
        let dimentions = collectionView.frame.height / rowsCount - (rowsCount * TileMargin * 0.8)
        return CGSize(width: dimentions, height: dimentions) // collectionView.frame.height * 0.9
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(TileMargin, TileMargin, TileMargin, TileMargin)
    }
}

class CollectionContainerCell: UICollectionViewCell {

    func configCell() {
        self.backgroundColor = UIColor.redColor()
    }
}