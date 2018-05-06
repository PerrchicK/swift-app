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
    
    private static let KVO_KEY_PATH_TO_OBSERVE = "constant"
    
    @IBOutlet weak var animatedOutTransitionView: UIView!
    @IBOutlet weak var animatedInTransitionView: UIView!
    @IBOutlet weak var animatedJumpView: UIView!
    @IBOutlet weak var animatedShootedView: UIView!
    @IBOutlet weak var theWallView: UIView!
    // Margin vs. Padding: http://stackoverflow.com/questions/2189452/when-to-use-margin-vs-padding-in-css
    @IBOutlet weak var shootedViewRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentOffsetLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    lazy var animatedGifBoxView: AnimatedGifBoxView = {
        return animatedGifBoxViewXibContainer.contentView as! AnimatedGifBoxView
    }()
    @IBOutlet weak var animatedGifBoxViewXibContainer: XibViewContainer!
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

        configureAnimations()
        configureUi()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // From: https://medium.com/@cjinghong/interactive-animations-in-ios-e3f8e1beb5b0
        if #available(iOS 10.0, *) {
            let cubicTiming = UICubicTimingParameters(animationCurve: .easeOut)
            let animator = UIViewPropertyAnimator(duration: 2.0, timingParameters: cubicTiming)
            animator.addAnimations { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.scrollViewContentOffsetLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            // Instead of animate it automatically...
            //animator.startAnimation()

            // ... Let's use a gesture
            scrollViewContentOffsetLabel.onDrag(predicateClosure: { _ in
                return true
            }, onDragClosure: { [weak self] dragGestureListener in
                guard let superview = self?.view, let draggingPoint = dragGestureListener.pannedPoint else { return }
                
                // 0 ... 0.5 ... 1
                let fractionCompleted = draggingPoint.x / superview.bounds.width
                
                // -0.5 ... 0 ... 0.5
                // let fractionCompleted = draggingPoint.x / superview.bounds.width - 0.5
                animator.fractionComplete = fractionCompleted
            })
            
            let originalY = scrollViewContentOffsetLabel.center.y;
            let flyLowAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: cubicTiming)
            flyLowAnimator.addAnimations { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.scrollViewContentOffsetLabel.center = CGPoint(x: strongSelf.scrollViewContentOffsetLabel.center.x, y: 100)
                strongSelf.scrollViewContentOffsetLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            }
            flyLowAnimator.startAnimation()
            flyLowAnimator.addCompletion({ position in
                let landBackAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: cubicTiming)
                landBackAnimator.addAnimations { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.scrollViewContentOffsetLabel.center = CGPoint(x: strongSelf.scrollViewContentOffsetLabel.center.x, y: originalY)
                    strongSelf.scrollViewContentOffsetLabel.transform = CGAffineTransform(rotationAngle: 0)
                }
                landBackAnimator.startAnimation()
            })
        } else {
            // Fallback on earlier versions - do nothing in this case
        }
        
        scrollViewContentOffsetLabel.onClick { [weak self] _ in
            self?.scheduleAutoScrollTimer()
        }
        
        //MARK: KVO: Adding the observer
        if shootedViewRightMarginConstraint.observationInfo == nil {
            // The 'addObserver' will occur only once...
            shootedViewRightMarginConstraint.addObserver(self, forKeyPath: AnimationsViewController.KVO_KEY_PATH_TO_OBSERVE, options: .new, context: nil)

        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        //MARK: KVO: Comment out this line and see what happens
        shootedViewRightMarginConstraint.removeObserver(self, forKeyPath: AnimationsViewController.KVO_KEY_PATH_TO_OBSERVE)

        // Comment out this line and see what happens (hint: deinit)
        autoScrollTimer?.invalidate()
    }

    func scheduleAutoScrollTimer() {
        if !(autoScrollTimer?.isValid ?? false) {
            autoScrollTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(teaseUserToScroll(_:)), userInfo: nil, repeats: true)
        }
    }

    @objc func teaseUserToScroll(_ timer: Timer) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
        PerrFuncs.runBlockAfterDelay(afterDelay: 0.3) { [weak self] in
            self?.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }

    func configureAnimations() {
        animatedGifBoxView.delegate = self

        weak var weakSelf: AnimationsViewController? = self
        animatedOutTransitionView.onClick { _ in
            guard let strongSelf = weakSelf else { return }
            
            let transition = CATransition()
            transition.startProgress = 0
            transition.endProgress = 1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            transition.duration = 0.5
            
            // Add the transition animation to both layers
            strongSelf.animatedOutTransitionView.layer.add(transition, forKey: "transition")
            strongSelf.animatedInTransitionView.layer.add(transition, forKey: "transition")
            
            // Finally, change the visibility of the layers.
            strongSelf.animatedOutTransitionView.toggleVisibility()
            strongSelf.animatedInTransitionView.toggleVisibility()
        }

        animatedOutTransitionView.onLongPress({ [weak self] (longPressGestureRecognizer) in
            if longPressGestureRecognizer.state == .began {
                self?.flipViews(true)
            }
        })

        animatedInTransitionView.onClick { [weak self] (tapGestureRecognizer) in
            guard let strongSelf = self else { return }

            let transition = CATransition()
            transition.startProgress = 0
            transition.endProgress = 1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.duration = 0.5
            
            // Add the transition animation to both layers
            strongSelf.animatedOutTransitionView.layer.add(transition, forKey: "transition")
            strongSelf.animatedInTransitionView.layer.add(transition, forKey: "transition")
            
            // Finally, change the visibility of the layers.
            strongSelf.animatedOutTransitionView.toggleVisibility()
            strongSelf.animatedInTransitionView.toggleVisibility()
        }

        animatedInTransitionView.onLongPress({ [weak self] (longPressGestureRecognizer) in
            if longPressGestureRecognizer.state == .began {
                self?.flipViews(true)
            }
        })
        
        animatedJumpView.onClick { [weak self] (tapGestureRecognizer) in
            guard let strongSelf = self else { return }

            let upAndDownAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            upAndDownAnimation.values = [0, 100]
            upAndDownAnimation.autoreverses = true
            upAndDownAnimation.duration = 1 // it doesn't matter because it will soon be grouped
            upAndDownAnimation.repeatCount = 2
            upAndDownAnimation.isCumulative = true // Continue from the current point
            upAndDownAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]

            let rightToLeftAnimation = CABasicAnimation(keyPath: "position.x")
            rightToLeftAnimation.fromValue = strongSelf.animatedJumpView.center.x
            rightToLeftAnimation.toValue = strongSelf.animatedJumpView.center.x - strongSelf.view.frame.width

            rightToLeftAnimation.duration = 4

            // Composite pattern, it's an animation that includes a group of animations
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [upAndDownAnimation, rightToLeftAnimation]
            animationGroup.duration = 4
            animationGroup.delegate = self // will this compile?

            strongSelf.animatedJumpView.layer.add(animationGroup, forKey: "jumpAnimation")
        }

        animatedShootedView.onClick { [weak self] (tapGestureRecognizer) in
            UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self?.shootedViewRightMarginConstraint.constant += 70
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        animatedImageView.onClick { [weak self] (tapGestureRecognizer) in
            if self?.animatedImageView.animationImages == nil {
                var frames = [UIImage]()
                for imageIndex in 0...9 {
                    let frame = UIImage(named: "hulk-and-thor-frame-\(imageIndex).gif")!
                    frames.append(frame)
                }
                self?.animatedImageView.animationImages = frames
                self?.animatedImageView.animationDuration = 0.9
                self?.animatedImageView.startAnimating()
                self?.animatedImageView.animationRepeatCount = 1
            } else if self?.animatedImageView.isAnimating ?? false {
                self?.animatedImageView.stopAnimating()
            } else {
                self?.animatedImageView.startAnimating()
            }
        }

        animatedImageView.onLongPress { [weak self] (longPressGestureRecognizer) in
            self?.animatedImageView.animateFade(fadeIn: false)
        }
        theWallView.onLongPress { [weak self] (longPressGestureRecognizer) in
            self?.theWallView.animateFade(fadeIn: false)
        }

        theWallView.onClick { [weak self] (tapGestureRecognizer) in
            guard let strongSelf = self else { return }

            strongSelf.wallGravityAnimator = UIDynamicAnimator(referenceView: strongSelf.scrollView) // Must be the top reference view
            strongSelf.wallGravityBehavior = UIGravityBehavior(items: [strongSelf.theWallView])
            strongSelf.wallGravityAnimator.addBehavior(strongSelf.wallGravityBehavior)
            strongSelf.wallCollision = UICollisionBehavior(items: [strongSelf.theWallView, strongSelf.animatedImageView])
            strongSelf.wallCollision.translatesReferenceBoundsIntoBoundary = true
            strongSelf.wallGravityAnimator.addBehavior(strongSelf.wallCollision)
        }
    }

    func flipViews(_ fromRight: Bool) {
        UIView.transition(with: self.animatedOutTransitionView, duration: 0.5, options: fromRight ? .transitionFlipFromRight : .transitionFlipFromLeft, animations: { [weak self] in
            self?.animatedOutTransitionView.toggleVisibility()
        }, completion: nil)
        
        UIView.transition(with: self.animatedInTransitionView, duration: 0.5, options: fromRight ? .transitionFlipFromRight : .transitionFlipFromLeft, animations: { [weak self] in
            self?.animatedInTransitionView.toggleVisibility()
        }, completion: nil)
    }
    
    // KVO (key value observation)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? CGFloat, let changedObject = object as? NSLayoutConstraint, changedObject == shootedViewRightMarginConstraint && keyPath == AnimationsViewController.KVO_KEY_PATH_TO_OBSERVE {
            if newValue > self.view.frame.width {
                UIView.animate(withDuration: 0.5, animations: {
                    self.shootedViewRightMarginConstraint.constant = 10
                    self.view.layoutIfNeeded()
                }) 
            }
        }
    }

    func configureUi() {
        fetchImageButton.onPan { [weak self] (panGestureRecognizer) in
            guard let strongSelf = self else { return }

            if let superview = panGestureRecognizer.view?.superview {
                let locationOfTouch = panGestureRecognizer.location(in: superview)
                📘(locationOfTouch)
                strongSelf.scrollView.contentOffset = locationOfTouch
            }
        }

        scrollView.keyboardDismissMode = .interactive
        fetchedImageUrlTextField.text = "http://vignette4.wikia.nocookie.net/simpsons/images/9/92/WOOHOO.jpg"

        animatedJumpView.layer.cornerRadius = animatedJumpView.frame.width / 2
        animatedShootedView.layer.cornerRadius = animatedShootedView.frame.width / 2

        animatedOutTransitionView.layer.cornerRadius = 5
        animatedInTransitionView.layer.cornerRadius = 5
        animatedInTransitionView.isHidden = true
    }
    
    @IBAction func fetchImageButtonPressed(_ sender: UIButton) {
        PerrFuncs.fetchAndPresentImage(fetchedImageUrlTextField.text)
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
            //scheduleAutoScrollTimer()
        }
    }
    
    deinit {
        📘("I'm dead 💀")
    }
}
