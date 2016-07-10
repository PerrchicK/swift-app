//
//  Synchronizer.swift
//  SomeApp
//
//  Created by Perry on 3/25/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class Synchronizer {
    let raceConditionQueue = NSOperationQueue()
    let blockOperation1: NSBlockOperation
    let blockOperation2: NSBlockOperation

    /**
     Initializes an atomic synchronization between two operations
     
     - parameter operation1: An operation to do, regardless the time to end
     - parameter operation2: An operation to do, regardless the time to end
     - parameter finalOperation: The completion operation to do, only after the first two are finished. It shall be invoked on the main thread.
     */
    init(operation1: () -> Void, operation2: () -> Void, finalOperation: () -> Void) {
        let completionOperation = NSBlockOperation {
            dispatch_async(dispatch_get_main_queue(), { 
                finalOperation()
            })
        }

        blockOperation1 = NSBlockOperation(block: operation1)
        blockOperation2 = NSBlockOperation(block: operation2)

        completionOperation.addDependency(blockOperation1)
        completionOperation.addDependency(blockOperation2)
        raceConditionQueue.addOperation(completionOperation)
    }
    
    func do1() {
        if !blockOperation1.finished {
            // Distapch...
            raceConditionQueue.addOperation(blockOperation1)
        }
    }
    
    func do2() {
        if !blockOperation2.finished {
            // Distapch...
            raceConditionQueue.addOperation(blockOperation2)
        }
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