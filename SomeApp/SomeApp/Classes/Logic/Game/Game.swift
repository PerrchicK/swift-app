//
//  TicTabToe.swift
//  SomeApp
//
//  Created by Perry on 2/23/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

protocol Player {
    func intValue() -> Int
    func stringValue() -> String
}

protocol Game: class {
    weak var delegate: GameDelegate? { get set }
    var player: Player? { get }
}

protocol GameDelegate: class {
    func game(_ game: Game, finishedWithWinner winner: Player)
    func isGameEnabled(_ game: Game) -> Bool
}
