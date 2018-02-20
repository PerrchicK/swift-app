//
//  SomeAnnotationView.swift
//  SomeApp
//
//  Created by Perry on 01/04/2016.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import MapKit

class SomeAnnotationView: UIView {
    @IBOutlet weak var annotationIconLabel: UILabel!
    lazy var possibleIcons: [String] = ["😏", "😍", "😜", "😟"]

    override func awakeFromNib() {
        annotationIconLabel.text = generateIcon()
        isUserInteractionEnabled = false
    }

    func generateIcon() -> String {
        let randomIndex = 0 ~ possibleIcons.count
        return possibleIcons[randomIndex]
    }
}
