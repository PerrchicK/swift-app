//
//  SwiftBridgedClass.swift
//  SomeApp
//
//  Created by Perry on 8/18/18.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

extension SwiftBridgedClass { // Inspired (not taken) from: https://medium.com/post-mortem/using-nsobjects-load-and-initialize-from-swift-f6f2c6d9aad0
    @objc static func swiftyLoad() {
        📘("App classes are loaded")
    }

    @objc static func swiftyInitialize() {
        📘("App classes are initialized")
    }
}
