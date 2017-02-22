//
//  ViewController.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 7..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class ColorViewController: UIViewController {
    
    
    // MARK: IBOuelt
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var modeChanger : UISegmentedControl!
    @IBOutlet weak var colorPickerImageView : ColorPickerImageView!
    @IBOutlet weak var playToggleButton : UIButton!
    
    @IBOutlet weak var plot : UIView!
    
    var imagePlayer: ImagePlayer?
    
    var imagePlayerCompleted : ( (Void) -> Void  )?
    var receivedColorByImagePlyer : ( (UIColor, _ x : Int?, _ y : Int? )  -> Void )?
    
    var image : UIImage?{
        get {
            return self.colorPickerImageView.image
        }
        set {
            
            guard let newImage = newValue else {
                print("Image loading failed!")
                self.colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
                return
            }
            
            self.colorPickerImageView.image = newImage
            
            self.imagePlayer = prepareImagePlayer()
            
        }
    }

    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add plot
//        self.plot.addSubview(AKRollingOutputPlot(frame: self.plot.bounds))
        
        // blurView : background 색이 너무 강렬하다.. blur 추가!
        let blur = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blur)
        // 가로일때 대비
        blurView.frame = CGRect(x: 0, y: self.modeChanger.frame.maxY,
                                width: self.view.frame.width, height: self.view.frame.height)
//        blurView.frame = self.colorPickerImageView.frame
        self.view.insertSubview(blurView, at: 0)
        
        super.viewDidLayoutSubviews()
        
        // Image / ImageView 초기화
        colorPickerImageView.isUserInteractionEnabled = true
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        
        
        // ImagePlayer 초기화
        self.imagePlayer = prepareImagePlayer()
        
        pickerSoundOn()
        
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        prepareRecevingColor()
        imagePlayer?.pickedSingleColor = self.receivedColorByImagePlyer
        
        if let view = self.view.subviews.first as? UIVisualEffectView {
            view.frame = CGRect(x: 0, y: self.modeChanger.frame.maxY,
                   width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    // MARK: IBAction
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        imagePlayer?.stop()
        
        switch sender.selectedSegmentIndex {
            
        case 0: // Picture
            // default image
            self.image = UIImage(named: "demo_colorful_city")
            colorPickerImageView.mode = .getColorByPixel
            
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.delegate = self
            imagePickerController.sourceType = .savedPhotosAlbum
            self.present(imagePickerController, animated: true, completion: nil)
            
        case 1:
            self.image = UIImage(named: Constants.colorPickerImage)
            self.colorPickerImageView.mode = .makeHSBColor
        default :
            
            self.performSegue(withIdentifier: "CameraView", sender: nil)

            // 카메라뷰 열고 ColorView는 Picker모드로
            modeChanger.selectedSegmentIndex = 1
            self.image = UIImage(named: Constants.colorPickerImage)
            self.colorPickerImageView.mode = .makeHSBColor
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        
        guard let player = self.imagePlayer else {
            print("ImagePlayer 없음")
            return
        }
        
        switch player.status {
        case .playing:
            player.pause()
            playToggleButton.setImage(UIImage(named: Constants.playIcon), for: .normal)
            pickerSoundOn()
            
        case .pause:
            player.resume()
            playToggleButton.setImage(UIImage(named: Constants.pauseIcon), for: .normal)
            pickerSoundOff()
            
        case .stop :
            player.play()
            playToggleButton.setImage(UIImage(named: Constants.pauseIcon), for: .normal)
            pickerSoundOff()
        }
    }
    
    func pickerSoundOn() {
        // Color Picked Completion Handler
        self.colorPickerImageView.pickedColor = { [unowned self] (newColor) in
            // 색 미리보기
            self.preview.backgroundColor = newColor
            ToneController.sharedInstance().playMelody(color: newColor)
        }
        self.colorPickerImageView.endedTouch = {
            ToneController.sharedInstance().stop()
        }
    }
    
    func pickerSoundOff() {
        // Color Picked Completion Handler
        self.colorPickerImageView.pickedColor = { [unowned self] (newColor) in
            // 색 미리보기
            self.preview.backgroundColor = newColor
        }
        self.colorPickerImageView.endedTouch = {
        }
    }
}

extension ColorViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ColorViewController {
    
    func prepareImagePlayer() -> ImagePlayer{
        
        // ImagePlyer 종료시 동작
        self.imagePlayerCompleted = {
            for sublayer in self.colorPickerImageView.layer.sublayers ?? [] {
                sublayer.removeFromSuperlayer()
            }
            self.playToggleButton.setImage(UIImage(named: Constants.playIcon), for: .normal)
            self.pickerSoundOn()
            self.view.backgroundColor = UIColor.white
        }
        
        prepareRecevingColor()
        
        // image 바꾸면 imagePlayer 생성
        // 1beat 에 4 노트
        let option = ImagePlayer.Option(bpm: 60, timePerBeat: 4, noteCount: 40, playMode: .verticalScanBar, scanSampleNumber: 11)
        let imagePlayer = ImagePlayer(source: self.image!, option: option)
        imagePlayer.completionHandler = self.imagePlayerCompleted
        imagePlayer.pickedSingleColor = self.receivedColorByImagePlyer
        
        return imagePlayer
    }
    
    func prepareRecevingColor() {
        // ImagePlayer가 `색`을 만들었을 때 동작
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 1
        animation.repeatCount = 1
        
        let imageFrame = self.colorPickerImageView.imageFrame()
        let makerSize: CGFloat = 40
        
        
        self.receivedColorByImagePlyer = {
            (color, x, y ) in
            
            
            /// TODO!!! 스캔바 이동하게 해보장
            if let x = x, let y = y {   /// x , y 모두 지정 되었을 경우
                self.view.backgroundColor = color
                
                // animation
                let scale =  imageFrame.size.width / self.colorPickerImageView.intrinsicContentSize.width
                let revisedX = imageFrame.minX + CGFloat(x) * scale
                let revisedY = imageFrame.minY + CGFloat(y) * scale
                
                let layer = CALayer()
                layer.backgroundColor = color.cgColor
                layer.frame = CGRect(x: revisedX - makerSize/2, y: revisedY - makerSize/2, width: makerSize, height: makerSize)
                
                layer.cornerRadius = makerSize/2
                layer.borderWidth = 1
                layer.borderColor = UIColor.white.cgColor
                
                layer.opacity = 0
                layer.add(animation, forKey: "opacity")
                
                self.colorPickerImageView.layer.addSublayer(layer)
                
            }
        }
            
    }
}
