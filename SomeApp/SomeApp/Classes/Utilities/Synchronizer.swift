//
//  Synchronizer.swift
//  SomeApp
//
//  Created by Perry on 3/25/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class Synchronizer {
    internal class HolderTicket {
        let blockOperation: NSBlockOperation
        let raceConditionQueue: NSOperationQueue

        init(raceConditionQueue: NSOperationQueue, block: (() -> Void)? = nil) {
            self.raceConditionQueue = raceConditionQueue
            if let block = block {
                blockOperation = NSBlockOperation(block: block)
            } else {
                blockOperation = NSBlockOperation(block: {
                    // Do nothing...
                    📘("operation is done")
                })
            }
        }

        func release() -> Bool {
            if !blockOperation.finished {
                // Dispatch...
                raceConditionQueue.addOperation(blockOperation)
                return true
            }

            return false
        }
    }

    let raceConditionQueue = NSOperationQueue()

    let completionOperation: NSBlockOperation
    private var shouldAddCompletionOperation = true
    /**
     Initializes an atomic synchronization between two operations
     
     - parameter operation1: An operation to do, regardless the time to end
     - parameter operation2: An operation to do, regardless the time to end
     - parameter finalOperation: The completion operation to do, only after the first two are finished. It shall be invoked on the main thread.
     */
    init(finalOperation: () -> Void) {
        let completionOperation = NSBlockOperation {
            dispatch_async(dispatch_get_main_queue(), { 
                finalOperation()
            })
        }

        self.completionOperation = completionOperation
    }
    
    func createHolder(onReleaseBlock onReleaseBlock: (() -> Void)? = nil) -> HolderTicket {
        let blocker = HolderTicket(raceConditionQueue: self.raceConditionQueue, block: onReleaseBlock)
        self.completionOperation.addDependency(blocker.blockOperation)

        // Will occur only once
        if shouldAddCompletionOperation {
            shouldAddCompletionOperation = false
            self.raceConditionQueue.addOperation(completionOperation)
        }

        return blocker
    }
    
    static func syncOperations(operations: (() -> Void)..., withFinalOperation finalOperation: () -> Void) {
        guard operations.count > 0 else { finalOperation(); return }

        guard operations.count > 1 else {
            operations[0]()
            finalOperation()
            return
        }

        let raceConditionQueue = NSOperationQueue()
        let completionOperation = NSBlockOperation {
            dispatch_async(dispatch_get_main_queue(), {
                finalOperation()
            })
        }

        var blockOperations = [NSBlockOperation]()
        for operation in operations {
            let blockOperation = NSBlockOperation(block: operation)
            blockOperations.append(blockOperation)
           
            completionOperation.addDependency(blockOperation)
        }

        raceConditionQueue.addOperation(completionOperation)

        for blockOperation in blockOperations {
            raceConditionQueue.addOperation(blockOperation)
        }
    }
}