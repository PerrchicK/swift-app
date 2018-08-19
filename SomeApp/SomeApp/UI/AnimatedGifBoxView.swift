//
//  AnimatedGifBoxView.swift
//  SomeApp
//
//  Created by Perry on 2/17/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

protocol AnimatedGifBoxViewDelegate: class {
    func animatedGifBoxView(_ animatedGifBoxView: AnimatedGifBoxView, durationSliderChanged newValue:Float)
}

class AnimatedGifBoxView: UIView {
    let ANIMATED_GIF_FILENAME = "running_cat_transparent"

    weak var delegate: AnimatedGifBoxViewDelegate?

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var animatedGifImageView: UIImageView!

    private(set) var isAnimating = false

    override func awakeFromNib() {
        animatedGifImageView.contentMode = .scaleAspectFit
        durationSlider.addTarget(self, action: #selector(AnimatedGifBoxView.durationSliderTouchUp(_:)), for: UIControlEvents.touchUpInside)
        durationSlider.addTarget(self, action: #selector(AnimatedGifBoxView.durationSliderTouchUp(_:)), for: UIControlEvents.touchUpOutside)
        let isBouncing = false
        animatedGifImageView.😘(huggedObject: isBouncing)
        let isNodding = false
        durationLabel.😘(huggedObject: isNodding)
    }
 
    @objc func durationSliderTouchUp(_ sender: UISlider) {
        let isBouncing = animatedGifImageView.😍() as? Bool ?? false
        guard !isBouncing else { return }

        // Refresh image with the new frame rate
        animatedGifImageView.image = UIImage(named: ANIMATED_GIF_FILENAME + ".gif")
        animatedGifImageView.animateBounce() { [weak self] (finished) in
            guard let strongSelf = self else { return }

            let isBouncing = false
            strongSelf.😘(huggedObject: isBouncing)

            strongSelf.animatedGifImageView.image = UIImage.gifWithName(strongSelf.ANIMATED_GIF_FILENAME, frameRate: TimeInterval(strongSelf.durationSlider.value) * 10000.0)
            strongSelf.isAnimating = true
        }
    }
    
    func animateNope() {
        let isNodding = durationLabel.😍() as? Bool ?? false
        guard !isNodding else { return }

        durationLabel.😘(huggedObject: !isNodding)
        // Refresh image with the new frame rate
        durationLabel.animateNo() { [weak self] (isDone) in
            if isDone {
                self?.durationLabel.😘(huggedObject: isNodding) // not done <==> animating || done <==> not animating
            }
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard durationSlider.value > 0.0 && durationSlider.value < 1.0 else { self.animateNope(); return }

        durationLabel.text = String(format: "%.02f", durationSlider.value)
        delegate?.animatedGifBoxView(self, durationSliderChanged: durationSlider.value)
    }
}
