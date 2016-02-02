//
//  StarterViewController.swift
//  SomeApp
//
//  Created by Perry on 1/19/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class StarterViewController: UIViewController {

    @IBOutlet weak var valueTextField: UITextField!

    // MARK: - Lifcycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss:"))
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "dismiss:"))
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
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
                
                UIAlertController.alert(title: "love result", message: isThisLove)
                
                valueTextField.text = ""
            }
        }
    }
    
    // Question: What is the problem in the following function?
    @IBAction func getButtonPressed(sender: AnyObject) {
        if let beloved = valueTextField.😍() {
            UIAlertController.alert(title: "beloved string", message: beloved)
        }
    }
    
    func dismiss(gestureRecognizer: UIGestureRecognizer) {
        print("Dismissing keyboard due to \(gestureRecognizer)")
        valueTextField.resignFirstResponder()
    }
}