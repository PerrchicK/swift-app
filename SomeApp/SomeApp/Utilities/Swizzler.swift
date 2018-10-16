//
//  Swizzler.swift
//  SomeApp
//
//  Created by Perry Shalev on 16/10/2018.
//  Copyright © 2018 PerrchicK. All rights reserved.
//

import Foundation

class Swizzler {
    static var swizzledSelectors = [Selector:Any]()
    /* Swizzles
     - From: https://medium.com/@abhimuralidharan/method-swizzling-in-ios-swift-1f38edaf984f
     */
    @discardableResult
    static func swizzle(selector originalSelector: Selector, ofClass swizzledClass: AnyClass, withSelector replacingSelector: Selector) -> (originalImplementation: IMP, originalSelector: Selector)? {
        var resultTuple: (originalImplementation: IMP, originalSelector: Selector)?
        let originalMethod = class_getInstanceMethod(swizzledClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(swizzledClass, replacingSelector)
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            let implementation = method_getImplementation(originalMethod)
            // switch selectors
            method_exchangeImplementations(originalMethod, swizzledMethod)
            // Finish
            resultTuple = (implementation, originalSelector)
            //let closure = unsafeBitCast(implementation, to: (@convention(c) (AnyObject, Selector, CALayer, CGContext) -> Void).self)
            //swizzledSelectors[originalSelector] = closure
        }
        
        return resultTuple
    }
}
