//
//  TicTacToeGame.swift
//  SomeApp
//
//  Created by Perry on 2/23/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

protocol TicTacToeGameDelegate: GameDelegate {
}

class TicTacToeGame: Game {
    internal var currentPlayer: Player
    weak internal var delegate: GameDelegate?

    struct Configuration {
        static let RowsCount = 3
        static let ColumnsCount = Configuration.RowsCount
        static let MaxMovesInSequence = Configuration.RowsCount
    }

    enum TicTacToePlayer: Player { // Enums don't must to inherit from anywhere, but it's helpful
        case X
        case O
        
        func intValue() -> Int {
            return TicTacToePlayer.X == self ? 1 : -1
        }
        
        func stringValue() -> String {
            return TicTacToePlayer.X == self ? "X" : "O"
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

    fileprivate lazy var matrix = Array<[Int?]>(repeating: Array<Int?>(repeating: nil, count: Configuration.RowsCount), count: Configuration.ColumnsCount)
    
    init() {
        currentPlayer = TicTacToePlayer.X
    }

    internal func playMove(player: Player, row: Int, column: Int) {
        // Using 'guard' statement to ensure conditions
        guard isGameEnabled && matrix[row][column] == nil else { return }

        matrix[row][column] = player.intValue()

        if let winner = checkWinner() {
            delegate?.game(self, finishedWithWinner: winner)
        } else {
            switchTurns()
        }

        delegate?.game(self, playerMadeMove: player, row: row, column: column)
    }

    fileprivate func switchTurns() {
        guard let _currentPlayer = currentPlayer as? TicTacToePlayer else { return }
        currentPlayer = _currentPlayer == TicTacToePlayer.X ? TicTacToePlayer.O : TicTacToePlayer.X
    }

    fileprivate func checkWinner() -> Player? {
        var winner: Player? = nil
        var diagonalSequenceCounter = 0
        var reverseDiagonalSequenceCounter = 0

        var verticalSequenceCounter = Array<Int>(repeating: 0, count: Configuration.MaxMovesInSequence)
//      Or: var verticalSequenceCounter = [0,0,0]
        for row in 0...Configuration.RowsCount - 1 {
            // Using 'guard' keyword for optimization in runtime, skips redundant loops
            guard winner == nil else { return winner }

            // Count \
            let diagonalIndex = row
            if let moveInDiagonalSequence = matrix[diagonalIndex][diagonalIndex] {
                if moveInDiagonalSequence == currentPlayer.intValue() {
                    // Removed on Swift 3.0:
//                    diagonalSequenceCounter++
                    diagonalSequenceCounter += 1
                }
            }

            // Count /
            let reverseDiagonalIndex = Configuration.RowsCount - row - 1
            if let moveInReverseDiagonalSequence = matrix[row][reverseDiagonalIndex] {
                if moveInReverseDiagonalSequence == currentPlayer.intValue() {
                    // Removed on Swift 3.0:
//                    reverseDiagonalSequenceCounter++
                    reverseDiagonalSequenceCounter += 1
                }
            }

            var horizontalSequenceCounter = 0
            for column in 0...Configuration.ColumnsCount - 1 {
                if let moveInRow = matrix[row][column] {
                    if moveInRow == currentPlayer.intValue() {
                        // Count -
                        horizontalSequenceCounter += 1
                        // Count |
                        verticalSequenceCounter[column] += currentPlayer.intValue()
                    }
                }
            }

            if [horizontalSequenceCounter, diagonalSequenceCounter, reverseDiagonalSequenceCounter].contains(Configuration.MaxMovesInSequence) {
                // 3 in an horozintal / diagonal row
                winner = currentPlayer
            } else if verticalSequenceCounter.contains(-Configuration.MaxMovesInSequence) || verticalSequenceCounter.contains(Configuration.MaxMovesInSequence) {
                // 3 in a vertical row
                winner = currentPlayer
            }
        }

        return winner
    }
    
    func restart() {
    }
}
