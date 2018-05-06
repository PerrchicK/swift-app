//
//  WhackGame.swift
//  SomeApp
//
//  Created by Perry on 2/23/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

protocol WhackGameDelegate: GameDelegate {
}

class WhackGame: Game {
    let currentPlayer: Player
    weak internal var delegate: GameDelegate?
    
    struct Configuration {
        static let MaxPlayerHits = 5
        static let MaxPlayerMisses = 5
        static let RowsCount = 3
        static let ColumnsCount = Configuration.RowsCount
        static let MaxMovesInSequence = Configuration.RowsCount
    }
    
    init(playerName: String) {
        currentPlayer = WhackPlayer()
    }
    
    func restart() { }
    
    func playMove(player: Player, row: Int, column: Int) { }
    
    class WhackPlayer: Player {
        func intValue() -> Int {
            return -1
        }
        
        func stringValue() -> String {
            return ""
        }
    }
    
}
