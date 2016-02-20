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
    let myGroupSemaphore = dispatch_semaphore_create(0)
    
    @IBOutlet var ungroupedProgressBar: UIProgressView!
    @IBOutlet var progressBars: [UIProgressView]!
    var progressBarsLeftArray = [Int]()
    // Computed variable example (this computed var specifically must not run on the main thread due to sleep and synchronized block)
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
            log("randomed: \(randomProgressBarIndex)")
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
            runBlockAfterDelay(afterDelay: ToastMessageLength.SHORT.rawValue, block: { () -> Void in
                UIAlertController.alert(title: "dispatch_group_notify", message: "GCD Notified: All GCD group is done working.") { [weak self] in
                    self?.resetProgressBars()
                }
            })
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            for progress in 1...100 {
                NSThread.sleepForTimeInterval(0.001)

                if progress == 80 {
                    runOnUiThread() { [weak self] in
                        guard let strongSelf = self else { return }

                        ToastMessage.show(messageText: "dispatch_group_wait: start waiting to group", inView: strongSelf.view)//
                        strongSelf.ungroupedProgressBar.animateBump()
                    }

                    // 10 Seconds timeout
                    let succeeded = dispatch_group_wait(self.myGroup, dispatchTime(10))
                    if succeeded != 0 {
                        log("dispatch_group_wait failed!")
                    }
                    
                    // This code won't run until group is finished / timeout occured
                    runOnUiThread() { [weak self] in
                        guard let strongSelf = self else { return }

                        ToastMessage.show(messageText: "dispatch_group_wait: done waiting, progress may continue...", inView: strongSelf.view)//
                        strongSelf.ungroupedProgressBar.animateBump()
                    }
                }

                runOnUiThread() {
                    self.ungroupedProgressBar.setProgress(Float(progress) / 100, animated: true)
                }
            }
        }
    }

    func resetProgressBars() {
        progressBarsLeftArray.removeAll()

        for progressBar in progressBars {
            progressBarsLeftArray.append(-1)
            progressBar.setProgress(0.0, animated: false)
        }
        ungroupedProgressBar.setProgress(0.0, animated: false)
    }
    
    func animateProgressRun(progressIndex progressIndex: Int, withInterval interval: NSTimeInterval) {
        for progress in 1...100 {
            NSThread.sleepForTimeInterval(interval)
            runOnUiThread() {
                self.progressBars[progressIndex].setProgress(Float(progress) / 100, animated: true)
            }
        }
    }
    
}