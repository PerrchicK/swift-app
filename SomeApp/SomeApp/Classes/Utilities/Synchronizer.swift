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
    let operation1 = NSBlockOperation(block: { () -> Void in
        // Do something
        📘("operation 1 is done")
    })
    let operation2 = NSBlockOperation(block: { () -> Void in
        // Do something
        📘("operation 2 is done")
    })
    
    init(finalOperation: () -> Void) {
        let completionOperation = NSBlockOperation {
            finalOperation()
        }
        completionOperation.addDependency(operation1)
        completionOperation.addDependency(operation2)
        raceConditionQueue.addOperation(completionOperation)
    }
    
    func do1() {
        if !operation1.finished {
            // Distapch...
            raceConditionQueue.addOperation(operation1)
        }
    }
    
    func do2() {
        if !operation2.finished {
            // Distapch...
            raceConditionQueue.addOperation(operation2)
        }
    }
}