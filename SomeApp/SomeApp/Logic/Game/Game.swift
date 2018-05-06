//
//  Game.swift
//  SomeApp
//
//  Created by Perry on 4/8/17.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

protocol Game: class {
    weak var delegate: GameDelegate? { get set }
    var currentPlayer: Player { get }

    func restart()
    func playMove(player: Player, row: Int, column: Int)
}

protocol Player {
    func intValue() -> Int
    func stringValue() -> String
}

protocol GameDelegate: class {
    func game(_ game: Game, finishedWithWinner winner: Player)
    func game(_ game: Game, playerMadeMove player: Player, row: Int, column: Int)
    func isGameEnabled(_ game: Game) -> Bool
}
