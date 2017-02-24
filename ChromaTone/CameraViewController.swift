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
import AudioKit

class CameraViewController : UIViewController {
    
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
    
    
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil) // session 관련 작업
    private let videoDataOutputQueue = DispatchQueue(label: "video data ouput queue") // capure frame 관련 작업
    
    @IBOutlet weak var plot : UIView!
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        
        /// TODO : add plot
//        self.plot.addSubview(AKRollingOutputPlot(frame: self.plot.bounds))
        
        // Set up the video preview view.
        cameraPreviewView.session = session
        
        // 화면 꽉차게!
        cameraPreviewView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        // Camera 설정 권한에 대한 대응
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            break
            
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                if !granted { // 허가되지 않았을 때
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // denied
            setupResult = .notAuthorized
            self.dismiss(animated: true, completion: nil)
        }
        
        // session 작업은 따로
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ToneController.sharedInstance().aChromaOff = true
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.barStyle = .black
        
        print(self.setupResult)
        // Session Setup 결과에 대한 대응
        sessionQueue.async {

            switch self.setupResult {
            case .success:
                
                self.session.startRunning()
                
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("카메라에 접근할수 업습니다. 설정 > ChromaTone 에서 카메라를 승인해주세요.", comment: "카메가 접근 권한을 얻지 못했을 때")
                    let alertController = UIAlertController(title: "ChromaTone", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: {action in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "go Settings"), style: .`default`, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("카메라 기능을 사용할 수 없습니다.", comment: "카메라 설정 실패...")
                    let alertController = UIAlertController(title: "ChromaTone", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //plot clear
//        self.plot.subviews.first!.removeFromSuperview()
        
        self.tabBarController?.tabBar.barStyle = .default
        
        ToneController.sharedInstance().aChromaOff = true
        
        sessionQueue.async { [unowned self] in
            if self.setupResult == .success {
                self.session.stopRunning()
            }
        }
        
        if isPlaying {
            self.isPlaying = false
            self.videoDataOutputQueue.async {
                print("CameraView Tone Stop in videoDataOutputQueue")
                ToneController.sharedInstance().stop()
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
    
    // sessionQueue
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        // Quaility
        session.sessionPreset = AVCaptureSessionPresetPhoto

        // Session에 input 과 ouput 추가
        // Add video input.
        do {
            guard let defaultVideoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
                
                print(" No Video Device ")
                self.setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                

                // cameraPreviewView Orinet 체크
                DispatchQueue.main.async {
                    let deviceOrientation = UIDevice.current.orientation
                    guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                        return
                    }
                    self.cameraPreviewView.videoPreviewLayer.connection.videoOrientation = newVideoOrientation
                    
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
            let deviceOrientation = UIDevice.current.orientation
            var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
            if let videoOrientation = deviceOrientation.videoOrientation {
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
    
    var isPlaying : Bool = false {
        didSet{
            if oldValue {
                self.playButton.setBackgroundImage(UIImage(named: Constants.playIcon), for: UIControlState.normal)
            }else {
                playButton.setBackgroundImage(UIImage(named: Constants.pauseIcon), for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func togglePlayButton(_ sender: UIButton) {
        
        if isPlaying {
            self.isPlaying = false
            self.videoDataOutputQueue.async {
                ToneController.sharedInstance().stop()
            }
            
        }else {
            self.isPlaying = true
            
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
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        // 얻은 색으로 할 일들 : 미리보기, 톤 재생
        DispatchQueue.main.async {
            
            if self.isPlaying {
                ToneController.sharedInstance().playMelody(color: color, volume: 100)
            }
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
