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

typealias CompletionClosure = ((AnyObject?) -> Void)?

func WIDTH(frame: CGRect?) -> CGFloat { return frame == nil ? 0 : (frame?.size.width)! }
func HEIGHT(frame: CGRect?) -> CGFloat { return frame == nil ? 0 : (frame?.size.height)! }

public func 📘(logMessage: String, file:String = #file, function:String = #function, line:Int = #line) {
    let formattter = NSDateFormatter()
    formattter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    let timesamp = formattter.stringFromDate(NSDate())

    print("〈\(timesamp)〉\(file.componentsSeparatedByString("/").last!) ➤ \(function.componentsSeparatedByString("(").first!) (\(line)): \(logMessage)")
}

// MARK: - Global Methods

// dispatch block on main queue
public func runOnUiThread(afterDelay seconds: Double = 0.0, block: dispatch_block_t) {
    runBlockAfterDelay(afterDelay: seconds, block: block)
}

// runClosureAfterDelay
public func runBlockAfterDelay(afterDelay seconds: Double = 0.0, onQueue: dispatch_queue_t = dispatch_get_main_queue(), block: dispatch_block_t) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))) // 2 seconds delay before retry
        dispatch_after(delayTime, onQueue, block)
}

public func className(aClass: AnyClass) -> String {
    let className = NSStringFromClass(aClass)
    let components = className.componentsSeparatedByString(".")
    
    if components.count > 0 {
        return components.last!
    } else {
        return className
    }
}

// MARK: - Class

public class PerrFuncs: NSObject {
    // Computed static variables will act as lazy variables
    static var sharedInstance: PerrFuncs = {
        return PerrFuncs()
    }()

    private override init() {
        super.init()
    }
    
