//
//  GameNavigationController.swift
//  SomeApp
//
//  Created by Perry on 31/08/2017.
//  Copyright © 2017 PerrchicK. All rights reserved.
//

import UIKit

class GameNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portraitUpsideDown
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    deinit {
        📘("💀: I'm dead")
    }
}
