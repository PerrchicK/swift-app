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

public func 📘(_ logMessage: Any, file:String = #file, function:String = #function, line:Int = #line) {
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
public func runBlockAfterDelay(afterDelay seconds: Double, onQueue: DispatchQueue = DispatchQueue.main, block: @escaping ()->()) {
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

    static func random(to: Int) -> UInt32 {
        return arc4random() % UInt32(to)
    }

    static func random(from: Int, to: Int) -> UInt32 {
        return random(to: to - from) + UInt32(from)
    }
    
    @discardableResult
    static func postRequest(urlString: String, jsonDictionary: [String: Any], completion: @escaping ([String: Any]?) -> ()) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else { completion(nil); return nil }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            
            // create post request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = 30
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if let error = error {
                    📘("Error: \(error)")
                    completion(nil)
                    return
                }
                guard let data = data else { completion(nil); return }
                
                do {
                    guard let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { completion(nil); return }
                    completion(result)
                } catch let deserializationError {
                    📘("Failed to parse JSON: \(deserializationError)")
                    completion(nil)
                }
            }
            
            task.resume()
            return task
        } catch let serializationError {
            📘("Failed to serialize JSON: \(serializationError)")
            completion(nil)
        }
        
        return nil
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
var SompApplicationHuggedProperty: UInt8 = 0

infix operator &* { associativity left precedence 140 }

