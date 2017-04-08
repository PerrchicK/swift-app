//
//  PerrFuncs.swift
//  SomeApp
//
//  Created by Perry on 2/12/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import ObjectiveC

// MARK: - "macros"

public typealias CompletionClosure = ((AnyObject?) -> Void)

func WIDTH(_ frame: CGRect?) -> CGFloat { return frame == nil ? 0 : (frame?.size.width)! }
func HEIGHT(_ frame: CGRect?) -> CGFloat { return frame == nil ? 0 : (frame?.size.height)! }

public func 📘(_ logMessage: String, file:String = #file, function:String = #function, line:Int = #line) {
    let formattter = DateFormatter()
    formattter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    let timesamp = formattter.string(from: Date())

    print("〈\(timesamp)〉\(file.components(separatedBy: "/").last!) ➤ \(function.components(separatedBy: "(").first!) (\(line)): \(logMessage)")
}

// MARK: - Global Methods

// dispatch block on main queue
public func runOnUiThread(afterDelay seconds: Double = 0.0, block: @escaping ()->()) {
    runBlockAfterDelay(afterDelay: seconds, block: block)
}

// runClosureAfterDelay
public func runBlockAfterDelay(afterDelay seconds: Double = 0.0, onQueue: DispatchQueue = DispatchQueue.main, block: @escaping ()->()) {
        let delayTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) // 2 seconds delay before retry
        onQueue.asyncAfter(deadline: delayTime, execute: block)
}

public func className(_ aClass: AnyClass) -> String {
    let className = NSStringFromClass(aClass)
    let components = className.components(separatedBy: ".")
    
    if components.count > 0 {
        return components.last!
    } else {
        return className
    }
}

// MARK: - Class

open class PerrFuncs: NSObject {
    // Computed static variables will act as lazy variables
    static var sharedInstance: PerrFuncs = {
        return PerrFuncs()
    }()

    fileprivate override init() {
        super.init()
    }
    
    lazy var imageContainer: UIView = {
        let container = UIView(frame: UIScreen.main.bounds)
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // To be a target, it must be an NSObject instance
        container.onClick() {_ in 
            self.removeImage()
        }

        return container
    }()

    func removeImage() {
        imageContainer.animateFade(fadeIn: false, duration: 0.5) { (doneSuccessfully) in
            self.imageContainer.removeAllSubviews()
            self.imageContainer.removeFromSuperview()
        }
    }

    class func shareImage(_ sharedImage: UIImage, completionClosure: @escaping UIActivityViewControllerCompletionWithItemsHandler) {
        let activityViewController = UIActivityViewController(activityItems: [SharingTextSource(), SharingImageSource(image: sharedImage)], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = completionClosure
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        
        UIApplication.mostTopViewController()?.present(activityViewController, animated: true, completion: nil)
    }

    class func fetchAndPresentImage(_ imageUrl: String?) {
        guard let imageUrl = imageUrl, imageUrl.length() > 0,
            let app = UIApplication.shared.delegate as? AppDelegate,
            let window = app.window
            else { return }
        
        📘("fetching \(imageUrl)")

        let loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadingSpinner.startAnimating()
        sharedInstance.imageContainer.addSubview(loadingSpinner)
        loadingSpinner.pinToSuperViewCenter()
        sharedInstance.imageContainer.animateFade(fadeIn: true, duration: 0.5)
        
        window.addSubview(sharedInstance.imageContainer)
        sharedInstance.imageContainer.stretchToSuperViewEdges()

        let screenWidth = WIDTH(window.frame) //Or: UIScreen.mainScreen().bounds.width
        UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenWidth)).fetchImage(withUrl: imageUrl) { (imageView) in
            if let imageView = imageView as? UIImageView, imageView.image != nil {
                sharedInstance.imageContainer.addSubview(imageView)
                imageView.isUserInteractionEnabled = false
                imageView.pinToSuperViewCenter()
            } else {
                sharedInstance.removeImage()
            }
        }
    }
}

extension String {
    func length() -> Int {
        return self.characters.count
    }

