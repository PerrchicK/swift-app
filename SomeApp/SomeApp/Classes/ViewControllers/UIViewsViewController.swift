//
//  UIViewsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class UIViewsViewController: UIViewController, AnimatedGifBoxViewDelegate {

    @IBOutlet weak var animatedGifBoxView: AnimatedGifBoxView!
    @IBOutlet weak var fetchImageButton: UIButton!
    @IBOutlet weak var fetchedImageUrlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animatedGifBoxView.delegate = self
        animatedGifBoxView.backgroundColor = UIColor.clearColor()

        fetchedImageUrlTextField.text = "http://vignette4.wikia.nocookie.net/simpsons/images/9/92/WOOHOO.jpg"
    }
    
    func animatedGifBoxView(animatedGiBoxView: AnimatedGifBoxView, durationSliderChanged newValue: Float) {
        self.view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(CGFloat(newValue))
    }

    @IBAction func fetchImageButtonPressed(sender: UIButton) {
        PerrFuncs.fetchAndPresentImage(fetchedImageUrlTextField.text)
    }

    deinit {
    }
}