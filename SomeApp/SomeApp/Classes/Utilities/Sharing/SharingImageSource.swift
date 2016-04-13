//
//  SharingImageSource.swift
//  SomeApp
//
//  Created by Perry on 4/14/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

class SharingImageSource: NSObject, UIActivityItemSource {
    private var image: UIImage
    
    init(image: UIImage) {
        self.image = image
        super.init()
    }

    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return UIImage()
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        
        switch activityType {
        case UIActivityTypeMessage:
            fallthrough
        case UIActivityTypeSaveToCameraRoll:
            fallthrough
        case UIActivityTypeMail:
            return self.image
        default:
            return nil
        }
    }
}