//
//  ConcurrencyViewController.swift
//  SomeApp
//
//  Created by Perry Shalom on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

class ConcurrencyViewController: UIViewController {

    let myQueue = DispatchQueue(label: "myQueue", attributes: DispatchQueue.Attributes.concurrent)
    let myGroup = DispatchGroup()
    var isVisible = false
    
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet var ungroupedProgressBar: UIProgressView!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var action1Spinner: UIActivityIndicatorView!
    @IBOutlet weak var action2Spinner: UIActivityIndicatorView!
    @IBOutlet weak var action3Spinner: UIActivityIndicatorView!

    let synchronizer = Synchronizer {
        runOnUiThread { // Without this, if the block will run on a background thread, you may get the following error: "This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird crashes.  This will cause an exception in a future release."
            ToastMessage.show(messageText: "released")
        }
    }
    
    var randomProgressBarIndexes: [Int]!

    func findNextRandomNumber() -> Int {
        repeat {
            let randomProgressBarIndex = Int(arc4random() % 4)
            if self.randomProgressBarIndexes.contains(randomProgressBarIndex) {
                Thread.sleep(forTimeInterval: 0.003)
            } else {
                return randomProgressBarIndex
            }
        } while true
    }

    func fillRandomProgressBarIndexes(_ onDone: @escaping () -> Void) {
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
        action3Spinner.stopAnimating()

        let holder1 = synchronizer.createHolder()
        action1Spinner.onClick {_ in 
            holder1.release()
            📘("action 1 dispatched")
            self.action1Spinner.stopAnimating()
        }
        let holder2 = synchronizer.createHolder()
        action2Spinner.onClick {_ in
            holder2.release()
            📘("action 2 dispatched")
            self.action2Spinner.stopAnimating()
        }
        let holder3 = synchronizer.createHolder()
        action3Spinner.onClick {_ in
            holder3.release()
            📘("action 2 dispatched")
            self.action3Spinner.stopAnimating()
        }

        openCountingThread()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isVisible = true
        resetProgressBars()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        isVisible = false
    }

    @IBAction func btnStartProgressPressed(_ sender: UIButton) {
        sender.animateFade(fadeIn: false)
        action1Spinner.startAnimating()
        action2Spinner.startAnimating()
        action3Spinner.startAnimating()
    }

    @IBAction func btnGoPressed(_ sender: UIButton) {
        guard randomProgressBarIndexes.contains(-1) == false else { return }

        sender.isEnabled = false

        myQueue.async(group: myGroup) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 1
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[0], withInterval: 0.02)
        }
        myQueue.async(group: myGroup) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 2
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[1], withInterval: 0.005)
        }
        myQueue.async(group: myGroup) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 3
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[2], withInterval: 0.05)
        }
        myQueue.async(group: myGroup) { [weak self] in
            guard let strongSelf = self else { return }
            //Task 4
            strongSelf.animateProgressRun(progressIndex: strongSelf.randomProgressBarIndexes[3], withInterval: 0.009)
        }
        myGroup.notify(queue: DispatchQueue.main) { [weak self] in
            // Will be dispatched on the main queue after all group is finished
            self?.ungroupedProgressBar.animateBounce()
        }

        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async {
            for progress in 1...100 {
                Thread.sleep(forTimeInterval: 0.001)

                if progress == 20 {
                    runOnUiThread() { [weak self] in
                        guard let strongSelf = self else { return }

                        ToastMessage.show(messageText: "dispatch_group_wait: started")
                        strongSelf.ungroupedProgressBar.animateBounce()
                    }

                    // 10 Seconds timeout
                    let succeeded = self.myGroup.wait(timeout: DispatchTime.timeWithSeconds(10))
                    if succeeded == DispatchTimeoutResult.timedOut {
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
        goButton.isEnabled = false
        fillRandomProgressBarIndexes { [weak self] in
            self?.goButton.isEnabled = true
        }

        for progressBar in progressBars {
            progressBar.setProgress(0.0, animated: false)
        }
        ungroupedProgressBar.setProgress(0.0, animated: false)
    }
    
    func animateProgressRun(progressIndex: Int, withInterval interval: TimeInterval) {
        for progress in 1...100 {
            Thread.sleep(forTimeInterval: interval)
            runOnUiThread() {
                self.progressBars[progressIndex].setProgress(Float(progress) / 100, animated: true)
            }
        }
    }

    func openCountingThread() {
        let myThread = Thread(target: self, selector: #selector(ConcurrencyViewController.countForever), object: nil)
        myThread.start()  // Actually creates the thread
    }

    func openCountingThread2() {
        Thread(target: self, selector: #selector(ConcurrencyViewController.countForever), object: nil).start()
    }
    
    func openCountingThread3() {
        Thread.detachNewThreadSelector(#selector(ConcurrencyViewController.countForever), toTarget: self, with: nil)
    }
    
    func countForever() {
        var time = 0
        while self.isVisible {
            Thread.sleep(forTimeInterval: 1)
            time += 1
            📘("counting \(time)")
        }
    }
}
