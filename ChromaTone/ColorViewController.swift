//
//  ViewController.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 7..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit
import AVFoundation

class ColorViewController: UIViewController {
    
    
    // MARK: IBOuelt
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var modeChanger : UISegmentedControl!
    @IBOutlet weak var colorPickerImageView : ColorPickerImageView!

    
    var engine: AVAudioEngine!
    var tonePlayer: AVTonePlayer!
    var tonePlayerAvailable: Bool = true
    var imagePickerDelegate : ImagePickerDelegate!
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Color Picker 이미지 선택
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        colorPickerImageView.isUserInteractionEnabled = true
        
        initAudio()
        imagePickerDelegate = ImagePickerDelegate()
        imagePickerDelegate.pickedImage = { [unowned self] (pickedImage) in
            self.colorPickerImageView.image = pickedImage
        }
        
        // Color Picked Completion Handler
        colorPickerImageView.pickedColor = { [unowned self] (makedColor) in
            
            // 색 미리보기
            self.preview.backgroundColor = makedColor
            // 음정 변환
            self.tonePlayer.frequency = Calculator.color2soundSimple(color: makedColor)
            
            if self.tonePlayerAvailable {
                
                do{
                    try self.engine.start()
                }catch let error as NSError {
                    print(error)
                }
                self.engine.mainMixerNode.outputVolume = 1.0
                
                self.tonePlayer.preparePlaying()
                self.tonePlayer.play()
                self.tonePlayerAvailable = false
            }
        }
        colorPickerImageView.endedTouch = { [unowned self] in
            self.tonePlayer.stop()
            self.tonePlayerAvailable = true
            
            self.engine.stop()
        }
        
    }
    
    func initAudio() {
        self.tonePlayer = AVTonePlayer()
        self.engine = AVAudioEngine()
        self.engine.attach(tonePlayer)
        let mixer = engine.mainMixerNode
        let format = AVAudioFormat(standardFormatWithSampleRate: tonePlayer.sampleRate, channels: 1)
        
        self.engine.connect(tonePlayer, to: mixer, format: format)
    }
    
    
    // MARK: IBAction
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            // default
            colorPickerImageView.image = UIImage(named: "demo_colorful_city")
            colorPickerImageView.mode = .getColorByPixel
            
            let imagePickerController = UIImagePickerController()
            
            guard let delegate = self.imagePickerDelegate as (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? else {
                print("ColorViewController : delegate error")
                return
            }
            
            imagePickerController.delegate = delegate
            imagePickerController.sourceType = .savedPhotosAlbum
            self.present(imagePickerController, animated: true, completion: nil)
            
            sender.selectedSegmentIndex = 1
            
        case 1:
            colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
            colorPickerImageView.mode = .makeHSBColor
        default :
            colorPickerImageView.mode = .none
            
            self.performSegue(withIdentifier: "CameraView", sender: nil)
            
            
            sender.selectedSegmentIndex = 0
            
//            colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
            colorPickerImageView.mode = .getColorByPixel
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CameraView" {
            
            let destination = segue.destination as! CameraViewController
            destination.ddd = { (image) in
                self.colorPickerImageView.image = image
            }
        }
    }
    
}
