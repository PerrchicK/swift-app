//
//  OperatorsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

class OperatorsViewController: UIViewController {
    
    @IBOutlet weak var valueTextField: UITextField!
    
    // MARK: - Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Additional setup after loading the view, typically from a nib.
        self.title = "Operators Overloading" // & 'Associated ObjC Objects'
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss:"))

        valueTextField.placeholder = "value that a String object will love"
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        valueTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setButtonPressed(sender: AnyObject) {
        valueTextField.resignFirstResponder()

        var lovingResult : AnyObject?
        
        do {
            lovingResult = try valueTextField.😘(beloved: valueTextField.text!)
        } catch {
        }
        
        defer {
            if let lovingResult = lovingResult as? Bool {
                let isThisLove = lovingResult ? "❤️" : "💔"
                
                UIAlertController.alert(title: "love result", message: isThisLove)
                
                valueTextField.text = ""
            }
        }
    }
    
    @IBAction func getButtonPressed(sender: AnyObject) {
        valueTextField.resignFirstResponder()

        if let beloved = valueTextField.😍() {
            UIAlertController.alert(title: "beloved string", message: beloved)
        }
    }
    
    func dismiss(gestureRecognizer: UIGestureRecognizer) {
        📘("Dismissing keyboard due to \(gestureRecognizer)")
        valueTextField.resignFirstResponder()
    }
    
    // MARK: - Other super class methods
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            // Show local UI live debugging tool
            FLEXManager.sharedManager().showExplorer() // Delete if it doesn't exist
        }
    }
    
}