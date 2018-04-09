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
public typealias CallbackClosure<T> = ((T) -> Void)
public typealias PredicateClosure<T> = ((T) -> Bool)

func WIDTH(_ frame: CGRect?) -> CGFloat { return frame == nil ? 0 : (frame?.size.width)! }
func HEIGHT(_ frame: CGRect?) -> CGFloat { return frame == nil ? 0 : (frame?.size.height)! }

// MARK: - Global Methods

public func 📘(_ logMessage: Any, file: String = #file, function: String = #function, line: Int = #line) {
    let formattter = DateFormatter()
    formattter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    let timesamp = formattter.string(from: Date())

    print("〈\(timesamp)〉\(file.components(separatedBy: "/").last!) ➤ \(function.components(separatedBy: "(").first!) (\(line)): \(logMessage)")
}

// MARK: - Class

open class PerrFuncs {

    static var dispatchTokens: [String] = []
    static public func dispatchOnce(dispatchToken: String, block: () -> ()) {
        if dispatchTokens.contains(dispatchToken) { return }
        dispatchTokens.append(dispatchToken)

        block()
    }

    // dispatch block on main queue
    static public func runOnUiThread(afterDelay seconds: Double = 0.0, block: @escaping ()->()) {
        runBlockAfterDelay(afterDelay: seconds, block: block)
    }
    
    // runClosureAfterDelay
    static public func runBlockAfterDelay(afterDelay seconds: Double, onQueue: DispatchQueue = DispatchQueue.main, block: @escaping ()->()) {
        let delayTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) // 2 seconds delay before retry
        onQueue.asyncAfter(deadline: delayTime, execute: block)
    }
    
    static public func className(_ aClass: AnyClass) -> String {
        let className = NSStringFromClass(aClass)
        let components = className.components(separatedBy: ".")
        
        if components.count > 0 {
            return components.last!
        } else {
            return className
        }
    }

    #if !os(macOS) && !os(watchOS)
    /// This is an async operation (it needs an improvement - in case this method is being called again before the previous is completed?)
    public static func runBackgroundTask(block: @escaping (_ completionHandler: @escaping () -> ()) -> ()) {
        func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
            UIApplication.shared.endBackgroundTask(task)
            task = UIBackgroundTaskInvalid
        }
        
        var backgroundTask: UIBackgroundTaskIdentifier!
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            endBackgroundTask(&backgroundTask!)
        }
        
        let onDone = {
            endBackgroundTask(&backgroundTask!)
        }
        
        block(onDone)
    }
    #endif

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
        
        let imageContainer: UIView = UIView(frame: UIScreen.main.bounds)

        let removeImage: () -> () = { [ weak imageContainer] in
            imageContainer?.animateFade(fadeIn: false, duration: 0.5) { (doneSuccessfully) in
                imageContainer?.removeAllSubviews()
                imageContainer?.removeFromSuperview()
            }
        }

        imageContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // To be a target, it must be an NSObject instance
        imageContainer.onClick() { (tapGestureRecognizer: UITapGestureRecognizer) in
            removeImage()
        }

        imageContainer.addSubview(loadingSpinner)
        loadingSpinner.pinToSuperViewCenter()
        imageContainer.animateFade(fadeIn: true, duration: 0.5)
        
        window.addSubview(imageContainer)
        imageContainer.stretchToSuperViewEdges()

        let screenWidth = WIDTH(window.frame) //Or: UIScreen.mainScreen().bounds.width
        UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenWidth)).fetchImage(withUrl: imageUrl) { (imageView) in
            if imageView.image != nil {
                imageContainer.addSubview(imageView)
                imageView.isUserInteractionEnabled = false
                imageView.pinToSuperViewCenter()
            } else {
                removeImage()
            }
        }
    }

    static func random(from: Int = 0, to: Int) -> Int {
        guard to != from else { return to }

        var _from: Int = from, _to: Int = to
        
        if to < from {// Error handling
            swap(&_to, &_from)
        }

        let randdomNumber: UInt32 = arc4random() % UInt32(_to - _from)
        return Int(randdomNumber) + _from
    }

    static func doesFileExistAtUrl(url: URL) -> Bool {
        return doesFileExistAtPath(path: url.absoluteString)
    }

    static func doesFileExistAtPath(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path.replacingOccurrences(of: "file://", with: ""))
    }

    @discardableResult
    static func postRequest(urlString: String, jsonDictionary: [String: Any], httpHeaders: [String:String]? = nil, completion: @escaping ([String: Any]?) -> ()) -> URLSessionDataTask? {

        guard let url = URL(string: urlString) else { completion(nil); return nil }

        do {
            // here "jsonData" is the dictionary encoded in JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            // create post request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            if let httpHeaders = httpHeaders {
                for httpHeader in httpHeaders {
                    request.setValue(httpHeader.value, forHTTPHeaderField: httpHeader.key)
                }
            }
            
            //request.setValue("application/json", forHTTPHeaderField: "Content-Type") // OR: setValue
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            // insert json data to the request
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
                    📘("Failed to parse JSON: \(deserializationError), data string: \(String(describing: String(data: data, encoding: String.Encoding.utf8)))")
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
        return self.count
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
        case "Crazy Whack":
            emoji = "😜"

        default:
            📘("Error: Couldn't find emoji for string '\(self)'")
            break
        }
        
        📘("string to emoji: \(self) -> \(emoji)")
        
        return emoji
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hexString:NSString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let scanner = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

