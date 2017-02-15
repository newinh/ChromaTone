//
//  CameraViewController.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 14..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreImage

class CameraViewController : UIViewController {
    
    var ddd :( ( UIImage) -> Void )?
    
    @IBOutlet weak var colorPreview: UIView!
    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    private var setupResult: SessionSetupResult = .success
    
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoDataOutput: AVCaptureVideoDataOutput!
    
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil) // Communicate with the session and other session objects on this queue.
    private let videoDataOutputQueue = DispatchQueue(label: "video data ouput queue")
    
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var sampleTimeing = CMSampleTimingInfo.init()
        sampleTimeing.duration = CMTime(seconds: 1, preferredTimescale: 10)
        
        // Set up the video preview view.
        cameraPreviewView.session = session
        
        // 화면 꽉차게!
        cameraPreviewView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {

            switch self.setupResult {
            case .success:
                
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async { [unowned self] in
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if let videoPreviewLayerConnection = cameraPreviewView.videoPreviewLayer.connection,
            let connection = videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
        {
            let deviceOrientation = UIDevice.current.orientation
            
            guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                return
            }
            
            connection.videoOrientation = newVideoOrientation
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    
    // Call this on the session queue.
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        // Quaility
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDualCamera, mediaType: AVMediaTypeVideo, position: .back) {
                defaultVideoDevice = dualCameraDevice
            }
            else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
                // If the back dual camera is not available, default to the back wide angle camera.
                defaultVideoDevice = backCameraDevice
            }
            else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
                // In some cases where users break their phones, the back wide angle camera is not available. In this case, we should default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                
                DispatchQueue.main.async {
                    /*
                     Why are we dispatching this to the main queue?
                     Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
                     can only be manipulated on the main thread.
                     Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    
                    if let videoOrientation = statusBarOrientation.videoOrientation , statusBarOrientation != .unknown {
                        initialVideoOrientation = videoOrientation
                    }
                    
                    self.cameraPreviewView.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation
                    
                }
            }
            else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        }
        catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add video output.
        let videoDataOutput = AVCaptureVideoDataOutput()
        
        if self.session.canAddOutput(videoDataOutput){
            
            self.session.beginConfiguration()
            self.session.addOutput(videoDataOutput)
            
            self.videoDataOutput = videoDataOutput
            self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)

            // kCVPixelFormatType_32BGRA is available...
            self.videoDataOutput.videoSettings[String(kCVPixelBufferPixelFormatTypeKey)] = Int(kCVPixelFormatType_32BGRA)
            
            // 메모리는 더 쓰지만 값을 안정시킨다.
            self.videoDataOutput.alwaysDiscardsLateVideoFrames = false
            
            // orient 설정
            let statusBarOrientation = UIApplication.shared.statusBarOrientation
            var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
            if let videoOrientation = statusBarOrientation.videoOrientation , statusBarOrientation != .unknown {
                initialVideoOrientation = videoOrientation
            }
            if let connection = self.videoDataOutput.connection(withMediaType: AVMediaTypeVideo) {
                connection.videoOrientation = initialVideoOrientation
            }
            
            self.session.commitConfiguration()
            
        }else {
            print("Could not add video device output to the session")
            self.setupResult = .configurationFailed
            self.session.commitConfiguration()
            return
        }
        
        self.session.commitConfiguration()
    }
    
    @IBAction func canceld(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var playButton: UIButton!
    var isPlaying : Bool = false
    @IBAction func togglePlayButton(_ sender: UIButton) {
        
        if isPlaying {
            self.isPlaying = false
            playButton.setBackgroundImage(UIImage(named: Constants.playIcon), for: UIControlState.normal)
        }else {
            self.isPlaying = true
            playButton.setBackgroundImage(UIImage(named: Constants.pauseIcon), for: UIControlState.normal)
        }
    }
    
}


extension CameraViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!) else {
            print("주소 로딩 실패")
            return
        }

         // Get the number of bytes per row for the pixel buffer
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        
        
        // Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)

        
        // Center point 로 offset 설정
        let offset = bytesPerRow * ( height / 2 ) + ( width / 2 ) * 4
        
        // 왜 bgr 순서인가 인가?  Answer: videoDataOutput을 BGRA 로 세팅했다..
        let b = CGFloat ( baseAddress.load(fromByteOffset: offset, as: UInt8.self) ) / 255
        let g = CGFloat ( baseAddress.load(fromByteOffset: offset + 1, as: UInt8.self) ) / 255
        let r = CGFloat ( baseAddress.load(fromByteOffset: offset + 2, as: UInt8.self) ) / 255
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1)
        
        
        /* make Image
        
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue).union(CGBitmapInfo.byteOrder32Little)

        // Create a bitmap graphics context with the sample buffer data
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {

            print("context error!!!")
            return
        }

        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context.makeImage()

        
        
        // 디버그용
        // Create an image object from the Quartz image
        let image = UIImage(cgImage: quartzImage!)
 
        */
        // UnLock the base address of the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        DispatchQueue.main.async {
            self.colorPreview.backgroundColor = color
        }
    }
}


extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return nil
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}