    lazy var imageContainer: UIView = {
        let container = UIView(frame: UIScreen.mainScreen().bounds)
        container.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
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

    class func fetchAndPresentImage(imageUrl: String?) {
        guard let imageUrl = imageUrl where imageUrl.length() > 0,
            let app = UIApplication.sharedApplication().delegate as? AppDelegate,
            let window = app.window
            else { return }
        
        📘("fetching \(imageUrl)")

        let loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingSpinner.startAnimating()
        sharedInstance.imageContainer.addSubview(loadingSpinner)
        loadingSpinner.pinToSuperViewCenter()
        sharedInstance.imageContainer.animateFade(fadeIn: true, duration: 0.5)
        
        window.addSubview(sharedInstance.imageContainer)
        sharedInstance.imageContainer.stretchToSuperViewEdges()

        let screenWidth = WIDTH(window.frame) //Or: UIScreen.mainScreen().bounds.width
        UIImageView(frame: CGRectMake(0.0, 0.0, screenWidth, screenWidth)).fetchImage(withUrl: imageUrl) { (imageView) in
            if let imageView = imageView as? UIImageView where imageView.image != nil {
                sharedInstance.imageContainer.addSubview(imageView)
                imageView.userInteractionEnabled = false
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
    static func fetchImage(withUrl urlString: String, completionClosure: CompletionClosure) {
        guard let url = NSURL(string: urlString) else { completionClosure?(nil); return }
        
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        // Run on background thread:
        dispatch_async(backgroundQueue) {
            var image: UIImage? = nil
            
            // No matter what, make the callback call on the main thread:
            defer {
                // Run on UI thread:
                dispatch_async(dispatch_get_main_queue()) {
                    completionClosure?(image)
                }
            }

            // The most (and inefficient) simple way to download a photo from the web (no timeout, error handling etc.)
            if let data = NSData(contentsOfURL: url) {
                image = UIImage(data: data)
            }
        }
    }
}

extension UIImageView {
    func fetchImage(withUrl urlString: String, completionClosure: CompletionClosure) {
        guard urlString.length() > 0 else { completionClosure?(nil); return }

        UIImage.fetchImage(withUrl: urlString) { (image) in
            defer {
                dispatch_async(dispatch_get_main_queue()) {
                    completionClosure?(self)
                }
            }

            guard let image = image as? UIImage else { return }

            self.image = image
            self.contentMode = .ScaleAspectFit
        }
    }
}

//MARK: - Global Extensions

// Declare a global var to produce a unique address as the assoc object handle
var SompApplicationBelovedProperty: UInt8 = 0

// Question: What is redundant in this code?

//infix operator 😘 { associativity left precedence 140 }
func 😘(left: NSObject, right: String) throws -> Bool {
    return try left.😘(beloved: right)
}

extension NSObject { // try extending 'AnyObject'...
    //infix operator 😘 { associativity left precedence 140 }
    func 😘(beloved beloved: String) throws -> Bool {
        guard beloved.length() > 0 else {
            return false
        }
        
        📘("loving \(beloved)")
        
        // "Hard" guard
        //assert(beloved.length() > 0, "non-empty strings only")
        
        objc_setAssociatedObject(self, &SompApplicationBelovedProperty, beloved, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return true
    }
    
    func 😍() -> String? { // 1
        //log("loving \(right)")
        guard let value = objc_getAssociatedObject(self, &SompApplicationBelovedProperty) as? String else {
            return nil
        }
        
        return value
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
        guard let topController = UIApplication.sharedApplication().keyWindow?.rootViewController else { return nil }
        return topController.mostTopViewController()
    }
}

extension UIAlertController {

    /**
     Dismisses the current alert (if presented) and pops up the new one
     */
    func show() {
        let mostTopViewController = UIApplication.mostTopViewController()!
        if mostTopViewController is UIAlertController { // Prevents a horrible bug, also promising the invocation of 'viewWillDisappear' in 'CommonViewController'
            // 1. Dismiss the alert
            mostTopViewController.dismissViewControllerAnimated(true, completion: {
                // 2. Then present fullscreen
                UIApplication.mostTopViewController()?.presentViewController(self, animated: true, completion: nil)
            })
        } else {
            mostTopViewController.presentViewController(self, animated: true, completion: nil)
        }
    }

    func withAction(action: UIAlertAction) -> UIAlertController {
        self.addAction(action)
        return self
    }

    func withInputText(inout textFieldToAdd: UITextField) -> UIAlertController {
        self.addTextFieldWithConfigurationHandler(/*configurationHandler: */ { (textField: UITextField!) -> Void in
            textFieldToAdd = textField
        })
        return self
    }
    
    static func make(title title: String, message: String, dismissButtonTitle:String = "OK", onGone: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        return alertController
    }
    /**
     A service method that alerts with title and message in the top view controller
     
     - parameter title: The title of the UIAlertView
     - parameter message: The message inside the UIAlertView
     */
    static func alert(title title: String, message: String, dismissButtonTitle:String = "OK", onGone: (() -> Void)? = nil) {
        guard var topController = UIApplication.sharedApplication().keyWindow?.rootViewController else { return }
        
        // topController should now be the most top view controller
        topController = topController.mostTopViewController()

        UIAlertController.make(title: title, message: message).withAction(UIAlertAction(title: dismissButtonTitle, style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            onGone?()
        })).show()
    }
}

extension UIViewController {
    
    class func instantiate(storyboardName storyboardName: String? = nil) -> Self {
        return instantiateFromStoryboardHelper(storyboardName)
    }
    
    private class func instantiateFromStoryboardHelper<T: UIViewController>(storyboardName: String?) -> T {
        let storyboard = storyboardName != nil ? UIStoryboard(name: storyboardName!, bundle: nil) : UIStoryboard(name: "Main", bundle: nil)
        let identifier = NSStringFromClass(T).componentsSeparatedByString(".").last!
        let controller = storyboard.instantiateViewControllerWithIdentifier(identifier) as! T
        return controller
    }
}

extension UIView {
    
    // MARK: - Animations
    public func animateBump(completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.CurveEaseOut   , animations: { [weak self] () -> Void in
            self?.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion:nil)

        UIView.animateWithDuration(0.1, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { [weak self] () -> Void in
            self?.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }) { (succeeded) -> Void in
                completion?(succeeded)
        }
    }

    public func animateNono(completion: ((Bool) -> Void)? = nil) {
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
    }

    public func animateMoveCenterTo(x x: CGFloat, y: CGFloat, duration: NSTimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        self.center.x = -self.center.x
        self.center.y = -self.center.y
        
        UIView.animateWithDuration(duration, animations: {
            self.center.x = x
            self.center.y = y
            }, completion: completion)
    }
    
    public func animateZoom(zoomIn zoomIn: Bool, duration: NSTimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        if zoomIn {
            self.transform = CGAffineTransformMakeScale(0.0, 0.0)
        }
        UIView.animateWithDuration(duration, animations: { () -> Void in
            if zoomIn {
                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            } else {
                self.frame.size = CGSizeMake(0.0, 0.0)
            }
            }) { (finished) in
                self.show(show: zoomIn)
                completion?(finished)
        }
    }
    
    public func animateFade(fadeIn fadeIn: Bool, duration: NSTimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        // Skip redundant calls
        guard (fadeIn == false && (alpha > 0 || hidden == false)) || (fadeIn == true && (alpha == 0 || hidden == true)) else { return }

        self.alpha = fadeIn ? 0.0 : 1.0
        self.show(show: true)
        UIView.animateWithDuration(duration, animations: {// () -> Void in
            self.alpha = fadeIn ? 1.0 : 0.0
            }) { (finished) in
                self.show(show: fadeIn)
                completion?(finished)
        }
    }
    
    // MARK: - Property setters-like methods

    public func show(show show: Bool, faded: Bool = false) {
        if faded {
            animateFade(fadeIn: show)
        } else {
            self.hidden = !show
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
    
    func stretchToSuperViewEdges(insets: UIEdgeInsets = UIEdgeInsetsZero) {
        // Validate
        guard let superview = superview else { fatalError("superview not set") }
        
        let leftConstraint = constraintWithItem(superview, attribute: .Left, multiplier: 1, constant: insets.left)
        let topConstraint = constraintWithItem(superview, attribute: .Top, multiplier: 1, constant: insets.top)
        let rightConstraint = constraintWithItem(superview, attribute: .Right, multiplier: 1, constant: insets.right)
        let bottomConstraint = constraintWithItem(superview, attribute: .Bottom, multiplier: 1, constant: insets.bottom)
        
        let edgeConstraints = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
        
        translatesAutoresizingMaskIntoConstraints = false

        superview.addConstraints(edgeConstraints)
    }
    
    func pinToSuperViewCenter(offset: CGPoint = CGPointZero) {
        // Validate
        assert(self.superview != nil, "superview not set")
        let superview = self.superview!
        
        let centerX = constraintWithItem(superview, attribute: .CenterX, multiplier: 1, constant: offset.x)
        let centerY = constraintWithItem(superview, attribute: .CenterY, multiplier: 1, constant: offset.y)
        
        let centerConstraints = [centerX, centerY]
        
        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(centerConstraints)
    }
    
    func constraintWithItem(view: UIView, attribute: NSLayoutAttribute, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: multiplier, constant: constant)
    }

    /**
     Adds a transparent gradient layer to the view's mask.
     */
    func addTransparentGradientLayer() -> CALayer {
        let gradientLayer = CAGradientLayer()
        let normalColor = UIColor.whiteColor().colorWithAlphaComponent(1.0).CGColor
        let fadedColor = UIColor.whiteColor().colorWithAlphaComponent(0.0).CGColor
        gradientLayer.colors = [normalColor, normalColor, normalColor, fadedColor]
        
        // Hoizontal - commenting these two lines will make the gradient veritcal (haven't tried this yet)
        gradientLayer.startPoint = CGPointMake(0.0, 0.5)
        gradientLayer.endPoint = CGPointMake(1.0, 0.5)
        
        gradientLayer.locations = [0.0, 0.4, 0.6, 1.0]
        gradientLayer.anchorPoint = CGPointZero

        self.layer.mask = gradientLayer
/*
        override func layoutSubviews() {
            super.layoutSubviews()
            
            transparentGradientLayer.bounds = self.bounds
        }
*/

        return gradientLayer
    }

    func addVerticalGradientBackgroundLayer(topColor topColor: UIColor, bottomColor: UIColor) -> CALayer {
        let gradientLayer = CAGradientLayer()
        let topCGColor = topColor.CGColor
        let bottomCGColor = bottomColor.CGColor
        gradientLayer.colors = [topCGColor, bottomCGColor]
        gradientLayer.frame = frame
        layer.insertSublayer(gradientLayer, atIndex: 0)

        return gradientLayer
    }

    // MARK: - Other cool additions

    // Attaches the closure to the tap event (onClick event)
    func onClick(onClickClosure: ClosureWrapper.TapRecognizedClosure) {
        self.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapRecognized(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        let attachedClosureWrapper = ClosureWrapper(closure: onClickClosure)
        objc_setAssociatedObject(self, &ClosureWrapper.onClickClosureProperty, attachedClosureWrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
    }
    
    func onTapRecognized(gestureRecognizer: UIGestureRecognizer) {
        guard let attachedClosureWrapper = objc_getAssociatedObject(self, &ClosureWrapper.onClickClosureProperty) as? ClosureWrapper else { return }
        attachedClosureWrapper.closure(gestureRecognizer: gestureRecognizer)
    }

    func firstResponder() -> UIView? {
        var firstResponder: UIView? = self
        
        if self.isFirstResponder() {
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

// Wraps
class ClosureWrapper {
    typealias TapRecognizedClosure = (gestureRecognizer: UIGestureRecognizer) -> ()
    static var onClickClosureProperty = "onClickClosureProperty"
    
    let closure: TapRecognizedClosure
    
    init(closure: TapRecognizedClosure) {
        self.closure = closure
    }
}

extension NSURL {
    func queryStringComponents() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        // Check for query string
        if let query = self.query {
            // Loop through pairings (separated by &)
            for pair in query.componentsSeparatedByString("&") {
                // Pull key, val from from pair parts (separated by =) and set dict[key] = value
                let components = pair.componentsSeparatedByString("=")
                dict[components[0]] = components[1]
            }
        }
        
        return dict
    }
}

extension NSUserDefaults {
    static func save(value value: AnyObject, forKey key: String) -> NSUserDefaults {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        return NSUserDefaults.standardUserDefaults()
    }
    
    static func remove(key key: String) -> NSUserDefaults {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: key)
        return NSUserDefaults.standardUserDefaults()
    }
    
    static func load(key key: String, defaultValue: AnyObject? = "") -> AnyObject? {
        if let actualValue = NSUserDefaults.standardUserDefaults().objectForKey(key) {
            return actualValue
        }
        
        return defaultValue
    }
}
