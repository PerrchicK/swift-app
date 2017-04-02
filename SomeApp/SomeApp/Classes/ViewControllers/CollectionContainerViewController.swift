//
//  CollectionContainerViewController.swift
//  SomeApp
//
//  Created by Perry on 2/21/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class CollectionContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let NumberOfRows = 3 // X - number of section
    let NumberOfColumns = 3 // Y - number of items in section
    let TileMargin = CGFloat(5.0)

    var isGameEnabled = true

    func reloadGame() {
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // This will: (1) dequeue the cell, if it doesn't exist it will create one. (2) will cast it to our custom cell. (3) will assert that the casting is legal.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: className(CollectionContainerCell.self), for: indexPath) as! CollectionContainerCell

        cell.configCell()

        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.backgroundColor = UIColor.clear
        return NumberOfColumns
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return NumberOfRows
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let rowsCount = CGFloat(NumberOfColumns)
        let dimentions = collectionView.frame.height / rowsCount - (rowsCount * TileMargin * 0.8)
        return CGSize(width: dimentions, height: dimentions) // collectionView.frame.height * 0.9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(TileMargin, TileMargin, TileMargin, TileMargin)
    }
}

class CollectionContainerCell: UICollectionViewCell {

    @IBOutlet weak var playerMarkLabel: UILabel!

    func configCell() {
        self.backgroundColor = UIColor.red
        self.playerMarkLabel.text = ""
    }
}
