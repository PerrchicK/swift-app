//
//  ConcurrencyViewController.swift
//  SomeApp
//
//  Created by Perry Shalom on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class ConcurrencyViewController: UIViewController {

    let synchronizer = Synchronizer {
        // Runs in a background queue

        runOnUiThread { // Without this, you will get the following error: "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird crashes.  This will cause an exception in a future release."
            ToastMessage.show(messageText: "released")
        }
    }

    let myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT)
    let myGroup = dispatch_group_create()
    var isVisible = false
    
    @IBOutlet var ungroupedProgressBar: UIProgressView!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var action1Spinner: UIActivityIndicatorView!
    @IBOutlet weak var action2Spinner: UIActivityIndicatorView!

    var progressBarsLeftArray = [Int]()
    // Computed variable example (this computed var specifically must not run on the main thread due to sleep and synchronized block)
    var randomProgressBarIndex: Int {
        NSThread.sleepForTimeInterval(0.003)
        var randomProgressBarIndex = random() % 4
        var found = false
        dispatch_sync(myQueue) {
            if self.progressBarsLeftArray[randomProgressBarIndex] == -1 {
                self.progressBarsLeftArray[randomProgressBarIndex] = 0
                found = true
            }
        }
        if found {
            📘("randomed: \(randomProgressBarIndex)")
            return randomProgressBarIndex
        } else {
            if self.progressBarsLeftArray.filter({ return $0 == -1 }).count == 1 {
                for idx in 0...self.progressBarsLeftArray.count {
                    if self.progressBarsLeftArray[idx] == -1 {
                        randomProgressBarIndex = idx
                    }
                }
            } else {
                randomProgressBarIndex = self.randomProgressBarIndex
            }
            return randomProgressBarIndex
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        action1Spinner.stopAnimating()
        action2Spinner.stopAnimating()

        action1Spinner.onClick {_ in 
            self.synchronizer.do1()
            📘("action 1 dispatched")
            self.action1Spinner.stopAnimating()
        }
        action2Spinner.onClick {_ in
            self.synchronizer.do2()
            📘("action 2 dispatched")
            self.action2Spinner.stopAnimating()
        }

        openCountingThread()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        isVisible = true
        resetProgressBars()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        isVisible = false
    }

    @IBAction func btnStartProgressPressed(sender: UIButton) {
        sender.animateFade(fadeIn: false)
        action1Spinner.startAnimating()
        action2Spinner.startAnimating()
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
            runBlockAfterDelay(afterDelay: ToastMessage.ToastMessageLength.SHORT.rawValue, block: { () -> Void in
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

                        ToastMessage.show(messageText: "dispatch_group_wait: start waiting to group")
                        strongSelf.ungroupedProgressBar.animateBounce()
                    }

                    // 10 Seconds timeout
                    let succeeded = dispatch_group_wait(self.myGroup, dispatch_time_t.timeWithSeconds(10))
                    if succeeded != 0 {
                        📘("dispatch_group_wait failed!")
                    }
                    
                    // This code won't run until group is finished / timeout occured
                    runOnUiThread() { [weak self] in
                        guard let strongSelf = self else { return }

                        ToastMessage.show(messageText: "dispatch_group_wait: done waiting, progress may continue...")
                        strongSelf.ungroupedProgressBar.animateBounce()
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

    func openCountingThread() {
        let myThread = NSThread(target: self, selector: #selector(ConcurrencyViewController.countForever), object: nil)
        myThread.start()  // Actually creates the thread
    }

    func openCountingThread2() {
        NSThread(target: self, selector: #selector(ConcurrencyViewController.countForever), object: nil).start()
    }
    
    func openCountingThread3() {
        NSThread.detachNewThreadSelector(#selector(ConcurrencyViewController.countForever), toTarget: self, withObject: nil)
    }
    
    func countForever() {
        var time = 0
        while self.isVisible {
            NSThread.sleepForTimeInterval(1)
            time += 1
            print("counting \(time)")
        }
    }
}