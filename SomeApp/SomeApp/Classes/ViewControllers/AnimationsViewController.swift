//
//  AnimationsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class AnimationsViewController: UIViewController, UIScrollViewDelegate, CAAnimationDelegate, AnimatedGifBoxViewDelegate {
    
    @IBOutlet weak var animatedOutTransitionView: UIView!
    @IBOutlet weak var animatedInTransitionView: UIView!
    @IBOutlet weak var animatedJumpView: UIView!
    @IBOutlet weak var animatedShootedView: UIView!
    @IBOutlet weak var theWallView: UIView!
    // Margin vs. Padding: http://stackoverflow.com/questions/2189452/when-to-use-margin-vs-padding-in-css
    @IBOutlet weak var shootedViewRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentOffsetLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var animatedGifBoxView: AnimatedGifBoxView!
    @IBOutlet weak var animatedImageView: UIImageView!
    @IBOutlet weak var fetchImageButton: UIButton!
    @IBOutlet weak var fetchedImageUrlTextField: UITextField!
    // https://www.raywenderlich.com/50197/uikit-dynamics-tutorial
    var wallGravityAnimator: UIDynamicAnimator!
    var wallGravityBehavior: UIGravityBehavior!
    var wallCollision: UICollisionBehavior!

    var autoScrollTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        animatedGifBoxView.delegate = self
        fetchedImageUrlTextField.text = "http://vignette4.wikia.nocookie.net/simpsons/images/9/92/WOOHOO.jpg"

        configureAnimations()
        configureUi()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scheduleAutoScrollTimer()
    }

    func scheduleAutoScrollTimer() {
        if !(autoScrollTimer?.isValid ?? false) {
            autoScrollTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(teaseUserToScroll(_:)), userInfo: nil, repeats: true)
        }
    }

    func teaseUserToScroll(_ timer: Timer) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
        runBlockAfterDelay(afterDelay: 0.3) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }

    func configureAnimations() {
        animatedOutTransitionView.onClick { (tapGestureRecognizer) in
            let transition = CATransition()
            transition.startProgress = 0
            transition.endProgress = 1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            transition.duration = 0.5
            
            // Add the transition animation to both layers
            self.animatedOutTransitionView.layer.add(transition, forKey: "transition")
            self.animatedInTransitionView.layer.add(transition, forKey: "transition")
            
            // Finally, change the visibility of the layers.
            self.animatedOutTransitionView.toggleVisibility()
            self.animatedInTransitionView.toggleVisibility()
        }

        animatedOutTransitionView.onLongPress({ (longPressGestureRecognizer) in
            if longPressGestureRecognizer.state == .began {
                self.flipViews(true)
            }
        })

        animatedInTransitionView.onClick { (tapGestureRecognizer) in
            let transition = CATransition()
            transition.startProgress = 0
            transition.endProgress = 1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.duration = 0.5
            
            // Add the transition animation to both layers
            self.animatedOutTransitionView.layer.add(transition, forKey: "transition")
            self.animatedInTransitionView.layer.add(transition, forKey: "transition")
            
            // Finally, change the visibility of the layers.
            self.animatedOutTransitionView.toggleVisibility()
            self.animatedInTransitionView.toggleVisibility()
        }

        animatedInTransitionView.onLongPress({ (longPressGestureRecognizer) in
            if longPressGestureRecognizer.state == .began {
                self.flipViews(true)
            }
        })
        
        animatedJumpView.onClick { (tapGestureRecognizer) in
            let upAndDownAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            upAndDownAnimation.values = [0, 100]
            upAndDownAnimation.autoreverses = true
            upAndDownAnimation.duration = 1 // it doesn't matter because it will soon be grouped
            upAndDownAnimation.repeatCount = 2
            upAndDownAnimation.isCumulative = true // Continue from the current point
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

            self.animatedJumpView.layer.add(animationGroup, forKey: "jumpAnimation")
        }

        animatedShootedView.onClick { (tapGestureRecognizer) in
            UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.shootedViewRightMarginConstraint.constant += 70
                self.view.layoutIfNeeded()
            }, completion: nil)
        }

        animatedImageView.onClick { (tapGestureRecognizer) in
            if self.animatedImageView.animationImages == nil {
                var frames = [UIImage]()
                for imageIndex in 0...9 {
                    let frame = UIImage(named: "hulk-and-thor-frame-\(imageIndex).gif")!
                    frames.append(frame)
                }
                self.animatedImageView.animationImages = frames
                self.animatedImageView.animationDuration = 0.9
                self.animatedImageView.startAnimating()
                self.animatedImageView.animationRepeatCount = 1
            } else if self.animatedImageView.isAnimating {
                self.animatedImageView.stopAnimating()
            } else {
                self.animatedImageView.startAnimating()
            }
        }

        animatedImageView.onLongPress { (longPressGestureRecognizer) in
            self.animatedImageView.animateFade(fadeIn: false)
        }
        theWallView.onLongPress { (longPressGestureRecognizer) in
            self.theWallView.animateFade(fadeIn: false)
        }

        shootedViewRightMarginConstraint.addObserver(self, forKeyPath: "constant", options: .new, context: nil)

        theWallView.onClick { (tapGestureRecognizer) in
            self.wallGravityAnimator = UIDynamicAnimator(referenceView: self.scrollView) // Must be the top reference view
            self.wallGravityBehavior = UIGravityBehavior(items: [self.theWallView])
            self.wallGravityAnimator.addBehavior(self.wallGravityBehavior)
            self.wallCollision = UICollisionBehavior(items: [self.theWallView, self.animatedImageView])
            self.wallCollision.translatesReferenceBoundsIntoBoundary = true
            self.wallGravityAnimator.addBehavior(self.wallCollision)
        }
    }

    func flipViews(_ fromRight: Bool) {
        UIView.transition(with: self.animatedOutTransitionView, duration: 0.5, options: fromRight ? .transitionFlipFromRight : .transitionFlipFromLeft, animations: {
            self.animatedOutTransitionView.toggleVisibility()
            }, completion: nil)
        
        UIView.transition(with: self.animatedInTransitionView, duration: 0.5, options: fromRight ? .transitionFlipFromRight : .transitionFlipFromLeft, animations: {
            self.animatedInTransitionView.toggleVisibility()
            }, completion: nil)
    }
    
    // KVO (key value observation)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? CGFloat, let changedObject = object as? NSLayoutConstraint, changedObject == shootedViewRightMarginConstraint && keyPath == "constant" {
            if newValue > self.view.frame.width {
                UIView.animate(withDuration: 0.5, animations: {
                    self.shootedViewRightMarginConstraint.constant = 10
                    self.view.layoutIfNeeded()
                }) 
            }
        }
    }

    func configureUi() {
        animatedJumpView.layer.cornerRadius = animatedJumpView.frame.width / 2
        animatedShootedView.layer.cornerRadius = animatedShootedView.frame.width / 2

        animatedOutTransitionView.layer.cornerRadius = 5
        animatedInTransitionView.layer.cornerRadius = 5
        animatedInTransitionView.isHidden = true
    }
    
    @IBAction func fetchImageButtonPressed(_ sender: UIButton) {
        PerrFuncs.fetchAndPresentImage(fetchedImageUrlTextField.text)
    }

    deinit {
        📘("...")
    }
    
    // MARK: - AnimatedGifBoxViewDelegate
    func animatedGifBoxView(_ animatedGiBoxView: AnimatedGifBoxView, durationSliderChanged newValue: Float) {
        let cgFloatValue = CGFloat(newValue)
        self.view.backgroundColor = UIColor(hue: cgFloatValue, saturation: cgFloatValue, brightness: 0.5, alpha: 1)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentlyActiveGestureRecognizersCount = scrollView.gestureRecognizers?.filter({ [.began, .changed].contains($0.state) }).count ?? 0
        let isOperatedByUser = currentlyActiveGestureRecognizersCount > 0
        if isOperatedByUser {
            // Disable "teasing"
            autoScrollTimer?.invalidate()
        }

        self.scrollViewContentOffsetLabel.text = String(format: "(%.1f,%.1f)", scrollView.contentOffset.x, scrollView.contentOffset.y)
        if scrollView.contentOffset.y == 0 {
            scheduleAutoScrollTimer()
        }
    }
}
