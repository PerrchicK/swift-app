//
//  AnimationsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class AnimationsViewController: UIViewController, UIScrollViewDelegate, AnimatedGifBoxViewDelegate {

    @IBOutlet weak var animatedOutTransitionView: UIView!
    @IBOutlet weak var animatedInTransitionView: UIView!
    @IBOutlet weak var animatedJumpView: UIView!
    @IBOutlet weak var animatedShootedView: UIView!
    // Margin vs. Padding: http://stackoverflow.com/questions/2189452/when-to-use-margin-vs-padding-in-css
    @IBOutlet weak var shootedViewRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentOffsetLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var animatedGifBoxView: AnimatedGifBoxView!
    @IBOutlet weak var fetchImageButton: UIButton!
    @IBOutlet weak var fetchedImageUrlTextField: UITextField!

    var autoScrollTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        animatedGifBoxView.delegate = self
        fetchedImageUrlTextField.text = "http://vignette4.wikia.nocookie.net/simpsons/images/9/92/WOOHOO.jpg"

        configureAnimations()
        configureUi()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        autoScrollTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(teaseUserToScroll(_:)), userInfo: nil, repeats: true)
    }

    func teaseUserToScroll(timer: NSTimer) {
        scrollView.setContentOffset(CGPointMake(0, -50), animated: true)
        runBlockAfterDelay(afterDelay: 0.3) {
            self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        }
    }

    func configureAnimations() {
        animatedOutTransitionView.onClick { (tapGestureRecognizer) in
            let transition = CATransition() // A subclass of CAAnimation
            transition.startProgress = 0
            transition.endProgress = 1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            transition.duration = 0.5
            
            // Add the transition animation to both layers
            self.animatedOutTransitionView.layer.addAnimation(transition, forKey: "transition")
            self.animatedInTransitionView.layer.addAnimation(transition, forKey: "transition")
            
            // Finally, change the visibility of the layers.
            self.animatedOutTransitionView.toggleVisibility()
            self.animatedInTransitionView.toggleVisibility()
        }

        animatedInTransitionView.onClick { (tapGestureRecognizer) in
            let transition = CATransition()
            transition.startProgress = 0
            transition.endProgress = 1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.duration = 0.5
            
            // Add the transition animation to both layers
            self.animatedOutTransitionView.layer.addAnimation(transition, forKey: "transition")
            self.animatedInTransitionView.layer.addAnimation(transition, forKey: "transition")
            
            // Finally, change the visibility of the layers.
            self.animatedOutTransitionView.toggleVisibility()
            self.animatedInTransitionView.toggleVisibility()
        }

        animatedJumpView.onClick { (tapGestureRecognizer) in
            let upAndDownAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            upAndDownAnimation.values = [0, 100]
            upAndDownAnimation.autoreverses = true
            upAndDownAnimation.duration = 1 // it doesn't matter because it will soon be grouped
            upAndDownAnimation.repeatCount = 2
            upAndDownAnimation.cumulative = true // Continue from the current point
            upAndDownAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]

            let rightToLeftAnimation = CABasicAnimation(keyPath: "position.x")
            rightToLeftAnimation.fromValue = self.animatedJumpView.center.x
            rightToLeftAnimation.toValue = self.animatedJumpView.center.x - self.view.frame.width

            rightToLeftAnimation.duration = 4

            // Composite pattern, it's an animation that includes a group of animations
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [upAndDownAnimation, rightToLeftAnimation]
            animationGroup.duration = 4
            animationGroup.delegate = self

            self.animatedJumpView.layer.addAnimation(animationGroup, forKey: "jumpAnimation")
        }

        animatedShootedView.onClick { (tapGestureRecognizer) in
            UIView.animateWithDuration(0.8, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .CurveEaseOut, animations: {
                self.shootedViewRightMarginConstraint.constant += 70
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                if self.shootedViewRightMarginConstraint.constant > self.view.frame.width {
                    UIView.animateWithDuration(0.5, animations: {
                        self.shootedViewRightMarginConstraint.constant = 10
                        self.view.layoutIfNeeded()
                    })
                }
            })
        }
    }
    
    func configureUi() {
        animatedJumpView.layer.cornerRadius = animatedJumpView.frame.width / 2
        animatedShootedView.layer.cornerRadius = animatedShootedView.frame.width / 2

        animatedOutTransitionView.layer.cornerRadius = 5
        animatedInTransitionView.layer.cornerRadius = 5
        animatedInTransitionView.hidden = true
    }
    
    @IBAction func fetchImageButtonPressed(sender: UIButton) {
        PerrFuncs.fetchAndPresentImage(fetchedImageUrlTextField.text)
    }

    deinit {
        📘("...")
    }
    
    // MARK: - AnimatedGifBoxViewDelegate
    func animatedGifBoxView(animatedGiBoxView: AnimatedGifBoxView, durationSliderChanged newValue: Float) {
        let cgFloatValue = CGFloat(newValue)
        self.view.backgroundColor = UIColor(hue: cgFloatValue, saturation: cgFloatValue, brightness: 0.5, alpha: 1)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.gestureRecognizers?.filter ({ [.Began, .Changed].contains($0.state) } ).count > 0 {
            autoScrollTimer?.invalidate()
        }
        self.scrollViewContentOffsetLabel.text = String(scrollView.contentOffset)
    }
}