//
//  OperatorsViewController.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import UIKit
import OnGestureSwift
//import SwiftyScryptoString

class OperatorsViewController: UIViewController {
    
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var draggedLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Additional setup after loading the view, typically from a nib.
        self.title = "Operators Overloading" // & 'Associated ObjC Objects'
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OperatorsViewController.dismiss(_:))))

        valueTextField.placeholder = "value that a String object will hug"
        var pannedPoint: CGPoint? = nil
        var offsetPoint: CGPoint? = nil
        var startPoint: CGPoint? = nil
        var relativeStartPoint: CGPoint? = nil

        draggedLabel.onDrag(onDragClosure: { [weak self] (onPanListener) in
            guard let draggedView = onPanListener.view,
                let superview = draggedView.superview else { return }
            
            let locationOfTouch = onPanListener.location(in: superview)

            switch onPanListener.state {
            case .cancelled: fallthrough
            case .ended: break
            case .began:
                relativeStartPoint = locationOfTouch
                startPoint = draggedView.center - locationOfTouch
                fallthrough
            default:
                if let startPoint = startPoint {
                    pannedPoint = CGPoint(x: locationOfTouch.x + (startPoint.x), y: locationOfTouch.y + (startPoint.y))
                    offsetPoint = locationOfTouch - startPoint // CGPoint - CGPoint
                }
                
                if let relativeStartPoint = relativeStartPoint {
                    offsetPoint = locationOfTouch - relativeStartPoint
                }
            }

            if var offsetPoint = offsetPoint {
                📘("offsetPoint: \(offsetPoint)")
                offsetPoint.x = offsetPoint.x.rounded(byPrecision: 2)
                offsetPoint.y = offsetPoint.y.rounded(byPrecision: 2)

                self?.positionLabel.text = "\(offsetPoint)"
            }
            if let pannedPoint = pannedPoint {
                📘("pannedPoint: \(pannedPoint)")
            }
        })

        positionLabel.text = ""

//        draggedLabel.onPan({ (gestureRecognizer) in
//            guard let onPanListener = gestureRecognizer as? OnPanListener else { return }
//
//            if let offsetPoint = onPanListener.offsetPoint {
//                📘("offsetPoint: \(offsetPoint)")
//            }
//            if let pannedPoint = onPanListener.pannedPoint {
//                📘("pannedPoint: \(pannedPoint)")
//            }
//        })

//        let encrypted = "my private key".encrypt(withPassword: "1234")
//        📘("encrypted: \(encrypted)")
//        let decrypted = encrypted.decrypt(withPassword: "1234")
//        📘("decrypted: \(decrypted)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        draggedLabel.center = view.center
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        PerrFuncs.verifyDeviceOwner { (didSucceed) in
            guard let didSucceed = didSucceed else { return }
            📘(didSucceed)
        }
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
            let p: PersistableUser = PersistableUser(email: text, firstName: text, lastName: text, nickname: text)
            huggingResult = valueTextField.😘(huggedObject: text)
            valueTextField.😘(huggedObject: p)
        } else {
            huggingResult = false
        }

        defer {
            let isThisLove = huggingResult ? "❤️" : "💔"
            
            UIAlertController.alert(title: "hugging result", message: isThisLove)
            
            valueTextField.text = ""
        }
    }
    
    @IBAction func getButtonPressed(_ sender: AnyObject) {
        valueTextField.resignFirstResponder()

        if let beloved = valueTextField.😍() as? String {
            UIAlertController.alert(title: "hugged string", message: beloved)
        }
    }
    
    @objc func dismiss(_ tapGestureRecognizer: UIGestureRecognizer) {
        📘("Dismissing keyboard due to \(tapGestureRecognizer.pointerAddress)")
        valueTextField.resignFirstResponder()
    }
}

extension CGFloat {
    func rounded(byPrecision precision: UInt) -> CGFloat {
        guard precision > 0 else { return rounded(FloatingPointRoundingRule.toNearestOrEven) }
        
        func pow(num: Int, power: UInt) -> Int {
            if power == 0 {
                return 1
            }
            if power == 1 {
                return num
            }

            return pow(num: num, power: power - 1) * num
        }

        let offset = CGFloat(pow(num: 10, power: precision))
        var result = self
        result *= offset
        result.round(FloatingPointRoundingRule.toNearestOrEven)
        result /= offset
        return result
    }
}
