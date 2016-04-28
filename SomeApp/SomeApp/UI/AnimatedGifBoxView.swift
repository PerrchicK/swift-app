//
//  AnimatedGifBoxView.swift
//  SomeApp
//
//  Created by Perry on 2/17/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

protocol AnimatedGifBoxViewDelegate: class {
    func animatedGifBoxView(animatedGifBoxView: AnimatedGifBoxView, durationSliderChanged newValue:Float)
}

class AnimatedGifBoxView: NibView {

    let ANIMATED_GIF_FILENAME = "running_cat_transparent"

    weak var delegate: AnimatedGifBoxViewDelegate?

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var animatedGifImageView: UIImageView!

    private var isAnimating = false

    override func viewDidLoadFromNib() {
        animatedGifImageView.contentMode = .ScaleAspectFit
        durationSlider.addTarget(self, action: #selector(AnimatedGifBoxView.durationSliderTouchUp(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        durationSlider.addTarget(self, action: #selector(AnimatedGifBoxView.durationSliderTouchUp(_:)), forControlEvents: UIControlEvents.TouchUpOutside)

        durationLabel.onClick {_ in 
            UIAlertController.makeAlert(title: "onClick Message", message: "tapped")
                .withAction(UIAlertAction(title: "Cool", style: .Cancel, handler: nil))
                .show()
        }
    }
 
    func durationSliderTouchUp(sender: UISlider) {
        guard !isAnimating else { return }

        isAnimating = true
        // Refresh image with the new frame rate
        animatedGifImageView.image = UIImage(named: ANIMATED_GIF_FILENAME.stringByAppendingString(".gif"))
        animatedGifImageView.animateBounce() { [weak self] (finished) in
            guard let strongSelf = self else { return }

            strongSelf.isAnimating = false
            strongSelf.animatedGifImageView.image = UIImage.gifWithName(strongSelf.ANIMATED_GIF_FILENAME, frameRate: NSTimeInterval(strongSelf.durationSlider.value) * 10000.0)
        }
    }
    
    func animateNope() {
        guard !isAnimating else { return }

        isAnimating = true
        // Refresh image with the new frame rate
        durationLabel.animateNono() { [weak self] (finished) in
            self?.isAnimating = false
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        guard durationSlider.value > 0.0 && durationSlider.value < 1.0 else { self.animateNope(); return }

        durationLabel.text = String(format: "%.02f", durationSlider.value)
        delegate?.animatedGifBoxView(self, durationSliderChanged: durationSlider.value)
    }
}