extension UIImage {
    static func fetchImage(withUrl urlString: String, completionClosure: CallbackClosure<UIImage?>?) {
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
    func fetchImage(withUrl urlString: String, completionClosure: CallbackClosure<UIImageView>?) {
        guard urlString.length() > 0 else { completionClosure?(self); return }

        UIImage.fetchImage(withUrl: urlString) { (image) in
            defer {
                DispatchQueue.main.async {
                    completionClosure?(self)
                }
            }

            guard let image: UIImage = image else { return }

            self.image = image
            self.contentMode = .scaleAspectFit
        }
    }
}

//MARK: - Global Extensions

// Declare a global var to produce a unique address as the assoc object handle
var SompApplicationHuggedProperty: UInt8 = 0

// Allows this: { let temp = -3 ~ -80 ~ 5 ~ 10 }
precedencegroup Additive {
    associativity: left // Explanation: https://en.wikipedia.org/wiki/Operator_associativity
}
infix operator ~ : Additive // https://developer.apple.com/documentation/swift/operator_declarations

/// Inclusively raffles a number from `left` hand operand value to the `right` hand operand value.
///
/// For example: the expression `{ let random: Int =  -3 ~ 5 }` will declare a random number between -3 and 5.
/// - parameter left:   The value represents `from`.
/// - parameter right:  The value represents `to`.
///
/// - returns: A random number between `left` and `right`.
func ~ (left: Int, right: Int) -> Int { // Reference: http://nshipster.com/swift-operators/
    return PerrFuncs.random(from: left, to: right)
}

/// Inclusively raffles a number from `left` hand operand value to the `right` hand operand value.
///
/// For example: the expression `{ let random: Int =  -3 ~ 5 }` will declare a random number between -3 and 5.
/// - parameter left:   The value represents `from`.
/// - parameter right:  The value represents `to`.
///
/// - returns: A random number between `left` and `right`.
func - (left: CGPoint, right: CGPoint) -> CGPoint { // Reference: http://nshipster.com/swift-operators/
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

extension NSObject { // try extending 'AnyObject'...

    // Cool use: https://marcosantadev.com/swift-arrays-holding-elements-weak-references/
    var pointerAddress: UnsafeMutableRawPointer {
        return Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque()
    }
    
    /**
     << EXPERIMENTAL METHOD >>
     Attaches any object to this NSObject.
     This enables the same idea of user info, to every object that inherits from NSObject.
     */
    @discardableResult
    func 😘(huggedObject: Any) -> Bool {
        //infix operator 😘 { associativity left precedence 140 }
        📘("\(self) is hugging \(huggedObject)")

        objc_setAssociatedObject(self, &SompApplicationHuggedProperty, huggedObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return true
    }
    
    /**
     << EXPERIMENTAL METHOD >>
     Extracts the hugged object from an NSObject.
     */
    func 😍() -> Any? { // 1
        guard let value = objc_getAssociatedObject(self, &SompApplicationHuggedProperty) else {
            return nil
        }
        
        return value as Any?
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
    func show(completion: (() -> Swift.Void)? = nil) -> UIAlertController? {
        guard let mostTopViewController = UIApplication.mostTopViewController() else { 📘("Failed to present alert [title: \(String(describing: self.title)), message: \(String(describing: self.message))]"); return nil }

        mostTopViewController.present(self, animated: true, completion: completion)

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
    
    static func make(style: UIAlertControllerStyle, title: String, message: String, dismissButtonTitle: String = "OK") -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        return alertController
    }

    static func makeActionSheet(title: String, message: String, dismissButtonTitle: String = "OK") -> UIAlertController {
        return make(style: .actionSheet, title: title, message: message, dismissButtonTitle: dismissButtonTitle)
    }

    static func makeAlert(title: String, message: String, dismissButtonTitle: String = "OK") -> UIAlertController {
        return make(style: .alert, title: title, message: message, dismissButtonTitle: dismissButtonTitle)
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

extension UIView {

    // Inspired from: https://stackoverflow.com/questions/25513271/how-to-initialize--a-custom-uiview-class-with-a-xib-file-in-swift
    class func instantiateFromNib<T>() -> T {
        let xibFileName: String = PerrFuncs.className(self.classForCoder().self)
        let nib: UINib = UINib(nibName: xibFileName, bundle: nil)
        let nibObject = nib.instantiate(withOwner: nil, options: nil).first
        return nibObject as! T
    }

    var isPresented: Bool {
        get {
            return !isHidden
        }
        set {
            isHidden = !newValue
        }
    }
    
    /**
     Hides the view if it's shown.
     Shows the view if it's hidden.
     */
    func toggleVisibility() {
        isPresented = !isPresented
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

    public func animateNo(_ completion: CallbackClosure<Bool>? = nil) {
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
                    completion?(done)
                })
            })
        })
    }

    public func animateMoveCenterTo(x: CGFloat, y: CGFloat, duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.center.x = x
            self.center.y = y
        }, completion: completion)
    }
    
    public func animateZoom(zoomIn: Bool, duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
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
    
    public func animateFade(fadeIn: Bool, duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
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
    public func show(show: Bool, faded: Bool = false) {
        if faded {
            animateFade(fadeIn: show)
        } else {
            self.isPresented = show
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

    func beOval() {
//        frame.width = frame.height
        self.layer.cornerRadius = frame.width / 2
        self.layer.masksToBounds = true
    }

    func makeRoundedCorners(_ radius: CGFloat = 5) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
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
    @discardableResult
    func onClick(_ onClickClosure: @escaping OnTapRecognizedClosure) -> OnClickListener {
        self.isUserInteractionEnabled = true
        let tapGestureRecognizer = OnClickListener(target: self, action: #selector(onTapRecognized(_:)), closure: onClickClosure)

        tapGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        tapGestureRecognizer.delegate = tapGestureRecognizer

        if self is UIButton {
            (self as? UIButton)?.addTarget(self, action: #selector(onTapRecognized(_:)), for: .touchUpInside)
            tapGestureRecognizer.isEnabled = false
        }

        addGestureRecognizer(tapGestureRecognizer)
        return tapGestureRecognizer
    }

    @objc func onTapRecognized(_ tapGestureRecognizer: UITapGestureRecognizer) {
        var onClickListener: OnClickListener?
        if self is UIButton {
            onClickListener = gestureRecognizers?.filter( { $0.isEnabled == false && $0 is OnClickListener } ).first as? OnClickListener
        } else {
            onClickListener = tapGestureRecognizer as? OnClickListener
        }

        guard let _onClickListener = onClickListener else { return }
        
        _onClickListener.closure(_onClickListener)
    }

    @discardableResult
    func onDrag(predicateClosure: PredicateClosure<UIView>? = nil, onDragClosure: @escaping CallbackClosure<OnPanListener>) -> OnPanListener {
        return onPan { panGestureRecognizer in
            guard let draggedView = panGestureRecognizer.view, (predicateClosure?(self)).or(true), let onPanListener = panGestureRecognizer as? OnPanListener else { return }

            if let pannedPoint = onPanListener.pannedPoint {
                draggedView.center = pannedPoint
            }

            onDragClosure(onPanListener)
        }
    }

    @discardableResult
    func onPan(_ onPanClosure: @escaping OnPanRecognizedClosure) -> OnPanListener {
        self.isUserInteractionEnabled = true
        let panGestureRecognizer = OnPanListener(target: self, action: #selector(onPanRecognized(_:)), closure: onPanClosure)
        
        panGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        panGestureRecognizer.delegate = panGestureRecognizer
        addGestureRecognizer(panGestureRecognizer)

        return panGestureRecognizer
    }
    
    @objc func onPanRecognized(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let onPanListener = panGestureRecognizer as? OnPanListener,
            let draggedView = panGestureRecognizer.view,
            let superview = draggedView.superview else { return }

        let locationOfTouch = panGestureRecognizer.location(in: superview)
        
        switch panGestureRecognizer.state {
        case .cancelled: fallthrough
        case .ended:
            onPanListener.startPoint = nil
            onPanListener.pannedPoint = nil
            onPanListener.offsetPoint = nil
            onPanListener.relativeStartPoint = nil
        case .began:
            onPanListener.relativeStartPoint = locationOfTouch
            onPanListener.startPoint = draggedView.center - locationOfTouch
            fallthrough
        default:
            if let startPoint = onPanListener.startPoint {
                onPanListener.pannedPoint = CGPoint(x: locationOfTouch.x + (startPoint.x), y: locationOfTouch.y + (startPoint.y))
                onPanListener.offsetPoint = locationOfTouch - startPoint
            }

            if let relativeStartPoint = onPanListener.relativeStartPoint {
                onPanListener.offsetPoint = locationOfTouch - relativeStartPoint
            }
        }

        onPanListener.closure(panGestureRecognizer)
    }

    @discardableResult
    func onSwipe(direction: UISwipeGestureRecognizerDirection, _ onSwipeClosure: @escaping OnSwipeRecognizedClosure) -> OnSwipeListener {
        self.isUserInteractionEnabled = true
        let swipeGestureRecognizer = OnSwipeListener(target: self, action: #selector(onSwipeRecognized(_:)), closure: onSwipeClosure)
        
        swipeGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        
        swipeGestureRecognizer.delegate = swipeGestureRecognizer
        swipeGestureRecognizer.direction = direction

        addGestureRecognizer(swipeGestureRecognizer)
        return swipeGestureRecognizer
    }

    @objc func onSwipeRecognized(_ swipeGestureRecognizer: UISwipeGestureRecognizer) {
        guard let swipeGestureRecognizer = swipeGestureRecognizer as? OnSwipeListener else { return }

        swipeGestureRecognizer.closure(swipeGestureRecognizer)
    }

    /**
     Attaches the closure to the tap event (onClick event)
     
     - parameter onClickClosure: A closure to dispatch when a tap gesture is recognized.
     */
    @discardableResult
    func onLongPress(_ onLongPressClosure: @escaping OnLongPressRecognizedClosure) -> OnLongPressListener {
        self.isUserInteractionEnabled = true
        let longPressGestureRecognizer = OnLongPressListener(target: self, action: #selector(longPressRecognized(_:)), closure: onLongPressClosure)
        
        longPressGestureRecognizer.cancelsTouchesInView = false // Solves bug: https://stackoverflow.com/questions/18159147/iphone-didselectrowatindexpath-only-being-called-after-long-press-on-custom-c
        longPressGestureRecognizer.delegate = longPressGestureRecognizer

        addGestureRecognizer(longPressGestureRecognizer)
        return longPressGestureRecognizer
    }
    
    @objc func longPressRecognized(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
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
    static func save(value: Any, forKey key: String) -> UserDefaults {
        UserDefaults.standard.set(value, forKey: key)
        return UserDefaults.standard
    }
    
    static func remove(key: String) -> UserDefaults {
        UserDefaults.standard.set(nil, forKey: key)
        return UserDefaults.standard
    }

    static func load<T>(key: String) -> T? {
        if let actualValue = UserDefaults.standard.object(forKey: key) {
            return actualValue as? T
        }
        
        return nil
    }
    
    static func load<T>(key: String, defaultValue: T) -> T {
        if let actualValue = UserDefaults.standard.object(forKey: key) {
            return (actualValue as? T).or(defaultValue)
        }
        
        return defaultValue
    }
}

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard count > index else {return nil }
        return self[index]
    }
    
    @discardableResult
    mutating func remove(where predicate: (Array.Iterator.Element) throws -> Bool) -> Element? {
        if let indexToRemove = try? self.index(where: predicate), let _indexToRemove = indexToRemove {
            return self.remove(at: _indexToRemove)
        }
        
        return nil
    }
}

typealias OnPanRecognizedClosure = (_ panGestureRecognizer: UIPanGestureRecognizer) -> ()
class OnPanListener: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    private(set) var closure: OnPanRecognizedClosure
    var startPoint: CGPoint?
    var relativeStartPoint: CGPoint?
    var offsetPoint: CGPoint?
    var pannedPoint: CGPoint?

    init(target: Any?, action: Selector?, closure: @escaping OnPanRecognizedClosure) {
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

typealias OnSwipeRecognizedClosure = (_ swipeGestureRecognizer: UISwipeGestureRecognizer) -> ()
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

    
//    deinit {
//        📘("\(className(OnLongPressListener.self)) gone from RAM 💀")
//    }
}

extension Optional {
    /// Still returning an optional, and dowesn't unwrap it ¯\\_(ツ)_/¯
    func `or`(_ value: Wrapped?) -> Optional {
        // Thanks to Lisa Dziuba. Reference: https://medium.com/flawless-app-stories/best-ios-hacks-from-twitter-october-edition-ce253347f88a
        return self ?? value
    }

    // Ha, that was the missing part from his twit: https://gist.github.com/PaulTaykalo/2ebfe0d7c1ca9fff1938506e910f738c#file-optionalchaining-swift-L13
    func `or`(_ value: Wrapped) -> Wrapped {
        return self ?? value
    }
}

extension CGRect {
    func withWidth(width _width: CGFloat) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: _width, height: size.height)
    }
    func withHeight(height _height: CGFloat) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: width, height: _height)
    }
    func withX(x _x: CGFloat) -> CGRect {
        return CGRect(x: _x, y: origin.y, width: width, height: height)
    }
    func withY(y _y: CGFloat) -> CGRect {
        return CGRect(x: origin.x, y: _y, width: width, height: height)
    }
}

extension Bool {
    /// Inspired by: https://twitter.com/TT_Kilew/status/922458025713119232/photo/1
    func `if`<T>(then valueIfTrue: T, else valueIfFalse: T) -> T {
        return self ? valueIfTrue : valueIfFalse
    }
}

/// https://benscheirman.com/2017/06/swift-json/
protocol DictionaryConvertible: Codable {
    // Starting from Swift 4, the mapping methods are genereated automatically behind the scenes
}

// Other considerations: https://stackoverflow.com/questions/29599005/how-to-convert-or-parse-swift-objects-to-json
extension DictionaryConvertible {
    static var decoder: JSONDecoder {
        get { return JSONDecoder() }
    }
    
    static var encoder: JSONEncoder {
        get { return JSONEncoder() }
    }
    
    static func fromDictionary<T: DictionaryConvertible>(objectDictionary: [AnyHashable:Any]) -> T? {
        let _objectDictionaryData: Data? = try? JSONSerialization.data(withJSONObject: objectDictionary, options: [])
        guard let objectDictionaryData = _objectDictionaryData else { return nil }
        guard let jsonString = String(data: objectDictionaryData, encoding: .utf8) else { return nil }
        
        return fromJson(jsonString: jsonString)
    }
    
    static func fromJson<T: DictionaryConvertible>(jsonString: String) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try? Self.decoder.decode(T.self, from: jsonData)
    }
    
    func toJsonString() -> String? {
        let _objectData: Data? = try? Self.encoder.encode(self)
        guard let objectData = _objectData else { return nil }
        return String(data: objectData, encoding: .utf8)
    }
    
    func toDictionary() -> [AnyHashable:Any] {
        let _objectData: Data? = try? Self.encoder.encode(self)
        guard let objectData = _objectData else { return [:] }
        
        guard let _firebaseDictionary = try? JSONSerialization.jsonObject(with: objectData, options: JSONSerialization.ReadingOptions.allowFragments) as? [AnyHashable: Any] else { return [:] }
        
        guard let firebaseDictionary = _firebaseDictionary else { return [:] }
        
        return firebaseDictionary
    }
}

extension NSError {
    static func create(errorDomain: String? = Bundle.main.bundleIdentifier, errorCode: Int, description: String, failureReason: String, underlyingError: Error?) -> NSError {
        var dict = [String: Any]()
        dict[NSLocalizedDescriptionKey] = description
        dict[NSLocalizedFailureReasonErrorKey] = failureReason

        if let underlyingError = underlyingError {
            dict[NSUnderlyingErrorKey] = underlyingError
        }

        return NSError(domain: errorDomain ?? "missing-domain", code: errorCode, userInfo: dict)
    }
}
