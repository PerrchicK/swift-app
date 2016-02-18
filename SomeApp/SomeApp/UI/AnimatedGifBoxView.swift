//
//  AnimatedGifBoxView.swift
//  SomeApp
//
//  Created by Perry on 2/17/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class AnimatedGifBoxView: NibView {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var animatedGifImageView: UIImageView!

    override func viewContentsDidLoadFromNib() {
        durationLabel.text = String(format: "%.02f", durationSlider.value)
        animatedGifImageView.image = UIImage.gifWithName("running_cat")
        animatedGifImageView.contentMode = .ScaleAspectFit
        durationLabel.onClick {
            UIAlertController.make(title: "onClick Message", message: "tapped").withAction(UIAlertAction(title: "Cool", style: .Cancel, handler: nil)).show()
        }
    }
 
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        durationLabel.text = String(format: "%.02f", sender.value)
    }
}