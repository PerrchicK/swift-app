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
    @IBOutlet weak var draggedLabel: UILabel!

    // MARK: - Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Additional setup after loading the view, typically from a nib.
        self.title = "Operators Overloading" // & 'Associated ObjC Objects'
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OperatorsViewController.dismiss(_:))))

        valueTextField.placeholder = "value that a String object will love"
        
        draggedLabel.onDrag(onDragClosure: { (point) in
            📘(point)
        })

//        draggedLabel.onPan({ (recognizer) in
//            if let offsetPoint = (recognizer as? OnPanListener)?.offsetPoint {
//                📘(offsetPoint)
//            }
//        })
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

        var huggingResult: Bool
        if let text = valueTextField.text {
            huggingResult = valueTextField.😘(huggedObject: text)
        } else {
            huggingResult = false
        }

        defer {
            let isThisLove = huggingResult ? "❤️" : "💔"
            
            UIAlertController.alert(title: "love result", message: isThisLove)
            
            valueTextField.text = ""
        }
    }
    
    @IBAction func getButtonPressed(_ sender: AnyObject) {
        valueTextField.resignFirstResponder()

        if let beloved = valueTextField.😍() as? String {
            UIAlertController.alert(title: "beloved string", message: beloved)
        }
    }
    
    @objc func dismiss(_ tapGestureRecognizer: UIGestureRecognizer) {
        📘("Dismissing keyboard due to \(tapGestureRecognizer)")
        valueTextField.resignFirstResponder()
    }
}
