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
    lazy var raceConditionQueue = OperationQueue()

    let completionOperation: BlockOperation
    fileprivate var shouldAddCompletionOperation: Bool

    /**
     Initializes an atomic synchronization between various operations
     
     - parameter finalOperationQueue: In case of updating UI without using 'DispatchQueue.main' (not on the main thread), the block will run on a background thread, we might get the following error: "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird crashes.  This will cause an exception in a future release.". Usually the app will not crash, but will act weird and slow.
     
     - parameter finalOperationClosure: The completion operation to do, only after the all holders are released.
     */
    init(finalOperationQueue: DispatchQueue = DispatchQueue.main, finalOperationClosure: @escaping () -> ()) {
        shouldAddCompletionOperation = true
        completionOperation = BlockOperation {
            finalOperationQueue.async(execute: {
                finalOperationClosure()
            })
        }
    }

    func createHolder(onReleaseBlock: (() -> Void)? = nil) -> Holder {
        let blocker = Holder(raceConditionQueue: raceConditionQueue, block: onReleaseBlock)
        self.completionOperation.addDependency(blocker.blockOperation)

        // Will occur only once
        if shouldAddCompletionOperation {
            shouldAddCompletionOperation = false
            self.raceConditionQueue.addOperation(completionOperation)
        }

        return blocker
    }

    @discardableResult
    func wait(forHolder holderClosure: (Holder) -> ()) -> Synchronizer {
        holderClosure(createHolder())
        return self
    }

    internal class Holder {
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
            guard !blockOperation.isFinished else { return false }

            // Dispatch...
            raceConditionQueue.addOperation(blockOperation)
            return true
        }
    }
}
