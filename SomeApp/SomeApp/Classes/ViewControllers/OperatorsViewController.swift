//
//  OperatorsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit

class OperatorsViewController: UIViewController {
    
    @IBOutlet weak var valueTextField: UITextField!
    
    // MARK: - Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Additional setup after loading the view, typically from a nib.
        self.title = "Operators Overloading" // & 'Associated ObjC Objects'
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OperatorsViewController.dismiss(_:))))

        valueTextField.placeholder = "value that a String object will love"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        valueTextField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setButtonPressed(_ sender: AnyObject) {
        valueTextField.resignFirstResponder()

        var lovingResult : AnyObject?
        
        do {
            lovingResult = try valueTextField.😘(belovedObject: valueTextField.text! as AnyObject) as AnyObject?
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
    
    @IBAction func getButtonPressed(_ sender: AnyObject) {
        valueTextField.resignFirstResponder()

        if let beloved = valueTextField.😍() as? String {
            UIAlertController.alert(title: "beloved string", message: beloved)
        }
    }
    
    func dismiss(_ tapGestureRecognizer: UIGestureRecognizer) {
        📘("Dismissing keyboard due to \(tapGestureRecognizer)")
        valueTextField.resignFirstResponder()
    }
}
