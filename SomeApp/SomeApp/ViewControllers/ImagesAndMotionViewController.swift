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

    var cameraPreivew: CameraPreivew?
    lazy var imagePickerController = UIImagePickerController()
    lazy var manager = CMMotionManager()
    
    @IBOutlet weak var cameraPreviewContainer: UIView!
    @IBOutlet weak var gyroDataLabel: UILabel!
    @IBOutlet weak var pickedImageButton: UIButton!
    // A replacement for UISegmentedControl, more info at: https://littlebitesofcocoa.com/226-bettersegmentedcontrol
    @IBOutlet weak var sourceControl: BetterSegmentedControl!
    @IBOutlet weak var typeControl: BetterSegmentedControl!
    @IBOutlet weak var isEditableControl: BetterSegmentedControl!

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

        // Initialize picker image view
        pickedImageButton.layer.cornerRadius = 3
        pickedImageButton.layer.borderColor = UIColor.black.withAlphaComponent(0.7).cgColor
        pickedImageButton.layer.borderWidth = 1
        // More info about 'contentMode' at: http://stackoverflow.com/questions/4895272/difference-between-uiviewcontentmodescaleaspectfit-and-uiviewcontentmodescaletof
        pickedImageButton.imageView?.contentMode = .scaleAspectFit

        // MARK: - Load state
        var sourceControlIndex: Int = 1
        var typeControlIndex: Int = 1
        var isEditableControlIndex: Int = 0
        if let selectedIndexesDictionary: [String: Int] = UserDefaults.load(key: "selected settings") {
            📘(selectedIndexesDictionary)
            sourceControlIndex = selectedIndexesDictionary["sourceControl"] ?? 1
            typeControlIndex = selectedIndexesDictionary["typeControl"] ?? 1
            isEditableControlIndex = selectedIndexesDictionary["isEditableControl"] ?? 0
        }

        sourceControl.segments = [LabelSegment(text: "Library", normalTextColor: UIColor.black, selectedTextColor: UIColor.white),
        LabelSegment(text: "Camera", normalTextColor: UIColor.black, selectedTextColor: UIColor.white),
        LabelSegment(text: "Moments", normalTextColor: UIColor.black, selectedTextColor: UIColor.white)]
        sourceControl.setIndex(sourceControlIndex)
        sourceControl.backgroundColor = UIColor.brown
        
        sourceControl.indicatorViewBackgroundColor = UIColor.red

        typeControl.segments = [LabelSegment(text: MediaType.Videos.rawValue, normalTextColor: UIColor.black, selectedTextColor: UIColor.blue),
        LabelSegment(text: MediaType.Both.rawValue, normalTextColor: UIColor.black, selectedTextColor: UIColor.blue),
        LabelSegment(text: MediaType.Photos.rawValue, normalTextColor: UIColor.black, selectedTextColor: UIColor.blue)] //[, MediaType.Both.rawValue, ]
        typeControl.setIndex(typeControlIndex)
        typeControl.backgroundColor = UIColor.yellow
        typeControl.indicatorViewBackgroundColor = UIColor.green.withAlphaComponent(0.5)

        isEditableControl.segments = [LabelSegment(text: "editable", normalTextColor: UIColor.gray, selectedTextColor: UIColor.green),
        LabelSegment(text: "non editable", normalTextColor: UIColor.gray, selectedTextColor: UIColor.green)]
        typeControl.setIndex(typeControlIndex)
        typeControl.backgroundColor = UIColor.yellow
        typeControl.indicatorViewBackgroundColor = UIColor.green.withAlphaComponent(0.5)

        isEditableControl.setIndex(isEditableControlIndex)
        isEditableControl.backgroundColor = UIColor.brown
        isEditableControl.indicatorViewBackgroundColor = UIColor.green.withAlphaComponent(0.5)
        isEditableControl.layer.cornerRadius = 5

        sourceControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        typeControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        isEditableControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        let preivew: CameraPreivew = CameraPreivew(frame: view.frame)
        cameraPreviewContainer.addSubview(preivew)
        cameraPreviewContainer.makeRoundedCorners()
        preivew.stretchToSuperViewEdges()
        //preivew.dropShadow()
        cameraPreivew = preivew
        cameraPreivew?.onClick({ [weak self] _ in
            guard let capturedImage = self?.cameraPreivew?.takeSnapshot() else { return }
            capturedImage.present()
            if #available(iOS 11.0, *) {
                PerrFuncs.readText(fromImage: capturedImage, block: { (text) in
                    📘(text)
                })
            }
        })

        cameraPreivew?.onLongPress({ [weak self] recognizer in
            guard recognizer.state == .began else { return }
            self?.cameraPreivew?.stop()
            self?.cameraPreivew?.addBlurEffect(blurEffectStyle: UIBlurEffectStyle.light)
            PerrFuncs.runBlockAfterDelay(afterDelay: 0.2, block: {
                self?.cameraPreivew?.animateFlip(duration: 0.5) { _ in
                    let otherPosition: AVCaptureDevice.Position = self?.cameraPreivew?.device?.position == .front ? .back : .front
                    self?.cameraPreivew?.setupCamera(cameraPosition: otherPosition)
                    self?.cameraPreivew?.removeAllBlurEffects()
                    self?.cameraPreivew?.start()
                }
            })
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        cameraPreivew?.setupCamera()
        PerrFuncs.runOnBackground(block: {
            self.cameraPreivew?.start()
        })

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

        cameraPreivew?.stop()
        manager.stopGyroUpdates()
        manager.stopDeviceMotionUpdates()
        NotificationCenter.default.removeObserver(self)

        // MARK: - Save state
        let selectedIndexesDictionary = ["isEditableControl":isEditableControl.index,"sourceControl":sourceControl.index,"typeControl":typeControl.index]
        UserDefaults.save(value: selectedIndexesDictionary as AnyObject, forKey: "selected settings").synchronize()
    }

    @objc func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        let selectedTitle = (typeControl.segments[typeControl.index] as? LabelSegment)?.text ?? "😯"
        // Just for fun:
        📘("Selected: \(selectedTitle)")
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

    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        guard let selectedMediaType = MediaType(rawValue: (typeControl.segments[typeControl.index] as! LabelSegment).text.or("none")),
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

        // Check permission using:
        // import Photos => PHPhotoLibrary.authorizationStatus() == .authorized
        present(imagePickerController, animated: true, completion: nil)
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

class CameraPreivew: UIView, AVCaptureVideoDataOutputSampleBufferDelegate, UIDocumentInteractionControllerDelegate {
    var cameraLensPreview: UIImageView?
    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraLensImage: UIImage?
    
    override init(frame: CGRect) {
        guard frame != CGRect.zero else { fatalError("The initial frame cannot be zero!"); }
        // Initialize snapshot image view
        cameraLensPreview = UIImageView(frame: frame)
        cameraLensPreview?.contentMode = .scaleAspectFill
        
        super.init(frame: frame)
        
        addSubview(cameraLensPreview!)
        cameraLensPreview?.stretchToSuperViewEdges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func start() {
        if let captureSession = captureSession, !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stop() {
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    func takeSnapshot() -> UIImage? {
        guard !PerrFuncs.isRunningOnSimulator() else { return nil }
        //previewLayer.image
        if let capturedImage = cameraLensImage {
            return capturedImage.fixedOrientation()
        }

        if #available(iOS 10.0, *) {
            return asImage()
        } else {
            // Fallback on earlier versions
        }

        return nil
    }
    
    func mockCamera() {
        let mockView = UIView(frame: self.frame)
        mockView.backgroundColor = .red
        addSubview(mockView)
        mockView.addVerticalGradientBackgroundLayer(topColor: UIColor.blue, bottomColor: UIColor.yellow)
        mockView.stretchToSuperViewEdges()
    }

    func cleanup() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()

        captureSession = nil
        previewLayer = nil
    }

    func setupCamera(cameraPosition: AVCaptureDevice.Position = .back) {
        guard !PerrFuncs.isRunningOnSimulator() else { mockCamera(); return }
        
        let devicevideoCameras = AVCaptureDevice.devices(for: AVMediaType.video)
        self.device = devicevideoCameras.filter( { $0.position == cameraPosition } ).first
        guard let device = device else { mockCamera(); return }

        cleanup()

        do {
            let input = try AVCaptureDeviceInput(device: device)
            
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
                previewLayer.frame = CGRect(x: 0.0, y: 0.0, width: cameraLensPreview!.frame.size.width, height: cameraLensPreview!.frame.size.height)
                // CHECK FOR YOUR APP
                
                cameraLensPreview?.layer.insertSublayer(previewLayer, at:0)   // Comment-out to hide preview layer
            }
        } catch let error {
            📘("Error: Failed to setup camera: \(error)")
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            guard let image = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
            cameraLensImage = image
            return
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        
        if let newImage = newContext?.makeImage() {
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
        }

        CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0));
    }
    
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }

        guard let cgImage = context.makeImage() else {
            return nil
        }

        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        cameraLensImage = image
    }
}