    func toEmoji() -> String {
        // "Hard" guard
        assert(self.length() > 0, "Cannot make emoji from an empty string")
        guard self.length() > 0 else { return self }
        
        var emoji = ""
        
        switch self {

            // Just for fun
        case "yo":
            emoji = "👋🏻"
        case "ahalan":
            emoji = "👋🏾"
        case "ok":
            emoji = "👌"
        case "victory":
            fallthrough
        case "peace":
            emoji = "✌🏽"

            // Icons for menu titles
        case "UI":
            emoji = "👋🏻"
        case "Communication & Location":
        emoji = "🌏"
        case "GCD & Multithreading":
        emoji = "🚦"
        case "Notifications":
            emoji = "👻"
        case "Persistence & Data":
            emoji = "📂"
        case "Views & Animations":
            emoji = "👀"
        case "Operators Overloading":
            emoji = "🔧"
        case "Collection View":
            emoji = "📚"
        case "Images & Core Motion":
            emoji = "📷"

        default:
            📘("Error: Couldn't find emoji for string '\(self)'")
            break
        }
        
        📘("string to emoji: \(self) -> \(emoji)")
        
        return emoji
    }
}

extension UIImage {
    static func fetchImage(withUrl urlString: String, completionClosure: CompletionClosure?) {
        guard let url = URL(string: urlString) else { completionClosure?(nil); return }

        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        // Run on background thread:
        backgroundQueue.async {
            var image: UIImage? = nil
            
            // No matter what, make the callback call on the main thread:
            defer {
                // Run on UI thread:
                DispatchQueue.main.async {
                    completionClosure?(image)
                }
            }

            // The most (and inefficient) simple way to download a photo from the web (no timeout, error handling etc.)
            do {
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
            } catch let error {
                print("Failed to fetch image from url: \(url)\nwith error: \(error)")
            }
        }
    }
}

extension UIImageView {
    func fetchImage(withUrl urlString: String, completionClosure: CompletionClosure?) {
        guard urlString.length() > 0 else { completionClosure?(nil); return }

        UIImage.fetchImage(withUrl: urlString) { (image) in
            defer {
                DispatchQueue.main.async {
                    completionClosure?(self)
                }
            }

            guard let image = image as? UIImage else { return }

            self.image = image
            self.contentMode = .scaleAspectFit
        }
    }
}

//MARK: - Global Extensions

// Declare a global var to produce a unique address as the assoc object handle
var SompApplicationBelovedProperty: UInt8 = 0

infix operator &* { associativity left precedence 140 }

extension NSObject { // try extending 'AnyObject'...
    /**
     Attaches any object to this NSObject.
     This enables the same idea of user info, to every object that inherits from NSObject.
     */
    func 😘(belovedObject: AnyObject) throws -> Bool {
        //infix operator 😘 { associativity left precedence 140 }
        📘("loving \(belovedObject)")
        
        objc_setAssociatedObject(self, &SompApplicationBelovedProperty, belovedObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return true
    }
    
    func 😍() -> AnyObject? { // 1
        guard let value = objc_getAssociatedObject(self, &SompApplicationBelovedProperty) else {
            return nil
        }
        
        return value as AnyObject?
    }
}

extension UIViewController {
    func mostTopViewController() -> UIViewController {
        guard let topController = self.presentedViewController else { return self }

        return topController.mostTopViewController()
    }
}

extension UIApplication {
    static func mostTopViewController() -> UIViewController? {
        guard let topController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        return topController.mostTopViewController()
    }
}

extension UIAlertController {

    /**
     Dismisses the current alert (if presented) and pops up the new one
     */
    func show() {
        guard let mostTopViewController = UIApplication.mostTopViewController() else { 📘("Failed to present alert [title: \(self.title), message: \(self.message)]"); return }
        if mostTopViewController is UIAlertController { // Prevents a horrible bug, also promising the invocation of 'viewWillDisappear' in 'CommonViewController'
            // 1. Dismiss the alert
            mostTopViewController.dismiss(animated: true, completion: {
                // 2. Then present fullscreen
                UIApplication.mostTopViewController()?.present(self, animated: true, completion: nil)
            })
        } else {
            mostTopViewController.present(self, animated: true, completion: nil)
        }
    }

    func withAction(_ action: UIAlertAction) -> UIAlertController {
        self.addAction(action)
        return self
    }

    func withInputText(_ textFieldToAdd: inout UITextField, configurationBlock: @escaping ((_ textField: inout UITextField) -> Void)) -> UIAlertController {
        self.addTextField(/*configurationHandler: */ configurationHandler: { (textField: UITextField!) -> Void in
//            textFieldToAdd = textField
//            configurationBlock(&textFieldToAdd)
        })
        return self
    }
    
    static func makeAlert(title: String, message: String, dismissButtonTitle:String = "OK") -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        return alertController
    }

