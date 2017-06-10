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
    let computerPlayer: WhackPlayer
    weak internal var delegate: GameDelegate?

    private var popInTimer: Timer?
    private(set) var hits: Int = 0
    private(set) var misses: Int = 0
    private var matrix: Array<[Int?]>

    struct Configuration {
        static let RowsCount = 3
        static let ColumnsCount = Configuration.RowsCount
        static let MaxMovesInSequence = Configuration.RowsCount
    }

    class WhackPlayer: Player, CustomStringConvertible {
        let name: String
        
        init(name: String) {
            self.name = name
        }

        func intValue() -> Int {
            return name.length()
        }

        func stringValue() -> String {
            return name
        }
        
        var description: String {
            return name
        }
    }


    // Computed property
    fileprivate var isGameEnabled: Bool {
        // Using 'guard' keyword to ensure that the delegate exists (not null):
        guard let delegate = delegate else { return false }
        // If exists: Make a new (and not optional!) object and continue
        // If it doesn't exist: do nothing and return 'false'

        return delegate.isGameEnabled(self)
    }
    
    init(playerName: String) {
        currentPlayer = WhackPlayer(name: playerName)
        computerPlayer = WhackPlayer(name: "C")
        matrix = Array<[Int?]>(repeating: Array<Int?>(repeating: nil, count: Configuration.RowsCount), count: Configuration.ColumnsCount)
        
        popInTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(popInObject), userInfo: nil, repeats: true)
    }

    @objc func popOutObject(timer: Timer) {
        guard let userInfo = timer.userInfo as? (Int, Int) else { return }
        let row = userInfo.0
        let column = userInfo.1
        if matrix[row][column] != nil {
            playMove(player: computerPlayer, row: row, column: column)
        }
    }

    @objc func popInObject() {
        guard isGameEnabled else {
            popInTimer?.invalidate()
            return
        }

        let randomColumn = Int(PerrFuncs._random(to: Configuration.ColumnsCount))
        let randomRow = Int(PerrFuncs._random(to: Configuration.RowsCount))
        if matrix[randomRow][randomColumn] == nil {
            matrix[randomRow][randomColumn] = computerPlayer.intValue()
            playMove(player: computerPlayer, row: randomRow, column: randomColumn)

            // using tuple to pass the coordinates
            let userInfo: (Int, Int) = (randomRow, randomColumn)
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WhackGame.popOutObject), userInfo: userInfo, repeats: false)
        } else if matrix.filter( { $0.filter( { $0 == computerPlayer.intValue() } ).count == Configuration.RowsCount } ).count == Configuration.ColumnsCount {
            popInTimer?.invalidate()
            delegate?.game(self, finishedWithWinner: computerPlayer)
        } else {
            popInObject()
        }
    }

    func restart() {
        matrix.removeAll()
        matrix = Array<[Int?]>(repeating: Array<Int?>(repeating: nil, count: Configuration.RowsCount), count: Configuration.ColumnsCount)
    }

    func playMove(player: Player, row: Int, column: Int) {
        // Using 'guard' statement to ensure conditions
        guard let player = player as? WhackPlayer, isGameEnabled else { return }

        if matrix[row][column] != nil {
            if player.intValue() == currentPlayer.intValue() {
                hits += 1
                📘("player hit")
            } else if player.intValue() == computerPlayer.intValue() {
            }
            matrix[row][column] = nil
        } else if player.intValue() == computerPlayer.intValue() {
            📘("player miss")
            matrix[row][column] = nil
            misses += 1
        }

        delegate?.game(self, playerMadeMove: player, row: row, column: column)

        if let winner = checkWinner() {
            delegate?.game(self, finishedWithWinner: winner)
        }
    }

    fileprivate func checkWinner() -> Player? {
        return hits == 30 ? currentPlayer : (misses == 3 ? computerPlayer : nil)
    }
}
