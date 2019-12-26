//
//  CollectionViewController.swift
//  SomeApp
//
//  Created by Perry on 2/21/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GameDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var playerNameTextField: UITextField?

    let NumberOfRows = TicTacToeGame.Configuration.RowsCount // X - number of section
    let NumberOfColumns = TicTacToeGame.Configuration.ColumnsCount // Y - number of items in section
    lazy var TileMargin: CGFloat = CGFloat(2.0)
    var allCellsPointers: [Int: [Int: WeakReference<GameCell>]] = [:]

    static let PLAYER_NAME = "user"
    lazy var game: Game = {
        let game = TicTacToeGame()
        game.delegate = self

        return game
    }()

    var isGameEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()

        //https://randexdev.com/2014/08/uicollectionviewcell/
        collectionView.register(ProgrammaticallyGameCell.self, forCellWithReuseIdentifier: ProgrammaticallyGameCell.REUSE_IDENTIFIER)
        collectionView.register(UINib(nibName: PerrFuncs.className(XibGameCell.self), bundle: nil), forCellWithReuseIdentifier: XibGameCell.REUSE_IDENTIFIER)
        // No need to to this: https://stackoverflow.com/a/29101490/2735029
        //collectionView.register(StoryboardGameCell.self, forCellWithReuseIdentifier: StoryboardGameCell.REUSE_IDENTIFIER)

        collectionView.isScrollEnabled = false

        view.onSwipe(direction: .down) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        collectionView.onSwipe(direction: .down) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isGameEnabled {
            reloadGame()
        } else {
            ToastMessage.show(messageText: "There's nothing to see here...", onGone: { [weak self] in
                self?.navigateToToMapView()
            })
        }
    }

    func reloadGame() {
        collectionView.reloadData()
        game.restart()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

//        let reuseIdentifier = XibGameCell.REUSE_IDENTIFIER
        let reuseIdentifier = ProgrammaticallyGameCell.REUSE_IDENTIFIER
//        let reuseIdentifier = StoryboardGameCell.REUSE_IDENTIFIER

        // This will: (1) dequeue the cell, if it doesn't exist it will create one. (2) will cast it to our custom cell. (3) will assert that the casting is legal.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GameCell

        cell.configCell()
        if allCellsPointers[indexPath.row] == nil {
            allCellsPointers[indexPath.row] = [:]
        }
        allCellsPointers[indexPath.row]?[indexPath.section] = WeakReference<GameCell>(cell)

        cell.onLongPress { [weak self] _ in
            self?.exposeAllCells(fromIndexPath: indexPath)
        }

        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.backgroundColor = UIColor.clear
        //return section == 1 ? NumberOfColumns - 1 : NumberOfColumns
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
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let rowsCount = CGFloat(NumberOfColumns)
        var dimentions = collectionView.frame.width / rowsCount - (rowsCount * TileMargin * 0.8)
        dimentions = dimentions < 0 ? collectionView.frame.width / rowsCount : dimentions
        dimentions = dimentions < 0 ? 5 : dimentions
        return CGSize(width: dimentions, height: dimentions) // collectionView.frame.height * 0.9
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
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
        
        navigateToToMapView()
    }
    
    func navigateToToMapView() {
        navigationController?.pushViewController(MapLocationAndCommunicationViewController.instantiate(), animated: true)
    }

    func isGameEnabled(_ game: Game) -> Bool {
        return isGameEnabled
    }
    
    func exposeAllCells(fromIndexPath indexPath: IndexPath) {
        guard let weakCellPointer = self.allCellsPointers[indexPath.row]?[indexPath.section] else { return }
        guard let cell = weakCellPointer.some else {
            // Cleanup...
            self.allCellsPointers[indexPath.row]?[indexPath.section] = nil
            return
        }

        guard cell.isPresented else { return }
        guard (cell.playerMarkLabel.text?.length() ?? 0) == 0 else { return }

        self.allCellsPointers[indexPath.row]?[indexPath.section]?.some?.isPresented = false
        📘("Cell [\(indexPath.row)][\(indexPath.section)] disappeared...")

        // Call all neighbours recursively
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row, section: indexPath.section + 1))
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section))
//
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row, section: indexPath.section - 1))
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section))
//
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section - 1))
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section + 1))
//
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section + 1))
//        self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section - 1))
        
        let delayDelta = 0.1
        var delay: Double = 0

        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row, section: indexPath.section + 1))
        }

        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section))
        }
        
        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row, section: indexPath.section - 1))
        }

        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section))
        }
        
        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section - 1))
        }

        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section + 1))
        }
        
        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section + 1))
        }

        delay += delayDelta
        PerrFuncs.runBlockAfterDelay(afterDelay: delay) {
            self.exposeAllCells(fromIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section - 1))
        }
    }
    
    deinit {
        📘("dead")
    }
}

//MARK: - GameCell super class

class GameCell: UICollectionViewCell {
    
    var playerMarkLabel: UILabel!
    
    override func awakeFromNib() {
        📘("Created a \(PerrFuncs.className(self.classForCoder)) object")
    }

    func configCell() {
        self.backgroundColor = UIColor.red
        self.playerMarkLabel.text = ""
    }
    
    func placeMark(_ mark: String) {
        if playerMarkLabel.text?.length() ?? 0 > 0 {
            playerMarkLabel.text = ""
            //            playerMarkLabel.animateZoom(zoomIn: false, duration: 0.4, completion: { _ in
            //                self.playerMarkLabel.text = ""
            //                self.playerMarkLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            //            })
        } else {
            //playerMarkLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            playerMarkLabel.text = mark
        }
    }
}

//MARK: - GameCell subclasses

class ProgrammaticallyGameCell: GameCell {
    static let REUSE_IDENTIFIER = PerrFuncs.className(ProgrammaticallyGameCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
        📘("Created a \(PerrFuncs.className(ProgrammaticallyGameCell.self)) object")
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
        playerMarkLabel.makeRoundedCorners()
        return playerMarkLabel
    }()
}

class StoryboardGameCell: GameCell {
    static let REUSE_IDENTIFIER = PerrFuncs.className(StoryboardGameCell.self)
    
    @IBOutlet weak var _playerMarkLabel: UILabel!

    override func awakeFromNib() {
        📘("Created a \(PerrFuncs.className(StoryboardGameCell.self)) object")
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

public class WeakReference<Wrapped: AnyObject> {
    weak private(set) var some: Wrapped?

    public init(_ some: Wrapped) {
        self.some = some
    }
}

//extension Array<T: AnyObject> {
//    convenience init(weak: T) {
//        <#statements#>
//    }
//}