    /**
     A service method that alerts with title and message in the top view controller
     
     - parameter title: The title of the UIAlertView
     - parameter message: The message inside the UIAlertView
     */
    static func alert(title: String, message: String, dismissButtonTitle:String = "OK", onGone: (() -> Void)? = nil) {
        UIAlertController.makeAlert(title: title, message: message).withAction(UIAlertAction(title: dismissButtonTitle, style: UIAlertActionStyle.cancel, handler: { (alertAction) -> Void in
            onGone?()
        })).show()
    }
}

extension UIViewController {
    
    class func instantiate(storyboardName: String? = nil) -> Self {
        return instantiateFromStoryboardHelper(storyboardName)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T: UIViewController>(_ storyboardName: String?) -> T {
        let storyboard = storyboardName != nil ? UIStoryboard(name: storyboardName!, bundle: nil) : UIStoryboard(name: "Main", bundle: nil)
        let identifier = NSStringFromClass(T).components(separatedBy: ".").last!
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return controller
    }
}

let DEFAULT_ANIMATION_DURATION = TimeInterval(1)
let ANIMATION_NO_KEY = "noAnimation"
extension UIView: CAAnimationDelegate {
    /**
     Hides the view if it's shown.
     Shows the view if it's hidden.
     */
    func toggleVisibility() {
        self.show(show: !self.shown)
    }