extension NSObject { // try extending 'AnyObject'...
    /**
     << EXPERIMENTAL METHOD >>
     Attaches any object to this NSObject.
     This enables the same idea of user info, to every object that inherits from NSObject.
     */
    @discardableResult
    func 😘(huggedObject: Any) -> Bool {
        //infix operator 😘 { associativity left precedence 140 }
        📘("hugging \(huggedObject)")

        objc_setAssociatedObject(self, &SompApplicationHuggedProperty, huggedObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return true
    }
    
    /**
     << EXPERIMENTAL METHOD >>
     Extracts the hugged object from an NSObject.
     */
    func 😍() -> AnyObject? { // 1
        guard let value = objc_getAssociatedObject(self, &SompApplicationHuggedProperty) else {
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
    @discardableResult
    func show() -> UIAlertController? {
        guard let mostTopViewController = UIApplication.mostTopViewController() else { 📘("Failed to present alert [title: \(String(describing: self.title)), message: \(String(describing: self.message))]"); return nil }
        if mostTopViewController is UIAlertController { // Prevents a horrible bug, also promising the invocation of 'viewWillDisappear' in 'CommonViewController'
            // 1. Dismiss the alert
            mostTopViewController.dismiss(animated: true, completion: {
                // 2. Then present fullscreen
                UIApplication.mostTopViewController()?.present(self, animated: true, completion: nil)
            })
        } else {
            mostTopViewController.present(self, animated: true, completion: nil)
        }

        return self
    }

    func withAction(_ action: UIAlertAction) -> UIAlertController {
        self.addAction(action)
        return self
    }

    func withInputText(configurationBlock: @escaping ((_ textField: UITextField) -> Void)) -> UIAlertController {
        self.addTextField(configurationHandler: { (textField: UITextField!) -> () in
            configurationBlock(textField)
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
        let identifier = NSStringFromClass(T.self).components(separatedBy: ".").last!
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
        /*
        let noAnimation = CAKeyframeAnimationWithClosure()
        noAnimation.keyPath = "position.x"
        
        noAnimation.values = [0, 10, -10, 10, 0]
        let keyTimes: [NSNumber] = [0, NSNumber(value: Float(1.0 / 6.0)), NSNumber(value: Float(3.0 / 6.0)), NSNumber(value: Float(5.0 / 6.0)), 1]
        noAnimation.keyTimes = keyTimes
        noAnimation.duration = 0.4
        
        noAnimation.isAdditive = true
        noAnimation.delegate = self
        noAnimation.isRemovedOnCompletion = false

        noAnimation.completionClosure = completion

        self.layer.add(noAnimation, forKey: ANIMATION_NO_KEY) // shake animation
         */

        // another implementation without using CAKeyframeAnimation:
        let originX = self.frame.origin.x

        UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
            self?.frame.origin.x = originX - 10
        }, completion: { done in
            UIView.animate(withDuration: 0.1, animations: { [weak self] () -> Void in
                self?.frame.origin.x = originX + 10
            }, completion: { done in
                UIView.animate(withDuration: 0.05, animations: { [weak self] () -> Void in
                    self?.frame.origin.x = originX
                    }, completion: { (done: Bool) in
                    completion?(done as AnyObject)
                })
            })
        })
    }

    public func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        if self.layer.animation(forKey: ANIMATION_NO_KEY) == animation {
            guard let animation = animation as? CAKeyframeAnimationWithClosure else { return }

            animation.completionClosure?(flag as AnyObject?)
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
    func onClick(_ onClickClosure: @escaping OnTapRecognizedClosure) {
        self.isUserInteractionEnabled = true
        let tapGestureRecognizer = OnClickListener(target: self, action: #selector(onTapRecognized(_:)), closure: onClickClosure)

        tapGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        
        tapGestureRecognizer.delegate = tapGestureRecognizer

        addGestureRecognizer(tapGestureRecognizer)
    }

    func onTapRecognized(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard let tapGestureRecognizer = tapGestureRecognizer as? OnClickListener else { return }
        
        tapGestureRecognizer.closure(tapGestureRecognizer)
    }
    
    func onSwipe(direction: UISwipeGestureRecognizerDirection, _ onSwipeClosure: @escaping OnSwipeRecognizedClosure) {
        self.isUserInteractionEnabled = true
        let swipeGestureRecognizer = OnSwipeListener(target: self, action: #selector(onSwipeRecognized(_:)), closure: onSwipeClosure)
        
        swipeGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        
        swipeGestureRecognizer.delegate = swipeGestureRecognizer
        swipeGestureRecognizer.direction = direction
        addGestureRecognizer(swipeGestureRecognizer)
    }

    func onSwipeRecognized(_ swipeGestureRecognizer: UISwipeGestureRecognizer) {
        guard let swipeGestureRecognizer = swipeGestureRecognizer as? OnSwipeListener else { return }

        swipeGestureRecognizer.closure(swipeGestureRecognizer)
    }

    /**
     Attaches the closure to the tap event (onClick event)
     
     - parameter onClickClosure: A closure to dispatch when a tap gesture is recognized.
     */
    func onLongPress(_ onLongPressClosure: @escaping OnLongPressRecognizedClosure) {
        self.isUserInteractionEnabled = true
        let longPressGestureRecognizer = OnLongPressListener(target: self, action: #selector(longPressRecognized(_:)), closure: onLongPressClosure)
        
        longPressGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        
        longPressGestureRecognizer.delegate = longPressGestureRecognizer
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func longPressRecognized(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard let longPressGestureRecognizer = longPressGestureRecognizer as? OnLongPressListener else { return }

        longPressGestureRecognizer.closure(longPressGestureRecognizer)
    }

//    open override func didChangeValue(forKey key: String, withSetMutation mutationKind: NSKeyValueSetMutationKind, using objects: Set<AnyHashable>) {
//        <#code#>
//    }

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

// Wrapper to save closure into a property - no need for this hack anymore, memory leak maker
//class CompletionClosureWrapper {
//    static var completionClosureProperty = "completionClosureProperty"
//    
//    let closure: CompletionClosure
//    
//    init(closure: @escaping CompletionClosure) {
//        self.closure = closure
//    }
//}

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
        if let actualValue = UserDefaults.standard.object(forKey: key) {
            return actualValue as AnyObject
        }
        
        return defaultValue
    }
}

typealias OnSwipeRecognizedClosure = (_ tapGestureRecognizer: UISwipeGestureRecognizer) -> ()
class OnSwipeListener: UISwipeGestureRecognizer, UIGestureRecognizerDelegate {
    private(set) var closure: OnSwipeRecognizedClosure
    
    init(target: Any?, action: Selector?, closure: @escaping OnSwipeRecognizedClosure) {
        self.closure = closure
        super.init(target: target, action: action)
    }
    
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
//    deinit {
//        📘("\(className(OnSwipeListener.self)) gone from RAM 💀")
//    }
}

typealias OnTapRecognizedClosure = (_ tapGestureRecognizer: UITapGestureRecognizer) -> ()
class OnClickListener: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    private(set) var closure: OnTapRecognizedClosure

    init(target: Any?, action: Selector?, closure: @escaping OnTapRecognizedClosure) {
        self.closure = closure
        super.init(target: target, action: action)
    }
    
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

//    deinit {
//        📘("\(className(OnClickListener.self)) gone from RAM 💀")
//    }
}

typealias OnLongPressRecognizedClosure = (_ longPressGestureRecognizer: UILongPressGestureRecognizer) -> ()
class OnLongPressListener: UILongPressGestureRecognizer, UIGestureRecognizerDelegate {
    private(set) var closure: OnLongPressRecognizedClosure

    init(target: Any?, action: Selector?, closure: @escaping OnLongPressRecognizedClosure) {
        self.closure = closure
        super.init(target: target, action: action)
    }

    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    
    deinit {
        📘("\(className(OnLongPressListener.self)) gone from RAM 💀")
    }
}

/// An interesting fact: the CAKeyframeAnimation object does not survive the animation, it's being dealloced right after it has been added to the layer
class CAKeyframeAnimationWithClosure: CAKeyframeAnimation {
    var completionClosure: CompletionClosure?
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        completionClosure = aDecoder.decodeObject(forKey: "completionClosure") as? CompletionClosure
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(completionClosure, forKey: "completionClosure")
    }
    
    deinit {
        📘("💀")
    }
}
