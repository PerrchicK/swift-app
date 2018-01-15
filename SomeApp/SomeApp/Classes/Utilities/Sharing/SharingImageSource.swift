//
//  SharingImageSource.swift
//  SomeApp
//
//  Created by Perry on 4/14/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class SharingImageSource: NSObject, UIActivityItemSource {
    fileprivate var image: UIImage

    let activityTypeMyApp = "com.perrchick.SomeApp.SomeExtension"

    init(image: UIImage) {
        self.image = image
        super.init() // AFTER assignment, only because the image is not optional
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        
        switch activityType?.rawValue {
        case UIActivityType.message.rawValue?:
            fallthrough
        case UIActivityType.saveToCameraRoll.rawValue?:
            fallthrough
        case UIActivityType.mail.rawValue?:
            fallthrough
        case "net.whatsapp.WhatsApp.ShareExtension"?:
            fallthrough
        case activityTypeMyApp?:
            return self.image
        default:
            return nil
        }
    }
}
