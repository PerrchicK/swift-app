//
//  SomeAnnotationView.swift
//  SomeApp
//
//  Created by Perry on 01/04/2016.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import MapKit

class SomeAnnotationView: MKAnnotationView {
    @IBOutlet weak var annotationIconLabel: UILabel!

    lazy var possibleIcons: [String] = ["😏", "😍", "😜", "😟"]
    private(set) var bDayTimestamp: TimeInterval!

    private var _reuseIdentifier: String?
    override var reuseIdentifier: String? {
        set {
            _reuseIdentifier = newValue
        }
        get {
            return _reuseIdentifier
        }
    }

    override func awakeFromNib() {
        annotationIconLabel.text = generateIcon()
        isUserInteractionEnabled = false
        bDayTimestamp = Date.init().timeIntervalSince1970
    }

    func generateIcon() -> String {
        let randomIndex = 0 ~ possibleIcons.count
        return possibleIcons[randomIndex]
    }
}
