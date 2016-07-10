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
    var isVisible = false
    
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet var ungroupedProgressBar: UIProgressView!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var action1Spinner: UIActivityIndicatorView!
    @IBOutlet weak var action2Spinner: UIActivityIndicatorView!

    let synchronizer = Synchronizer(operation1: {
        // Do something
        📘("operation 1 is done")
        }, operation2: {
            // Do something
            📘("operation 2 is done")
        }, finalOperation: {
            // Runs in a background queue
            
            runOnUiThread { // Without this, you will get the following error: "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird crashes.  This will cause an exception in a future release."
                ToastMessage.show(messageText: "released")
            }
    })
    
    var randomProgressBarIndexes: [Int]!

    func findNextRandomNumber() -> Int {
        repeat {
            let randomProgressBarIndex = random() % 4
            if self.randomProgressBarIndexes.contains(randomProgressBarIndex) {
                NSThread.sleepForTimeInterval(0.003)
            } else {
                return randomProgressBarIndex
            }
        } while true
    }

    func fillRandomProgressBarIndexes(onDone: () -> Void) {
        randomProgressBarIndexes = [-1,-1,-1,-1]

        Synchronizer.syncOperations({
            let rand = self.findNextRandomNumber()
            self.randomProgressBarIndexes[0] = rand
            📘("Random 0: \(rand)")
        },{
            let rand = self.findNextRandomNumber()
            self.randomProgressBarIndexes[1] = rand
            📘("Random 1: \(rand)")
        },{
            let rand = self.findNextRandomNumber()
            self.randomProgressBarIndexes[2] = rand
            📘("Random 2: \(rand)")
        },{
            let rand = self.findNextRandomNumber()
            self.randomProgressBarIndexes[3] = rand
            📘("Random 3: \(rand)")
        }, withFinalOperation: {
            onDone()
        })
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

    @IBAction func btnGoPressed(sender: UIButton) {
        guard randomProgressBarIndexes.contains(-1) == false else { return }

        sender.enabled = false

        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 1
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[0], withInterval: 0.02)
        }
        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 2
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[1], withInterval: 0.005)
        }
        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 3
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[2], withInterval: 0.05)
        }
        dispatch_group_async(myGroup, myQueue) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 4
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[3], withInterval: 0.009)
        }
        dispatch_group_notify(myGroup, dispatch_get_main_queue()) { [weak self] in
            // Will be dispatched on the main queue after all group is finished
            self?.ungroupedProgressBar.animateBounce()
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            for progress in 1...100 {
                NSThread.sleepForTimeInterval(0.001)

                if progress == 20 {
                    runOnUiThread() { [weak self] in
                        guard let strongSelf = self else { return }

                        ToastMessage.show(messageText: "dispatch_group_wait: started")
                        strongSelf.ungroupedProgressBar.animateBounce()
                    }

                    // 10 Seconds timeout
                    let succeeded = dispatch_group_wait(self.myGroup, dispatch_time_t.timeWithSeconds(10))
                    if succeeded != 0 {
                        📘("dispatch_group_wait failed!")
                    }
                    
                    // This code won't run until group is finished / timeout occured
                    runOnUiThread() { [weak self] in
                        ToastMessage.show(messageText: "dispatch_group_wait: finished...") { [weak self] in
                            self?.resetProgressBars()
                        }
                    }
                }

                runOnUiThread() {
                    self.ungroupedProgressBar.setProgress(Float(progress) / 100, animated: true)
                }
            }
        }
    }

    func resetProgressBars() {
        goButton.enabled = false
        fillRandomProgressBarIndexes { [weak self] in
            self?.goButton.enabled = true
        }

        for progressBar in progressBars {
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
            📘("counting \(time)")
        }
    }
}