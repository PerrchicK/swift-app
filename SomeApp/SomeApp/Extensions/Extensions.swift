//
//  Extensions.swift
//  SomeApplication
//
//  Created by Perry on 1/8/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import ObjectiveC

// Declare a global var to produce a unique address as the assoc object handle
var SompApplicationBelovedProperty: UInt8 = 0

// Question: What is redundant in this code?

//infix operator 😘 { associativity left precedence 140 }
func 😘(left: NSObject, right: String) throws -> Bool {
    return try left.😘(beloved: right)
}

extension NSObject { // try AnyObject first...
    //infix operator 😘 { associativity left precedence 140 }
    func 😘(beloved beloved: String) throws -> Bool {
        guard beloved.characters.count > 0 else {
            return false
        }

        print("loving \(beloved)")
        
        // "Hard" guard
        //assert(beloved.characters.count > 0, "non-empty strings only")
        
        objc_setAssociatedObject(self, &SompApplicationBelovedProperty, beloved, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return true
    }

    func 😍() -> String? { // 1
        //print("loving \(right)")
        guard let value = objc_getAssociatedObject(self, &SompApplicationBelovedProperty) as? String else {
            return nil
        }
        
        return value
    }
}

extension UIAlertController {
    
    /**
     A service method that alerts with title and message in the top view controller
     
     - parameter title: The title of the UIAlertView
     - parameter message: The message inside the UIAlertView
     */
    static func alert(title title: String, message: String, dismissButtonTitle:String = "OK", onGone: (() -> Void)? = nil) {
        guard var topController = UIApplication.sharedApplication().keyWindow?.rootViewController else {
            return
        }
        
        // topController should now be the most top view controller
        if let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: dismissButtonTitle, style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            guard let onGone = onGone else {
                return
            }
            
            onGone()
        }))
        
        topController.presentViewController(alertController, animated: true, completion: nil)
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

extension UIView {

    // MARK: - Animations
    public func animateBump(completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.2, 1.2)
        }, completion: completion)
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
    public func show(show show: Bool) {
        self.hidden = !show
    }
}