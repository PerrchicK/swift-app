//
//  CrazyWhackViewController.swift
//  SomeApp
//
//  Created by Perry on 16/08/2017.
//  Copyright © 2017 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class CrazyCollectionView: UICollectionView {
}

class CrazyWhackViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GameDelegate, UITextFieldDelegate {

    lazy var collectionView: UICollectionView = {
        let c = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewLayout())
//        self.view.addSubview(c)
//        c.stretchToSuperViewEdges()
        c.delegate = self
        c.dataSource = self
        return c
    }()
    var playerNameTextField: UITextField?
    
    let NumberOfRows = CrazyWhackGame.Configuration.RowsCount // X - number of section
    let NumberOfColumns = CrazyWhackGame.Configuration.ColumnsCount // Y - number of items in section
    let TileMargin = CGFloat(5.0)
    
    var game: Game?
    func createGame(playerName: String) -> Game {
        game = WhackGame(playerName: playerName)
        game?.delegate = self
        
        return game!
    }
    
    var isGameEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: PerrFuncs.className(CrazyGameCell.self), bundle: nil), forCellWithReuseIdentifier: CrazyGameCell.REUSE_IDENTIFIER)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //let closeButton = UIButton()
        //closeButton.setTitle("❌", for: .normal)
        //view.addSubview(closeButton)
        //closeButton.stretchToSuperViewEdges()

        view.onSwipe(direction: .down) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        reloadGame()
    }
    
    func reloadGame() {
        collectionView.reloadData()

//        UIAlertController.makeAlert(title: "name", message: "enter one letter name", dismissButtonTitle: "pass...").withInputText(configurationBlock: { [weak self] (textField) in
//            self?.playerNameTextField = textField
//            textField.placeholder = "your symbol"
//            textField.delegate = self
//        }).withAction(UIAlertAction(title: "name it", style: UIAlertActionStyle.default, handler: { [weak self] (alertAction) in
//            guard let strongSelf = self, let playerName = strongSelf.playerNameTextField?.text else { return }
//            strongSelf.game = strongSelf.createGame(playerName: playerName)
//            strongSelf.game?.restart()
//        })).show()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let playerNameText = playerNameTextField?.text, playerNameTextField == textField else { return true }
        return playerNameText.length() == 0 && string.length() == 1 || string.length() == 0
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // This will: (1) dequeue the cell, if it doesn't exist it will create one. (2) will cast it to our custom cell. (3) will assert that the casting is legal.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CrazyGameCell.REUSE_IDENTIFIER, for: indexPath) as! GameCell
        
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
        guard let game = game else { return }
        
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
    
    // MARK: - TicTacToeGameDelegate
    
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

class CrazyGameCell: GameCell {
    static let REUSE_IDENTIFIER = PerrFuncs.className(XibGameCell.self)
    
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

class CrazyWhackGame {
    struct Configuration {
        static let RowsCount = 3
        static let ColumnsCount = Configuration.RowsCount
        static let MaxMovesInSequence = Configuration.RowsCount
    }
}
