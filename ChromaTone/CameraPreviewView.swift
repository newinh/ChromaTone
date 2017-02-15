//
//  CameraPreviewView.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 14..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import AVFoundation
import UIKit

class CameraPreviewView: UIView {
    // MARK: UIView
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
}
