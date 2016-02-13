//
//  AnimationsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class AnimationsViewController: UIViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        PerrFuncs.fetchAndPresentImage("http://vignette4.wikia.nocookie.net/simpsons/images/9/92/WOOHOO.jpg")
    }
}