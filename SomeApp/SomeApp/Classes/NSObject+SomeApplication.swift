//
//  NSObject+SomeApplication.swift
//  SomeApplication
//
//  Created by Perry on 1/8/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import ObjectiveC

// Declare a global var to produce a unique address as the assoc object handle
var SompApplicationBelovedProperty: UInt8 = 0

// Question: What is redundant in this code?

//infix operator 😘 { associativity left precedence 140 }
func 😘(left: NSObject, right: String) throws -> Bool {
    return try left.😘(beloved: right)
}

extension NSObject { // try AnyObject first...
    //infix operator 😘 { associativity left precedence 140 }
    func 😘(beloved beloved: String) throws -> Bool {
        guard beloved.characters.count > 0 else {
            return false
        }

        print("loving \(beloved)")
        
        // "Hard" guard
        //assert(beloved.characters.count > 0, "non-empty strings only")
        
        objc_setAssociatedObject(self, &SompApplicationBelovedProperty, beloved, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return true
    }

    func 😍() -> String? { // 1
        //print("loving \(right)")
        guard let value = objc_getAssociatedObject(self, &SompApplicationBelovedProperty) as? String else {
            return nil
        }
        
        return value
    }
}