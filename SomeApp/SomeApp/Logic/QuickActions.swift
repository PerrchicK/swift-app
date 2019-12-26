//
//  QuickActions.swift
//  Runner
//
//  Created by Perry Shalom on 06/05/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

enum ShortcutItemType: String {
    case OpenImageExamples
    case OpenMultiTaskingExamples
    case OpenMapExamples
    
    init?(from rawValue: String) {
        switch rawValue {
        case ForceTouchQuickActions.Types.ViewAnimations:
            return nil
        case ForceTouchQuickActions.Types.ViewImages:
            self = ShortcutItemType.OpenImageExamples
        case ForceTouchQuickActions.Types.ViewMultithreading:
            self = ShortcutItemType.OpenMultiTaskingExamples
        case ForceTouchQuickActions.Types.ViewMap:
            self = ShortcutItemType.OpenMapExamples
//        case ForceTouchQuickActions.Types.ViewAnimations:
//            self = ShortcutItemType.OpenAnimationsExamples
        default:
            return nil
        }
    }
}

// https://developer.apple.com/documentation/uikit/uiapplicationshortcuticontype/
// http://www.thomashanning.com/3d-touch-quick-actions/
class ForceTouchQuickActions {
    static var selectedAction: String?

    struct Types {
        static let ViewAnimations: String  = "view-animations"
        static let ViewMap: String  = "view-map"
        static let ViewImages: String  = "view-images"
        static let ViewMultithreading: String  = "view-multithreading"
    }
}
