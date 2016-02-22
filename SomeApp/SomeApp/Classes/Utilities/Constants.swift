//
//  Constants.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

public struct Notifications {
    public static let CloseDrawer = "CloseDrawer"
}

public struct LeftMenuOptions {
    public struct iOS {
        public static let title = "iOS"
        
        public static let Data = "Data"
    }
    public struct UI {
        public static let title = "UI"
        
        public static let Views_Animations = "Views & Animations"
        public static let CollectionView = "Collection View"
    }
    public struct SwiftStuff {
        public static let title = "Swift Stuff"
        
        public static let OperatorsOverloading = "Operators Overloading"
    }
    public struct Concurrency {
        public static let title = "Concurrency"
        
        public static let GCD = "GCD" // Grand Central Dispatch
    }
}