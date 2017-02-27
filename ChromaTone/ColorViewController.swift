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
    @IBOutlet weak var colorPickerImageView : ColorPickerImageView!
//    @IBOutlet weak var playToggleButton : UIButton!
    @IBOutlet weak var plot : AKRollingOutputPlot!
    
    @IBOutlet weak var toolbar : UIToolbar!
    @IBOutlet weak var albumButton : UIBarButtonItem!
    @IBOutlet weak var pickerButton : UIBarButtonItem!
    @IBOutlet weak var cameraButton : UIBarButtonItem!
    
    @IBOutlet weak var playButton : UIButton!
    
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

    let attributes = [NSFontAttributeName : UIFont.fontAwesome(ofSize: 25)] as [String : Any]
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumButton.setTitleTextAttributes(attributes, for: .normal)
        albumButton.title = String.fontAwesomeIcon(name: .photo)
        
        pickerButton.setTitleTextAttributes(attributes, for: .normal)
        pickerButton.title = String.fontAwesomeIcon(name: .dotCircleO)
        
//        cameraButton.setTitleTextAttributes(attributes, for: .normal)
//        cameraButton.title = " "
        cameraButton.isEnabled = false
        
        playButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 50)
        playButton.setTitle(String.fontAwesomeIcon(name: .playCircleO), for: .normal)
        
        self.tabBarController?.tabBar.items?[1].image = UIImage.fontAwesomeIcon(name: .camera, textColor: UIColor.blue, size: CGSize(width: 30, height: 30))
        self.tabBarController?.tabBar.items?[2].image = UIImage.fontAwesomeIcon(name: .cog, textColor: UIColor.blue, size: CGSize(width: 30, height: 30))
        
        // blurView : background 색이 너무 강렬하다.. blur 추가!
        let blur = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blur)
        // 가로일때 대비
        blurView.frame = CGRect(x: 0, y: self.colorPickerImageView.frame.minY,
                                width: self.view.frame.width, height: self.view.frame.height)
        self.view.insertSubview(blurView, at: 0)
        
        
        // Image / ImageView 초기화
        colorPickerImageView.isUserInteractionEnabled = true
        colorPickerImageView.isMultipleTouchEnabled = true
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        
        pickerSoundOn()
    }
    
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        for sublayer in self.colorPickerImageView.layer.sublayers ?? [] {
            sublayer.removeFromSuperlayer()
        }
        self.scanBarIsMoving = false
        prepareReceivingSingleColor()
        prepareReceivingScanColor()
        imagePlayer?.pickedSingleColor = self.receivedSingleColorByImagePlyer
        imagePlayer?.pickedScanColor = self.receivedScanColorByImagePlyer
        
        if let view = self.view.subviews.first as? UIVisualEffectView {
            view.frame = CGRect(x: 0, y: self.colorPickerImageView.frame.minY,
                   width: self.view.frame.width, height: self.view.frame.height)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.imagePlayer = prepareImagePlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.imagePlayer?.stop()
    }
    
    @IBAction func albumButtonPressed(_ sender: UIBarButtonItem){
        
        imagePlayer?.stop()
        
        // default image
        self.image = UIImage(named: "demo_colorful_city")
        colorPickerImageView.mode = .getColorByPixel

        let imagePickerController = UIImagePickerController()

        imagePickerController.delegate = self
        imagePickerController.sourceType = .savedPhotosAlbum
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickerButtonPressed(_ sender: UIBarButtonItem){
        
        imagePlayer?.stop()
        
        self.image = UIImage(named: Constants.colorPickerImage)
        self.colorPickerImageView.mode = .makeHSBColor
        
    }
    @IBAction func playButtonPressed(_ sender: UIButton){
        
        guard let player = self.imagePlayer else {
            print("ImagePlayer 없음")
            return
        }

        switch player.status {
        case .playing:
            player.pause()
            playButton.setTitle(String.fontAwesomeIcon(name: .playCircleO), for: .normal)
            pickerSoundOn()

            self.scanBarIsMoving = false
            self.colorPickerImageView.layer.sublayers?[0].removeAllAnimations()

        case .pause:
            player.resume()
            playButton.setTitle(String.fontAwesomeIcon(name: .pauseCircleO), for: .normal)
            pickerSoundOff()

        case .stop :
            player.play()
            playButton.setTitle(String.fontAwesomeIcon(name: .pauseCircleO), for: .normal)
            pickerSoundOff()
        }
    }
    
    @IBAction func stopButtonPressed(_ sender : UIBarButtonItem) {
        imagePlayer?.stop()
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


