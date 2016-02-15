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
    var randomProgressBarIndex: Int {
        NSThread.sleepForTimeInterval(0.003)
        let randomProgressBarIndex = random() % 4
        var found = false
        dispatch_sync(myQueue) {
            if self.progressBarsLeftArray[randomProgressBarIndex] == -1 {
                self.progressBarsLeftArray[randomProgressBarIndex] = 0
                found = true
            }
        }
        if found {
            print("randomed: \(randomProgressBarIndex)")
            return randomProgressBarIndex
        } else {
            return self.randomProgressBarIndex
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        resetProgressBars()
    }

    @IBAction func btnGoPressed(sender: AnyObject) {
        guard progressBarsLeftArray.contains(-1) else { return }

        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 1
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndex, withInterval: 0.02)
        }
        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 2
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndex, withInterval: 0.005)
        }
        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 3
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndex, withInterval: 0.05)
        }
        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 4
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndex, withInterval: 0.009)
        }
        dispatch_group_notify(myGroup, dispatch_get_main_queue()) {
            // Being dispatched on main queue after all group is finished
            UIAlertController.alert(title: "That's it", message: "Done") {
                self.resetProgressBars()
            }
        }
    }

    func resetProgressBars() {
        progressBarsLeftArray.removeAll()

        for progressBar in progressBars {
            progressBarsLeftArray.append(-1)
            progressBar.setProgress(0.0, animated: false)
        }
    }
    
    func animateProgressRun(progressIndex progressIndex: Int, withInterval interval: NSTimeInterval) {
        for progress in 1...100 {
            NSThread.sleepForTimeInterval(interval)
            if progress == 50 {
                dispatch_group_wait(myGroup, 2)
            }
            runOnUiThread() {
                self.progressBars[progressIndex].setProgress(Float(progress) / 100, animated: true)
            }
        }
    }
    
}