    // MARK: - Animations
    func animateScaleAndFadeOut(_ completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            // Core Graphics Affine Transformation: https://en.wikipedia.org/wiki/Affine_transformation
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.alpha = 0.0
        }, completion: { (completed) -> Void in
            completion?(completed)
        })
    }

    public func animateBounce(_ completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { [weak self] () -> () in
            self?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (succeeded) -> Void in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.curveEaseOut   , animations: { [weak self] () -> Void in
                self?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (succeeded) -> Void in
                completion?(succeeded)
            }
        }
    }

    public func animateNo(_ completion: CompletionClosure? = nil) {
        let noAnimation = CAKeyframeAnimation()
        noAnimation.keyPath = "position.x"
        
        noAnimation.values = [0, 10, -10, 10, 0]
        let keyTimes: [NSNumber] = [0, NSNumber(value: Float(1.0 / 6.0)), NSNumber(value: Float(3.0 / 6.0)), NSNumber(value: Float(5.0 / 6.0)), 1]
        noAnimation.keyTimes = keyTimes
        noAnimation.duration = 0.4
        
        noAnimation.isAdditive = true
        noAnimation.delegate = self
        noAnimation.isRemovedOnCompletion = false

        if completion != nil {
            let attachedClosureWrapper = CompletionClosureWrapper(closure: completion!)
            objc_setAssociatedObject(self, &CompletionClosureWrapper.completionClosureProperty, attachedClosureWrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }

        self.layer.add(noAnimation, forKey: ANIMATION_NO_KEY) // shake animation

        // another implementation without using CAKeyframeAnimation:
        /*
        let originX = self.frame.origin.x

        UIView.animateWithDuration(0.1, animations: { [weak self] () -> Void in
            self?.frame.origin.x = originX - 10
        }, completion: { (done) in
            UIView.animateWithDuration(0.1, animations: { [weak self] () -> Void in
                self?.frame.origin.x = originX + 10
            }, completion: { (done) in
                UIView.animateWithDuration(0.05, animations: { [weak self] () -> Void in
                    self?.frame.origin.x = originX
                }, completion: { (done) in
                    completion?(done)
                })
            })
        })
         */
    }

    public func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        if self.layer.animation(forKey: ANIMATION_NO_KEY) == animation {
            guard let attachedClosureWrapper = objc_getAssociatedObject(self, &CompletionClosureWrapper.completionClosureProperty) as? CompletionClosureWrapper else { return }
            attachedClosureWrapper.closure(flag as AnyObject?)
            self.layer.removeAnimation(forKey: ANIMATION_NO_KEY)
        }
    }

    public func animateMoveCenterTo(x: CGFloat, y: CGFloat, duration: TimeInterval = DEFAULT_ANIMATION_DURATION, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.center.x = x
            self.center.y = y
        }, completion: completion)
    }
    
    public func animateZoom(zoomIn: Bool, duration: TimeInterval = DEFAULT_ANIMATION_DURATION, completion: ((Bool) -> Void)? = nil) {
        if zoomIn {
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        UIView.animate(withDuration: duration, animations: { () -> Void in
            if zoomIn {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } else {
                self.frame.size = CGSize(width: 0.0, height: 0.0)
            }
            }, completion: { (finished) in
                self.show(show: zoomIn)
                completion?(finished)
        }) 
    }
    
    public func animateFade(fadeIn: Bool, duration: TimeInterval = DEFAULT_ANIMATION_DURATION, completion: ((Bool) -> Void)? = nil) {
        // Skip redundant calls
        guard (fadeIn == false && (alpha > 0 || isHidden == false)) || (fadeIn == true && (alpha == 0 || isHidden == true)) else { return }

        self.alpha = fadeIn ? 0.0 : 1.0
        self.show(show: true)
        UIView.animate(withDuration: duration, animations: {// () -> Void in
            self.alpha = fadeIn ? 1.0 : 0.0
            }, completion: { (finished) in
                self.show(show: fadeIn)
                completion?(finished)
        }) 
    }
    
    // MARK: - Property setters-like methods

    // Computed variable
    var shown: Bool {
        return !self.isHidden
    }

    public func show(show: Bool, faded: Bool = false) {
        if faded {
            animateFade(fadeIn: show)
        } else {
            self.isHidden = !show
        }
    }
    
    // MARK: - Property setters-like methods

    /**
    Recursively remove all receiver’s immediate subviews... and their subviews... and their subviews... and their subviews...
    */
    public func removeAllSubviews() {
        for subView in self.subviews {
            subView.removeAllSubviews()
        }

        📘("Removing: \(self), bounds: \(bounds), frame: \(frame):")
        self.removeFromSuperview()
    }
    
    // MARK: - Constraints methods
    
    func stretchToSuperViewEdges(_ insets: UIEdgeInsets = UIEdgeInsets.zero) {
        // Validate
        guard let superview = superview else { fatalError("superview not set") }
        
        let leftConstraint = constraintWithItem(superview, attribute: .left, multiplier: 1, constant: insets.left)
        let topConstraint = constraintWithItem(superview, attribute: .top, multiplier: 1, constant: insets.top)
        let rightConstraint = constraintWithItem(superview, attribute: .right, multiplier: 1, constant: insets.right)
        let bottomConstraint = constraintWithItem(superview, attribute: .bottom, multiplier: 1, constant: insets.bottom)
        
        let edgeConstraints = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
        
        translatesAutoresizingMaskIntoConstraints = false

        superview.addConstraints(edgeConstraints)
    }
    
    func pinToSuperViewCenter(_ offset: CGPoint = CGPoint.zero) {
        // Validate
        assert(self.superview != nil, "superview not set")
        let superview = self.superview!
        
        let centerX = constraintWithItem(superview, attribute: .centerX, multiplier: 1, constant: offset.x)
        let centerY = constraintWithItem(superview, attribute: .centerY, multiplier: 1, constant: offset.y)
        
        let centerConstraints = [centerX, centerY]
        
        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(centerConstraints)
    }
    
    func constraintWithItem(_ view: UIView, attribute: NSLayoutAttribute, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: multiplier, constant: constant)
    }

    /**
     Adds a transparent gradient layer to the view's mask.
     */
    func addTransparentGradientLayer() -> CALayer {
        let gradientLayer = CAGradientLayer()
        let normalColor = UIColor.white.withAlphaComponent(1.0).cgColor
        let fadedColor = UIColor.white.withAlphaComponent(0.0).cgColor
        gradientLayer.colors = [normalColor, normalColor, normalColor, fadedColor]
        
        // Hoizontal - commenting these two lines will make the gradient veritcal (haven't tried this yet)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.locations = [0.0, 0.4, 0.6, 1.0]
        gradientLayer.anchorPoint = CGPoint.zero

        self.layer.mask = gradientLayer
/*
        override func layoutSubviews() {
            super.layoutSubviews()
            
            transparentGradientLayer.bounds = self.bounds
        }
*/

        return gradientLayer
    }

    func addVerticalGradientBackgroundLayer(topColor: UIColor, bottomColor: UIColor) -> CALayer {
        let gradientLayer = CAGradientLayer()
        let topCGColor = topColor.cgColor
        let bottomCGColor = bottomColor.cgColor
        gradientLayer.colors = [topCGColor, bottomCGColor]
        gradientLayer.frame = frame
        layer.insertSublayer(gradientLayer, at: 0)

        return gradientLayer
    }

    // MARK: - Other cool additions

    /**
     Attaches the closure to the tap event (onClick event)

     - parameter onClickClosure: A closure to dispatch when a tap gesture is recognized.
     */
    func onClick(_ onClickClosure: @escaping OnClickClosureWrapper.TapRecognizedClosure) {
        self.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapRecognized(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        addGestureRecognizer(tapGestureRecognizer)
        let attachedClosureWrapper = OnClickClosureWrapper(closure: onClickClosure)
        tapGestureRecognizer.delegate = attachedClosureWrapper
        objc_setAssociatedObject(self, &OnClickClosureWrapper.onClickClosureProperty, attachedClosureWrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
    }
    
    func onTapRecognized(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard let attachedClosureWrapper = objc_getAssociatedObject(self, &OnClickClosureWrapper.onClickClosureProperty) as? OnClickClosureWrapper else { return }
        attachedClosureWrapper.closure(tapGestureRecognizer)
    }
    
    /**
     Attaches the closure to the tap event (onClick event)
     
     - parameter onClickClosure: A closure to dispatch when a tap gesture is recognized.
     */
    func onLongPress(_ onLongPressClosure: @escaping OnLongPressClosureWrapper.LongPressRecognizedClosure) {
        self.isUserInteractionEnabled = true
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized(_:)))
        addGestureRecognizer(longPressRecognizer)
        let attachedClosureWrapper = OnLongPressClosureWrapper(closure: onLongPressClosure)
        longPressRecognizer.delegate = attachedClosureWrapper
        objc_setAssociatedObject(self, &OnLongPressClosureWrapper.longPressClosureProperty, attachedClosureWrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
    }
    
    func longPressRecognized(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard let attachedClosureWrapper = objc_getAssociatedObject(self, &OnLongPressClosureWrapper.longPressClosureProperty) as? OnLongPressClosureWrapper else { return }
        if longPressGestureRecognizer.state == .began {
            attachedClosureWrapper.closure(longPressGestureRecognizer)
        }
    }
    
    func firstResponder() -> UIView? {
        var firstResponder: UIView? = self
        
        if isFirstResponder {
            return firstResponder
        }
        
        for subView in subviews {
            firstResponder = subView.firstResponder()
            if firstResponder != nil {
                return firstResponder
            }
        }
        
        return nil
    }
}

