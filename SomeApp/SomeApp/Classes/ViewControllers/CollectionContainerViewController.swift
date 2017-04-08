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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionContainerCell

        let currentPlayerMark = game.currentPlayer.stringValue()
        if game.playerMadeMove(indexPath.section, column: indexPath.row) {
            // Move confirmed
            cell.placeMark(currentPlayerMark)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//        collectionView.invalidateLayout() performBatch...
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let rowsCount = CGFloat(NumberOfColumns)
        let dimentions = collectionView.frame.height / rowsCount - (rowsCount * TileMargin * 0.8)
        return CGSize(width: dimentions, height: dimentions) // collectionView.frame.height * 0.9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(TileMargin, TileMargin, TileMargin, TileMargin)
    }

    // MARK: - TicTabToeGameDelegate

    func game(_ game: Game, finishedWithWinner winner: Player) {
        ToastMessage.show(messageText: "winner: \(winner)")
        isGameEnabled = false
    }

    func isGameEnabled(_ game: Game) -> Bool {
        return isGameEnabled
    }
}

class CollectionContainerCell: UICollectionViewCell {

    @IBOutlet weak var playerMarkLabel: UILabel!

    func configCell() {
        📘("configuring cell")
        self.backgroundColor = UIColor.red
        self.playerMarkLabel.text = ""
    }

    func placeMark(_ mark: String) {
        self.playerMarkLabel.text = mark
    }
}
