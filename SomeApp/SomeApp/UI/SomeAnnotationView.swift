//
//  SomeAnnotationView.swift
//  SomeApp
//
//  Created by Perry on 01/04/2016.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import MapKit

class SomeAnnotationView: NibView {
    @IBOutlet weak var annotationIconLabel: UILabel!
    let possibleIcons = ["😏", "😍", "😜", "😟"]

    override func viewDidLoadFromNib() {
        annotationIconLabel.text = generateIcon()
    }

    func generateIcon() -> String {
        return possibleIcons[random() % possibleIcons.count]
    }
}