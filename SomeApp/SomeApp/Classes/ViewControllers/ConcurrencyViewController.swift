//
//  ConcurrencyViewController.swift
//  SomeApp
//
//  Created by Perry Shalom on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class ConcurrencyViewController: UIViewController {
    let myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT)
    let myGroup = dispatch_group_create()

    @IBOutlet var progressBars: [UIProgressView]!
    var progressBarsLeftArray = [Int]()
    var progressBarsLeft = 0
    var randomProgressBarIndex: Int {
//        NSThread.sleepForTimeInterval(0.00003)
//        var randomProgressBarIndex = random() % 4
//        dispatch_sync(myQueue) {
//            if self.progressBarsLeft[randomProgressBarIndex] == -1 {
//                self.progressBarsLeft[randomProgressBarIndex] = 0
//            } else {
//                randomProgressBarIndex = self.randomProgressBarIndex
//            }
//        }
//        print("randomed: \(randomProgressBarIndex)")
//        return randomProgressBarIndex
        return --progressBarsLeft
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        resetProgressBars()
    }

    @IBAction func btnGoPressed(sender: AnyObject) {
        dispatch_group_async(myGroup, myQueue) {
            //Task 1
            self.animateProgressRun(progressIndex: self.randomProgressBarIndex, withInterval: 0.02)
        }
        dispatch_group_async(myGroup, myQueue) {
            //Task 2
            self.animateProgressRun(progressIndex: self.randomProgressBarIndex, withInterval: 0.005)
        }
        dispatch_group_async(myGroup, myQueue) {
            //Task 3
            self.animateProgressRun(progressIndex: self.randomProgressBarIndex, withInterval: 0.05)
        }
        dispatch_group_async(myGroup, myQueue) {
            //Task 4
            self.animateProgressRun(progressIndex: self.randomProgressBarIndex, withInterval: 0.009)
        }
        dispatch_group_notify(myGroup, dispatch_get_main_queue()) {
            // Being dispatched on main queue after all group is finished
            UIAlertController.alert(title: "That's it", message: "Done") {
                self.resetProgressBars()
            }
        }
    }

    func resetProgressBars() {
//        progressBarsLeft.removeAll()
        progressBarsLeft = progressBars.count

        for progressBar in progressBars {
//            progressBarsLeft.append(-1)
            progressBar.setProgress(0.0, animated: false)
        }
    }
    
    func animateProgressRun(progressIndex progressIndex: Int, withInterval interval: NSTimeInterval) {
        for progress in 1...100 {
            NSThread.sleepForTimeInterval(interval)
//                dispatch_group_notify(myGroup, myQueue, {})
            if progress == 50 {
                dispatch_group_wait(myGroup, 2)
            }
            runOnUiThread() {
                self.progressBars[progressIndex].setProgress(Float(progress) / 100, animated: true)
            }
        }
    }
    
}