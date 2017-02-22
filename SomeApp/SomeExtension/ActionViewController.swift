//
//  ActionViewController.swift
//  SomeExtension
//
//  Created by Perry on 19/04/2016.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit
import MobileCoreServices

// Created by Apple, modified by Perry
class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        for item: Any in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            for provider: Any in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    // This is an image! We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (sharedImage, error) in
                        OperationQueue.main.addOperation {
                            if let strongImageView = weakImageView {
                                if let image = sharedImage as? UIImage { // Modified by Perry
                                    strongImageView.image = image
                                    strongImageView.alpha = 1
                                }
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) { // Added by Perry
                    // This is a text!
                    weak var weakTextView = self.textView
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (sharedText, error) in
                        OperationQueue.main.addOperation {
                            if let strongTextView = weakTextView {
                                if let someText = sharedText as? String {
                                    strongTextView.text = someText
                                }
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}
