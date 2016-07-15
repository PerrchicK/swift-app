//
//  ImagesAndMotionViewController.swift
//  SomeApp
//
//  Created by Perry on 04/04/2016.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
import CoreMotion
import AVFoundation
import MobileCoreServices
import BetterSegmentedControl

class ImagesAndMotionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    let imagePickerController = UIImagePickerController()
    let manager = CMMotionManager()
    
    @IBOutlet weak var gyroDataLabel: UILabel!
    @IBOutlet weak var pickedImageButton: UIButton!
    @IBOutlet weak var betterSegmentedControl_source_PlaceHolder: UIView!
    @IBOutlet weak var betterSegmentedControl_type_PlaceHolder: UIView!
    @IBOutlet weak var betterSegmentedControl_isEditable_PlaceHolder: UIView!

    @IBOutlet weak var cameraLensPreviewButton: UIButton!
    
    // More info at: https://littlebitesofcocoa.com/226-bettersegmentedcontrol
    var sourceControl: BetterSegmentedControl!
    var typeControl: BetterSegmentedControl!
    var isEditableControl: BetterSegmentedControl!

    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraLensImage: UIImage?

    // Computed variable example
    var isEditable: Bool {
        return isEditableControl.index == 0
    }

    enum MediaType: String {
        case Both
        case Videos
        case Photos
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize snapshot image view
        self.cameraLensPreviewButton.contentMode = .ScaleAspectFill
        self.cameraLensPreviewButton.clipsToBounds = true
        self.cameraLensPreviewButton.layer.cornerRadius = 12

        // Initialize picker image view
        pickedImageButton.layer.cornerRadius = 3
        pickedImageButton.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.7).CGColor
        pickedImageButton.layer.borderWidth = 1
        // More info about 'contentMode' at: http://stackoverflow.com/questions/4895272/difference-between-uiviewcontentmodescaleaspectfit-and-uiviewcontentmodescaletof
        pickedImageButton.imageView?.contentMode = .ScaleAspectFit

        // MARK: - Load state
        var sourceControlIndex: UInt = 1
        var typeControlIndex: UInt = 1
        var isEditableControlIndex: UInt = 0
        if let selectedIndexesDictionary = NSUserDefaults.load(key: "selected settings") as? [String: UInt] {
            print(selectedIndexesDictionary)
            sourceControlIndex = selectedIndexesDictionary["sourceControl"] ?? 1
            typeControlIndex = selectedIndexesDictionary["typeControl"] ?? 1
            isEditableControlIndex = selectedIndexesDictionary["isEditableControl"] ?? 0
        }

        sourceControl = BetterSegmentedControl(frame: CGRectZero, titles: ["Library", "Camera", "Moments"], index: sourceControlIndex, backgroundColor: UIColor.brownColor(), titleColor: UIColor.blackColor(), indicatorViewBackgroundColor: UIColor.redColor(), selectedTitleColor: UIColor.whiteColor())
        betterSegmentedControl_source_PlaceHolder.addSubview(sourceControl)
        sourceControl.stretchToSuperViewEdges()

        typeControl = BetterSegmentedControl(frame: CGRectZero, titles: [MediaType.Videos.rawValue, MediaType.Both.rawValue, MediaType.Photos.rawValue], index: typeControlIndex, backgroundColor: UIColor.yellowColor(), titleColor: UIColor.blackColor(), indicatorViewBackgroundColor: UIColor.greenColor().colorWithAlphaComponent(0.5), selectedTitleColor: UIColor.blueColor())
        betterSegmentedControl_type_PlaceHolder.addSubview(typeControl)
        typeControl.stretchToSuperViewEdges()

        isEditableControl = BetterSegmentedControl(frame: CGRectZero, titles: ["editable","not editable"], index: isEditableControlIndex, backgroundColor: UIColor.brownColor(), titleColor: UIColor.grayColor(), indicatorViewBackgroundColor: UIColor.greenColor().colorWithAlphaComponent(0.5), selectedTitleColor: UIColor.greenColor())
        isEditableControl.layer.cornerRadius = 5
        betterSegmentedControl_isEditable_PlaceHolder.addSubview(isEditableControl)
        isEditableControl.stretchToSuperViewEdges()

        betterSegmentedControl_source_PlaceHolder.backgroundColor  = UIColor.clearColor()
        betterSegmentedControl_type_PlaceHolder.backgroundColor  = UIColor.clearColor()
        betterSegmentedControl_isEditable_PlaceHolder.backgroundColor  = UIColor.clearColor()

        sourceControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), forControlEvents: .ValueChanged)
        typeControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), forControlEvents: .ValueChanged)
        isEditableControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), forControlEvents: .ValueChanged)
        
        self.setupCamera()
        cameraLensPreviewButton.onClick { (tapGestureRecognizer) in
            self.takeSnapshot()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cameBackFromBackground(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)

        // MARK: - Core Motion
        if manager.gyroAvailable {
            manager.gyroUpdateInterval = 0.5
            manager.startGyroUpdatesToQueue(NSOperationQueue.mainQueue()) { [weak self] (gyroData, error) in
                guard let gyroData = gyroData else { return }

                self?.gyroDataLabel.text = "\(gyroData)"
            }
        }

        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { [weak self] (deviceMotion, error) in
                guard let strongSelf = self, deviceMotion = deviceMotion else { return }

                let rotation = atan2(deviceMotion.gravity.x, deviceMotion.gravity.y) - M_PI
                strongSelf.pickedImageButton.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
            }
        }

        if pickedImageButton.imageView?.image == nil, let savedImage = DataManager.loadImage(fromFile: "tempSavedImage") {
            pickedImageButton.setImage(savedImage, forState: .Normal)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        manager.stopGyroUpdates()
        manager.stopDeviceMotionUpdates()
        NSNotificationCenter.defaultCenter().removeObserver(self)

        // MARK: - Save state
        let selectedIndexesDictionary = ["isEditableControl":isEditableControl.index,"sourceControl":sourceControl.index,"typeControl":typeControl.index]
        NSUserDefaults.save(value: selectedIndexesDictionary, forKey: "selected settings").synchronize()
    }

    func segmentedControlValueChanged(sender: BetterSegmentedControl) {
        // Just for fun:
        📘("Selected: \(sender.titles[Int(sender.index)])")
    }

    @IBAction func pickedImageButtonPressed(sender: UIButton) {
        if let image = sender.imageView?.image {
            PerrFuncs.shareImage(image, completionClosure: { (activityType, isCompleted, returnedItems, activityError) in
                📘("\(isCompleted ? "shared" : "canceled") via \(activityType)")
            })
        }
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cameraLensPreviewButtonPressed(sender: AnyObject) {
        takeSnapshot()
    }

    @IBAction func cameraButtonPressed(sender: AnyObject) {
        guard let selectedMediaType = MediaType(rawValue: typeControl.titles[Int(typeControl.index)]),
            let selectedSourceType = UIImagePickerControllerSourceType(rawValue: Int(sourceControl.index)) where UIImagePickerController.isSourceTypeAvailable(selectedSourceType) else { 📘("😱 Selected input types aren't available"); return }

        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSourceType
        
        switch selectedMediaType {
        case .Photos:
            imagePickerController.mediaTypes = [kUTTypeImage as String]
        case .Videos:
            imagePickerController.mediaTypes = [kUTTypeMovie as String]
        case .Both:
            fallthrough
        default:
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        }

        imagePickerController.allowsEditing = self.isEditable

        presentViewController(imagePickerController, animated: true, completion: nil)
    }

    func cameBackFromBackground(notification: NSNotification) {
        self.takeSnapshot()
    }

    func takeSnapshot() {
        if let capturedImage = cameraLensImage {
            self.cameraLensPreviewButton.setImage(capturedImage, forState: .Normal)
            UIImageWriteToSavedPhotosAlbum(capturedImage,
                                           nil,//id completionTarget
                nil,//SEL completionSelector
                nil)//void *contextInfo
        } else {
//            self.previewLayer
        }
    }

    func setupCamera() {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            if device.position == .Front {
                self.device = device as? AVCaptureDevice
            }
        }
        do {
            let input = try AVCaptureDeviceInput(device: self.device)
            
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            
            let cameraQueue = dispatch_queue_create("cameraQueue", nil)
            output.setSampleBufferDelegate(self, queue: cameraQueue)
            
            let key = kCVPixelBufferPixelFormatTypeKey as String
            let value = Int(kCVPixelFormatType_32BGRA)
            let videoSettings = [key:value]
            output.videoSettings = videoSettings

            captureSession = AVCaptureSession()
            previewLayer = AVCaptureVideoPreviewLayer()
            if let captureSession = captureSession, previewLayer = previewLayer {
                captureSession.addInput(input)
                captureSession.addOutput(output)
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto

                previewLayer.session = captureSession
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                // CHECK FOR YOUR APP
                previewLayer.frame = CGRectMake(0.0, 0.0, cameraLensPreviewButton.frame.size.width, cameraLensPreviewButton.frame.size.height)
                // CHECK FOR YOUR APP
                
                cameraLensPreviewButton.layer.insertSublayer(previewLayer, atIndex:0)   // Comment-out to hide preview layer
                
                captureSession.startRunning()
            }
        } catch {
            📘("Error: Failed to setup camera")
        }
    }
    
    // MARK:- AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        CVPixelBufferLockBaseAddress(imageBuffer,0)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)// as? UInt8  else { return }
        // size_t:
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)

        if let newImage = CGBitmapContextCreateImage(newContext) {
            
            //        CGContextRelease(newContext)
            //        CGColorSpaceRelease(colorSpace)
            
            var imageOrientation = UIImageOrientation.DownMirrored
            switch UIDevice.currentDevice().orientation {
            case .Portrait:
                imageOrientation = .LeftMirrored
            case .PortraitUpsideDown:
                imageOrientation = .RightMirrored
            case .LandscapeLeft:
                imageOrientation = .DownMirrored
            case .LandscapeRight:
                imageOrientation = .UpMirrored
            default:
                break
            }
            
            self.cameraLensImage = UIImage(CGImage: newImage, scale:1.0, orientation:imageOrientation)
            
            // No need to release on Swift
            //        CGImageRelease(newImage)
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        📘("picked image, location on disk: \(info[UIImagePickerControllerReferenceURL])")
        
        if let pickedMediaType = info[UIImagePickerControllerMediaType] {
            ToastMessage.show(messageText: "Picked a \(pickedMediaType)")
        }
        
        if let image = info[isEditable ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImageButton.setImage(image, forState: .Normal)
            DataManager.saveImage(image, toFile: "tempSavedImage")
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // Prevent interruptions with core motion exercise
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}