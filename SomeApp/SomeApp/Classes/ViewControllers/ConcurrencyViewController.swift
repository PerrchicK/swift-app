//
//  ConcurrencyViewController.swift
//  SomeApp
//
//  Created by Perry Shalom on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import UIKit

/// Reference: https://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized
func synchronized(_ lock: Any, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

class ConcurrencyViewController: UIViewController {

    // Grand Central Dispatch (GCD) usage
    let myQueue = DispatchQueue(label: "myQueue", attributes: DispatchQueue.Attributes.concurrent)
    let myGroup = DispatchGroup()
    lazy var isAppeared: Bool = false

    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet var ungroupedProgressBar: UIProgressView!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var action1Spinner: UIActivityIndicatorView!
    @IBOutlet weak var action2Spinner: UIActivityIndicatorView!
    @IBOutlet weak var action3Spinner: UIActivityIndicatorView!

    // OperationQueue class usage
    let synchronizer = Synchronizer {
        ToastMessage.show(messageText: "released")
    }
    
    var randomProgressBarIndexes: [Int]!

    func findNextRandomNumber() -> Int {
        repeat {
            let randomProgressBarIndex = 0 ~ 4
            if self.randomProgressBarIndexes.contains(randomProgressBarIndex) {
                Thread.sleep(forTimeInterval: 0.003)
            } else {
                return randomProgressBarIndex
            }
        } while true
    }

    private func fillAllRandomProgressBarIndexes(_ onDone: @escaping () -> Void) {
        randomProgressBarIndexes = [-1,-1,-1,-1]

        let v = UIView()
        v.isPresented = true

        // Sync the async:
        func _fillRandomProgressBarIndexes(index: Int = 0, onDone: @escaping () -> Void) {
            guard let _ = self.randomProgressBarIndexes[safe: index] else { onDone(); return }
            let randomIndex = self.findNextRandomNumber()
            self.randomProgressBarIndexes[index] = randomIndex
            📘("Random \(index): \(randomIndex)")
            
            _fillRandomProgressBarIndexes(index: index + 1, onDone: onDone)
        }
        
        _fillRandomProgressBarIndexes(onDone: onDone)

//        Synchronizer.syncOperations({
//            Thread.sleep(forTimeInterval: 0.01)
//        },{
//            Thread.sleep(forTimeInterval: 0.02)
//            let rand = self.findNextRandomNumber()
//            self.randomProgressBarIndexes[1] = rand
//            📘("Random 1: \(rand)")
//        },{
//            Thread.sleep(forTimeInterval: 0.03)
//            let rand = self.findNextRandomNumber()
//            self.randomProgressBarIndexes[2] = rand
//            📘("Random 2: \(rand)")
//        },{
//            Thread.sleep(forTimeInterval: 0.04)
//            let rand = self.findNextRandomNumber()
//            self.randomProgressBarIndexes[3] = rand
//            📘("Random 3: \(rand)")
//        }, withFinalOperation: {
//            onDone()
//        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        action1Spinner.stopAnimating()
        action2Spinner.stopAnimating()
        action3Spinner.stopAnimating()

        let holder1 = synchronizer.createHolder()
        action1Spinner.onClick { [weak self] _ in
            holder1.release()
            📘("action 1 dispatched")
            self?.action1Spinner.stopAnimating()
        }
        let holder2 = synchronizer.createHolder()
        action2Spinner.onClick { [weak self] _ in
            holder2.release()
            📘("action 2 dispatched")
            self?.action2Spinner.stopAnimating()
        }
        let holder3 = synchronizer.createHolder()
        action3Spinner.onClick { [weak self] _ in
            holder3.release()
            📘("action 2 dispatched")
            self?.action3Spinner.stopAnimating()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        resetProgressBars()
        isAppeared = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        openCountingThread_3()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isAppeared = false
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

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
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
        fillAllRandomProgressBarIndexes { [weak self] in
            self?.goButton.isEnabled = true
        }

        progressBars.forEach { (progressView) in
            progressView.setProgress(0.0, animated: false)
        }
        ungroupedProgressBar.setProgress(0.0, animated: false)
    }
    
    func animateProgressRun(progressIndex: Int, withInterval interval: TimeInterval) {
        for progress in 1...100 {
            Thread.sleep(forTimeInterval: interval)
            DispatchQueue.main.sync(execute: {
                self.progressBars[progressIndex].setProgress(Float(progress) / 100, animated: true)
            })
        }
    }

    func openCountingThread_1() {
        let myThread = Thread(target: self, selector: #selector(ConcurrencyViewController.countForever), object: "1")
        myThread.start()  // Actually creates the thread
    }

    func openCountingThread_2() {
        Thread(target: self, selector: #selector(ConcurrencyViewController.countForever), object: "2").start()
    }
    
    func openCountingThread_3() {
        Thread.detachNewThreadSelector(#selector(ConcurrencyViewController.countForever), toTarget: self, with: "3")
    }
    
    func countForever(argument: Any?) {
        var time = 0
        while self.isAppeared {
            Thread.sleep(forTimeInterval: 1)
            time += 1
            📘("counting (\(time) til now) on thread with argument: \(String(describing: argument))")
        }
    }
    
    deinit {
        📘("I'm dead 💀")
    }
}
