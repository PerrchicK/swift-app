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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let NumberOfRows = TicTabToeGame.Configuration.RowsCount // X - number of section
    let NumberOfColumns = TicTabToeGame.Configuration.ColumnsCount // Y - number of items in section
    let TileMargin = CGFloat(5.0)

    static let PLAYER_NAME = "user"
    lazy var game: Game = {
        let game = TicTabToeGame()
//        let game = WhackGame(playerName: CollectionContainerViewController.PLAYER_NAME)
        game.delegate = self

        return game
    }()

//    var game: Game
    var isGameEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(ProgrammaticallyGameCell.self, forCellWithReuseIdentifier: ProgrammaticallyGameCell.REUSE_IDENTIFIER)
        collectionView.register(XibGameCell.self, forCellWithReuseIdentifier: XibGameCell.REUSE_IDENTIFIER)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadGame()
    }
    
    func reloadGame() {
        collectionView.reloadData()
        game.restart()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // This will: (1) dequeue the cell, if it doesn't exist it will create one. (2) will cast it to our custom cell. (3) will assert that the casting is legal.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryboardGameCell.REUSE_IDENTIFIER, for: indexPath) as! GameCell

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
        // If the move is confirmed, the delegate will be called
        game.playMove(player: game.currentPlayer, row: indexPath.section, column: indexPath.item)
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

    func game(_ game: Game, playerMadeMove player: Player, row: Int, column: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: column, section: row)) as? GameCell else {
            📘("Error: failed to get the cell")
            return
        }
        cell.placeMark(player.stringValue())
    }

    func game(_ game: Game, finishedWithWinner winner: Player) {
        ToastMessage.show(messageText: "winner: \(winner)")
        isGameEnabled = false
    }

    func isGameEnabled(_ game: Game) -> Bool {
        return isGameEnabled
    }
}

class ProgrammaticallyGameCell: GameCell {
    static let REUSE_IDENTIFIER = className(ProgrammaticallyGameCell.self)

    override func awakeFromNib() {
        📘("Created a \(className(ProgrammaticallyGameCell.self)) object")
    }

    override var playerMarkLabel: UILabel! {
        get {
            return _playerMarkLabel
        }
        set { }
    }
    
    lazy var _playerMarkLabel: UILabel = {
        var playerMarkLabel = UILabel()
        playerMarkLabel.textAlignment = .center
        self.addSubview(playerMarkLabel)
        playerMarkLabel.stretchToSuperViewEdges()
        return playerMarkLabel
    }()
}

class StoryboardGameCell: GameCell {
    static let REUSE_IDENTIFIER = className(StoryboardGameCell.self)
    
    @IBOutlet weak var _playerMarkLabel: UILabel!

    override func awakeFromNib() {
        📘("Created a \(className(StoryboardGameCell.self)) object")
    }
    
    override var playerMarkLabel: UILabel! {
        get {
            return _playerMarkLabel
        }
        set {
            _playerMarkLabel = newValue
        }
    }
}

class XibGameCell: GameCell {
    static let REUSE_IDENTIFIER = className(XibGameCell.self)
    
    @IBOutlet weak var _playerMarkLabel: UILabel!
    
    override var playerMarkLabel: UILabel! {
        get {
            return _playerMarkLabel
        }
        set {
            _playerMarkLabel = newValue
        }
    }
}

class GameCell: UICollectionViewCell {

    var playerMarkLabel: UILabel!

    func configCell() {
        self.backgroundColor = UIColor.red
        self.playerMarkLabel.text = ""
    }

    func placeMark(_ mark: String) {
        if playerMarkLabel.text?.length() ?? 0 > 0 {
            playerMarkLabel.animateZoom(zoomIn: false, duration: 0.4, completion: { _ in
                self.playerMarkLabel.text = ""
                self.playerMarkLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        } else {
            playerMarkLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            playerMarkLabel.text = mark
        }
        
    }
}
