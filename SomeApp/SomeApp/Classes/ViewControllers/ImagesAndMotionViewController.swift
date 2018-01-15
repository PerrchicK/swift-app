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

class ImagesAndMotionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIDocumentInteractionControllerDelegate {

    let imagePickerController = UIImagePickerController()
    let manager = CMMotionManager()
    
    @IBOutlet weak var gyroDataLabel: UILabel!
    @IBOutlet weak var pickedImageButton: UIButton!
    // A replacement for UISegmentedControl, more info at: https://littlebitesofcocoa.com/226-bettersegmentedcontrol
    @IBOutlet weak var sourceControl: BetterSegmentedControl!
    @IBOutlet weak var typeControl: BetterSegmentedControl!
    @IBOutlet weak var isEditableControl: BetterSegmentedControl!

    @IBOutlet weak var cameraLensPreviewButton: UIButton!

    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraLensImage: UIImage?

    // Computed variable example
    var isEditableSelected: Bool {
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
        self.cameraLensPreviewButton.contentMode = .scaleAspectFill
        self.cameraLensPreviewButton.clipsToBounds = true
        self.cameraLensPreviewButton.layer.cornerRadius = 12

        // Initialize picker image view
        pickedImageButton.layer.cornerRadius = 3
        pickedImageButton.layer.borderColor = UIColor.black.withAlphaComponent(0.7).cgColor
        pickedImageButton.layer.borderWidth = 1
        // More info about 'contentMode' at: http://stackoverflow.com/questions/4895272/difference-between-uiviewcontentmodescaleaspectfit-and-uiviewcontentmodescaletof
        pickedImageButton.imageView?.contentMode = .scaleAspectFit

        // MARK: - Load state
        var sourceControlIndex: UInt = 1
        var typeControlIndex: UInt = 1
        var isEditableControlIndex: UInt = 0
        if let selectedIndexesDictionary: [String: UInt] = UserDefaults.load(key: "selected settings") {
            print(selectedIndexesDictionary)
            sourceControlIndex = selectedIndexesDictionary["sourceControl"] ?? 1
            typeControlIndex = selectedIndexesDictionary["typeControl"] ?? 1
            isEditableControlIndex = selectedIndexesDictionary["isEditableControl"] ?? 0
        }

        sourceControl.titles = ["Library", "Camera", "Moments"]
        try? sourceControl.setIndex(sourceControlIndex)
        sourceControl.backgroundColor = UIColor.brown
        sourceControl.titleColor = UIColor.black
        sourceControl.indicatorViewBackgroundColor = UIColor.red
        sourceControl.selectedTitleColor = UIColor.white

        typeControl.titles = [MediaType.Videos.rawValue, MediaType.Both.rawValue, MediaType.Photos.rawValue]
        try? typeControl.setIndex(typeControlIndex)
        typeControl.backgroundColor = UIColor.yellow
        typeControl.titleColor = UIColor.black
        typeControl.indicatorViewBackgroundColor = UIColor.green.withAlphaComponent(0.5)
        typeControl.selectedTitleColor = UIColor.blue

        isEditableControl.titles = ["editable","not editable"]
        try? isEditableControl.setIndex(isEditableControlIndex)
        isEditableControl.backgroundColor = UIColor.brown
        isEditableControl.titleColor = UIColor.gray
        isEditableControl.indicatorViewBackgroundColor = UIColor.green.withAlphaComponent(0.5)
        isEditableControl.selectedTitleColor = UIColor.green
        isEditableControl.layer.cornerRadius = 5

        sourceControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        typeControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        isEditableControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        self.setupCamera()
        cameraLensPreviewButton.onClick { [weak self] (tapGestureRecognizer) in
            self?.takeSnapshot()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(cameBackFromBackground(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        // MARK: - Core Motion
        if manager.isGyroAvailable {
            manager.gyroUpdateInterval = 0.5
            manager.startGyroUpdates(to: OperationQueue.main, withHandler: { [weak self] (gyroData, error) in
                guard let gyroData = gyroData else { return }
                
                self?.gyroDataLabel.text = "\(gyroData)"
            })
        }

        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (deviceMotion, error) in
                guard let strongSelf = self, let deviceMotion = deviceMotion else { return }

                let rotation = atan2(deviceMotion.gravity.x, deviceMotion.gravity.y) - Double.pi
                strongSelf.pickedImageButton.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            }
        }

        if pickedImageButton.imageView?.image == nil, let savedImage = DataManager.loadImage(fromFile: "tempSavedImage") {
            pickedImageButton.setImage(savedImage, for: .normal)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        manager.stopGyroUpdates()
        manager.stopDeviceMotionUpdates()
        NotificationCenter.default.removeObserver(self)

        // MARK: - Save state
        let selectedIndexesDictionary = ["isEditableControl":isEditableControl.index,"sourceControl":sourceControl.index,"typeControl":typeControl.index]
        UserDefaults.save(value: selectedIndexesDictionary as AnyObject, forKey: "selected settings").synchronize()
    }

    @objc func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        // Just for fun:
        📘("Selected: \(sender.titles[Int(sender.index)])")
    }

    @IBAction func pickedImageButtonPressed(_ sender: UIButton) {
        if let image = sender.imageView?.image {
            PerrFuncs.shareImage(image, completionClosure: { (activityType, isCompleted, returnedItems, activityError) in
                📘("\(isCompleted ? "shared" : "canceled") via \(activityType.debugDescription)")
            })
        }
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraLensPreviewButtonPressed(_ sender: AnyObject) {
        takeSnapshot()
    }

    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        guard let selectedMediaType = MediaType(rawValue: typeControl.titles[Int(typeControl.index)]),
            let selectedSourceType = UIImagePickerControllerSourceType(rawValue: Int(sourceControl.index)), UIImagePickerController.isSourceTypeAvailable(selectedSourceType) else {
                let errorString: String = "😱 Selected input types aren't available"
                ToastMessage.show(messageText: errorString)
                📘(errorString)
                return
        }

        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSourceType
        
        switch selectedMediaType {
        case .Photos:
            imagePickerController.mediaTypes = [kUTTypeImage.string]
        case .Videos:
            imagePickerController.mediaTypes = [String(kUTTypeMovie)]
        case .Both:
            fallthrough
        default:
            imagePickerController.mediaTypes = [kUTTypeImage.string, kUTTypeMovie as String]
        }
        
        imagePickerController.allowsEditing = self.isEditableSelected

        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func cameBackFromBackground(_ notification: Notification) {
        self.takeSnapshot()
    }

    func takeSnapshot() {
        if let capturedImage = cameraLensImage {
            self.cameraLensPreviewButton.setImage(capturedImage, for: .normal)
            UIImageWriteToSavedPhotosAlbum(capturedImage,
                                           nil,//id completionTarget
                nil,//SEL completionSelector
                nil)//void *contextInfo
        } else {
//            self.previewLayer
        }
    }

    func setupCamera() {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if (device as AnyObject).position == .front {
                self.device = device as? AVCaptureDevice
            }
        }
        do {
            let input = try AVCaptureDeviceInput(device: self.device!)
            
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            
            let cameraQueue = DispatchQueue(label: "cameraQueue", attributes: [])
            output.setSampleBufferDelegate(self, queue: cameraQueue)
            
            let key = kCVPixelBufferPixelFormatTypeKey as String
            let value = Int(kCVPixelFormatType_32BGRA)
            let videoSettings = [key:value]
            output.videoSettings = videoSettings

            captureSession = AVCaptureSession()
            previewLayer = AVCaptureVideoPreviewLayer()
            if let captureSession = captureSession, let previewLayer = previewLayer {
                captureSession.addInput(input)
                captureSession.addOutput(output)
                captureSession.sessionPreset = AVCaptureSession.Preset.photo

                previewLayer.session = captureSession
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                // CHECK FOR YOUR APP
                previewLayer.frame = CGRect(x: 0.0, y: 0.0, width: cameraLensPreviewButton.frame.size.width, height: cameraLensPreviewButton.frame.size.height)
                // CHECK FOR YOUR APP
                
                cameraLensPreviewButton.layer.insertSublayer(previewLayer, at:0)   // Comment-out to hide preview layer
                
                captureSession.startRunning()
            }
        } catch {
            📘("Error: Failed to setup camera")
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        CVPixelBufferLockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)// as? UInt8  else { return }
        // size_t:
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)

        if let newImage = newContext?.makeImage() {
            
            //        CGContextRelease(newContext)
            //        CGColorSpaceRelease(colorSpace)
            
            var imageOrientation = UIImageOrientation.downMirrored
            switch UIDevice.current.orientation {
            case .portrait:
                imageOrientation = .leftMirrored
            case .portraitUpsideDown:
                imageOrientation = .rightMirrored
            case .landscapeLeft:
                imageOrientation = .downMirrored
            case .landscapeRight:
                imageOrientation = .upMirrored
            default:
                break
            }
            
            self.cameraLensImage = UIImage(cgImage: newImage, scale:1.0, orientation:imageOrientation)
            
            // No need to release on Swift
            //        CGImageRelease(newImage)
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0));
    }

    // MARK: - UIDocumentInteractionControllerDelegate

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaUrl = info[UIImagePickerControllerReferenceURL].debugDescription
        📘("picked image, location on disk: \(mediaUrl)")
        
        if let pickedMediaType = info[UIImagePickerControllerMediaType] {
            ToastMessage.show(messageText: "Picked a \(pickedMediaType)")
        }

        let selectedImageKey = isEditableSelected ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[selectedImageKey] as? UIImage {
            pickedImageButton.setImage(image, for: .normal)
            DataManager.saveImage(image, toFile: "tempSavedImage")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    // Prevent interruptions with core motion exercise
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait        
    }

    deinit {
        📘("I'm dead 💀")
    }
}

extension CFString {
    var string: String {
        return String(self)
    }
}
