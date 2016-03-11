//
//  UIViewsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class UIViewsViewController: UIViewController, UIScrollViewDelegate, AnimatedGifBoxViewDelegate {

    @IBOutlet weak var scrollViewContentOffsetLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var animatedGifBoxView: AnimatedGifBoxView!
    @IBOutlet weak var fetchImageButton: UIButton!
    @IBOutlet weak var fetchedImageUrlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        animatedGifBoxView.delegate = self
        fetchedImageUrlTextField.text = "http://vignette4.wikia.nocookie.net/simpsons/images/9/92/WOOHOO.jpg"
    }
    
    @IBAction func fetchImageButtonPressed(sender: UIButton) {
        PerrFuncs.fetchAndPresentImage(fetchedImageUrlTextField.text)
    }

    deinit {
        📘("...")
    }
    
    // MARK: - AnimatedGifBoxViewDelegate
    func animatedGifBoxView(animatedGiBoxView: AnimatedGifBoxView, durationSliderChanged newValue: Float) {
        self.view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(CGFloat(newValue))
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollViewContentOffsetLabel.text = String(scrollView.contentOffset)
    }

}