// Wrapper to save closure into a property
class OnClickClosureWrapper: NSObject, UIGestureRecognizerDelegate {
    typealias TapRecognizedClosure = (_ tapGestureRecognizer: UITapGestureRecognizer) -> ()
    static var onClickClosureProperty = "onClickClosureProperty"
    
    let closure: TapRecognizedClosure
    
    init(closure: @escaping TapRecognizedClosure) {
        self.closure = closure
    }

    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// Wrapper to save closure into a property
class OnLongPressClosureWrapper: NSObject, UIGestureRecognizerDelegate {
    typealias LongPressRecognizedClosure = (_ longPressGestureRecognizer: UILongPressGestureRecognizer) -> ()
    static var longPressClosureProperty = "longPressClosureProperty"
    
    let closure: LongPressRecognizedClosure
    
    init(closure: @escaping LongPressRecognizedClosure) {
        self.closure = closure
    }
    
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// Wrapper to save closure into a property
class CompletionClosureWrapper {
    static var completionClosureProperty = "completionClosureProperty"
    
    let closure: CompletionClosure
    
    init(closure: @escaping CompletionClosure) {
        self.closure = closure
    }
}

extension URL {
    func queryStringComponents() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        // Check for query string
        if let query = self.query {
            // Loop through pairings (separated by &)
            for pair in query.components(separatedBy: "&") {
                // Pull key, val from from pair parts (separated by =) and set dict[key] = value
                let components = pair.components(separatedBy: "=")
                dict[components[0]] = components[1] as AnyObject?
            }
        }
        
        return dict
    }
}

extension UserDefaults {
    static func save(value: AnyObject, forKey key: String) -> UserDefaults {
        UserDefaults.standard.set(value, forKey: key)
        return UserDefaults.standard
    }
    
    static func remove(key: String) -> UserDefaults {
        UserDefaults.standard.set(nil, forKey: key)
        return UserDefaults.standard
    }
    
    static func load(key: String, defaultValue: AnyObject? = nil) -> AnyObject? {
        if let actualValue = UserDefaults.standard.object(forKey: key) as? AnyObject {
            return actualValue
        }
        
        return defaultValue
    }
}
