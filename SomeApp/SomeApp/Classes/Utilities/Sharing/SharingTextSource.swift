//
//  SharingTextSource.swift
//  SomeApp
//
//  Created by Perry on 4/14/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class SharingTextSource: NSObject, UIActivityItemSource {

    // Don’t rely on that so easily, this might change at any version WhatsApp are distributing
    let activityTypeWhatsApp = "net.whatsapp.WhatsApp.ShareExtension"

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivityType) -> Any? {
        var shareText = "Yo check this out!"
        switch activityType.rawValue {
        case activityTypeWhatsApp:
            shareText = "Whazzzzup? 😝" + shareText
        case UIActivityType.message.rawValue:
            shareText += " (I hope your iMessage is on)"
        case UIActivityType.mail.rawValue:
            fallthrough // Consider building an HTML body
        case UIActivityType.postToFacebook.rawValue:
            fallthrough // Consider taking a sharing URL in facebook
        default:
            shareText = MainViewController.projectLocationInsideGitHub
        }

        return shareText
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivityType?) -> String {
        return "Shared from SomeApp"
    }
}
