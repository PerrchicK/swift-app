//
//  CollectionContainerViewController.swift
//  SomeApp
//
//  Created by Perry on 2/21/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class CollectionContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, TicTabToeGameDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let NumberOfRows = TicTabToeGame.Configuration.RowsCount // X - number of section
    let NumberOfColumns = TicTabToeGame.Configuration.ColumnsCount // Y - number of items in section
    let TileMargin = CGFloat(5.0)

    var game: TicTabToeGame!
    var isGameEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()

        game = TicTabToeGame()
        game.delegate = self
    }

    func reloadGame() {
        collectionView.reloadData()
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
        return NumberOfColumns
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return NumberOfRows
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionContainerCell

        let currentPlayerMark = game.currentPlayer.rawValue
        if game.playerMadeMove(indexPath.section, column: indexPath.row) {
            // Move confirmed
            cell.placeMark(currentPlayerMark)
        }
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        collectionView.invalidateLayout() performBatch...
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let rowsCount = CGFloat(NumberOfColumns)
        let dimentions = collectionView.frame.height / rowsCount - (rowsCount * TileMargin * 0.8)
        return CGSize(width: dimentions, height: dimentions) // collectionView.frame.height * 0.9
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(TileMargin, TileMargin, TileMargin, TileMargin)
    }

    // MARK: - TicTabToeGameDelegate

    func ticTabToeGame(game: TicTabToeGame, finishedWithWinner winner: TicTabToeGame.Player) {
        ToastMessage.show(messageText: "winner: \(winner)")
        isGameEnabled = false
    }

    func isGameEnabled(game: TicTabToeGame) -> Bool {
        return isGameEnabled
    }
}

class CollectionContainerCell: UICollectionViewCell {

    @IBOutlet weak var playerMarkLabel: UILabel!

    func configCell() {
        📘("configuring cell")
        self.backgroundColor = UIColor.redColor()
        self.playerMarkLabel.text = ""
    }

    func placeMark(mark: String) {
        self.playerMarkLabel.text = mark
    }
}