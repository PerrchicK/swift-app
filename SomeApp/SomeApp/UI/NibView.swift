//
//  NibView.swift
//  SomeApp
//
//  Referenced from: https://github.com/n-b/UIView-NibLoading/blob/master/UIView+NibLoading.m

import Foundation

public class NibView: UIView {

    private struct AssociatedKeys {
        static var NibsKey = "nibViewNibsAssociatedKeys"
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewContentsFromNib()
        
        // Notify event
        viewContentsDidLoadFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewContentsFromNib()

        // Notify event
        viewContentsDidLoadFromNib()
    }
    
    func viewContentsDidLoadFromNib() {
        // Override in children to get this event...
    }
    
    private static func _nibLoadingAssociatedNibWithName(nibName: String) -> UINib? {
        
        let associatedNibs = objc_getAssociatedObject(self, &AssociatedKeys.NibsKey) as? NSDictionary
        var nib: UINib? = associatedNibs?.objectForKey(nibName) as? UINib
        
        if (nib == nil) {
            nib = UINib(nibName: nibName, bundle: nil)
            
            let updatedAssociatedNibs = NSMutableDictionary()
            if (associatedNibs != nil) {
                updatedAssociatedNibs.addEntriesFromDictionary(associatedNibs! as! [String:UINib])
            }
            
            updatedAssociatedNibs.setObject(nib!, forKey: nibName)
            objc_setAssociatedObject(self, &AssociatedKeys.NibsKey, updatedAssociatedNibs, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return nib
    }
    
    public func loadViewContentsFromNib() {
        loadViewContentsFromNibNamed(className(self.dynamicType))
    }
    
    public func loadViewContentsFromNibNamed(nibName:String) {
        
        let nib = self.dynamicType._nibLoadingAssociatedNibWithName(nibName)
        
        if let nib = nib {
            
            let views = nib.instantiateWithOwner(self, options: nil) as NSArray
            assert(views.count == 1, "There must be exactly one root container view in \(nibName)")
            
            let containerView = views.firstObject as! UIView
            
            assert(containerView.isKindOfClass(UIView.self) || containerView.isKindOfClass(self.dynamicType), "UIView+NibLoading: The container view in nib \(nibName) should be a UIView instead of \(className(containerView.dynamicType)). (It's only a container, and it's discarded after loading.")
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            if CGRectEqualToRect(self.bounds, CGRectZero) {
                //`self` has no size : use the containerView's size, from the nib file
                self.bounds = containerView.bounds
            }
            else {
                //`self` has a specific size : resize the containerView to this size, so that the subviews are autoresized.
                containerView.bounds = self.bounds
            }
            
            //save constraints for later
            let constraints = containerView.constraints
            
            //reparent the subviews from the nib file
            for view in containerView.subviews {
                self.addSubview(view)
            }
            
            //re-add constraints, replace containerView with self
            for constraint in constraints {
                
                var firstItem = constraint.firstItem
                var secondItem = constraint.secondItem
                
                if (firstItem as? NSObject == containerView) {
                    firstItem = self
                }
                
                if (secondItem as? NSObject == containerView) {
                    secondItem = self
                }
                
                //re-add
                self.addConstraint(NSLayoutConstraint(item: firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            }
        }
        else {
            assert(nib != nil, "UIView+NibLoading : Can't load nib named \(nibName)")
        }
    }
}