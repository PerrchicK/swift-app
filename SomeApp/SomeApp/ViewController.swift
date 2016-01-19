//
//  ViewController.swift
//  SomeApp
//
//  Created by Perry on 1/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var valueTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss:"))
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "dismiss:"))
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func dismiss(gestureRecognizer: UIGestureRecognizer) {
        print("Dismissing keyboard due to \(gestureRecognizer)")
        valueTextField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setButtonPressed(sender: AnyObject) {
        var lovingResult : AnyObject?
        
        do {
            lovingResult = try valueTextField.😘(beloved: valueTextField.text!)
        } catch {
        }
        
        defer {
            if let lovingResult = lovingResult as? Bool {
                let isThisLove = lovingResult ? "❤️" : "💔"
                
                alert("love result", message: isThisLove)
                
                valueTextField.text = ""
            }
        }
    }
    
    // Question: What is the problem in the following function?
    @IBAction func getButtonPressed(sender: AnyObject) {
        if let beloved = valueTextField.😍() {
            alert("beloved string", message: beloved)
        }
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            // Do nothing...
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}