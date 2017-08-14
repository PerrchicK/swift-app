//
//  Synchronizer.swift
//  SomeApp
//
//  Created by Perry on 3/25/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

/// Responsible for synchronizing asynchronous operations by wrapping Apple's OperationQueue class
class Synchronizer {
    internal class HolderTicket {
        let blockOperation: BlockOperation
        let raceConditionQueue: OperationQueue

        init(raceConditionQueue: OperationQueue, block: (() -> ())? = nil) {
            self.raceConditionQueue = raceConditionQueue
            if let block = block {
                blockOperation = BlockOperation(block: block)
            } else {
                blockOperation = BlockOperation(block: {
                    // Do nothing...
                    📘("operation is done")
                })
            }
        }

        @discardableResult
        func release() -> Bool {
            if !blockOperation.isFinished {
                // Dispatch...
                raceConditionQueue.addOperation(blockOperation)
                return true
            }

            return false
        }
    }

    let raceConditionQueue = OperationQueue()

    let completionOperation: BlockOperation
    fileprivate var shouldAddCompletionOperation = true

    /**
     Initializes an atomic synchronization between various operations
     
     - parameter finalOperationQueue: In case of updating UI without using 'DispatchQueue.main' (not on the main thread), the block will run on a background thread, we might get the following error: "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird crashes.  This will cause an exception in a future release.". Usually the app will not crash, but will act weird and slow.
     
     - parameter finalOperationClosure: The completion operation to do, only after the all holders are released.
     */
    init(finalOperationQueue: DispatchQueue = DispatchQueue.main, finalOperationClosure: @escaping () -> ()) {
        let completionOperation = BlockOperation {
            finalOperationQueue.async(execute: {
                finalOperationClosure()
            })
        }

        self.completionOperation = completionOperation
    }

    func createHolder(onReleaseBlock: (() -> Void)? = nil) -> HolderTicket {
        let blocker = HolderTicket(raceConditionQueue: self.raceConditionQueue, block: onReleaseBlock)
        self.completionOperation.addDependency(blocker.blockOperation)

        // Will occur only once
        if shouldAddCompletionOperation {
            shouldAddCompletionOperation = false
            self.raceConditionQueue.addOperation(completionOperation)
        }

        return blocker
    }
    
    static func syncOperations(_ operationClosures: (() -> Void)..., withFinalOperation finalOperation: @escaping () -> Void) {
        guard operationClosures.count > 0 else { finalOperation(); return }

        guard operationClosures.count > 1 else {
            operationClosures[0]()
            finalOperation()
            return
        }

        let raceConditionQueue = OperationQueue()
        let completionOperation = BlockOperation {
            DispatchQueue.main.async(execute: {
                finalOperation()
            })
        }

        var blockOperations = [BlockOperation]()
        for operationBlock in operationClosures {
            let blockOperation = BlockOperation(block: operationBlock)
            blockOperations.append(blockOperation)
           
            completionOperation.addDependency(blockOperation)
        }

        raceConditionQueue.addOperation(completionOperation)

        for blockOperation in blockOperations {
            raceConditionQueue.addOperation(blockOperation)
        }
    }
}
