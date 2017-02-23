//
//  ViewController.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 7..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit
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
    var receivedSingleColorByImagePlyer : ( (UIColor, _ x : Int?, _ y : Int? )  -> Void )?
    var receivedScanColorByImagePlyer : ( (UIColor, _ x : Int, _ y : Int ,_ option: ImagePlayer.Option, _ count : Int)  -> Void )?
    
    var scanBarIsMoving : Bool = false
    
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
        colorPickerImageView.isMultipleTouchEnabled = true
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        
        
        // ImagePlayer 초기화
        self.imagePlayer = prepareImagePlayer()
        
        pickerSoundOn()
        
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        prepareReceivingSingleColor()
        prepareReceivingScanColor()
        imagePlayer?.pickedSingleColor = self.receivedSingleColorByImagePlyer
        imagePlayer?.pickedScanColor = self.receivedScanColorByImagePlyer
        
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
            
            self.scanBarIsMoving = false
            self.colorPickerImageView.layer.sublayers?[0].removeAllAnimations()
            
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


