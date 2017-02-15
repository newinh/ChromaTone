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
    var tonePlayer: TonePlayer!
    var tonePlayerAvailable: Bool = true
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Color Picker 이미지 선택
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        colorPickerImageView.isUserInteractionEnabled = true
        
        initAudio()
        
        // Color Picked Completion Handler
        colorPickerImageView.pickedColor = { [unowned self] (newColor) in
            
            // 색 미리보기
            self.preview.backgroundColor = newColor
            
            // 음정 변환
            self.tonePlayer.frequency = newColor.color2soundSimple()
            
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
        self.tonePlayer = TonePlayer()
        self.engine = AVAudioEngine()
        self.engine.attach(tonePlayer)
        let mixer = engine.mainMixerNode
        let format = AVAudioFormat(standardFormatWithSampleRate: tonePlayer.sampleRate, channels: 1)
        
        self.engine.connect(tonePlayer, to: mixer, format: format)
    }
    
    
    // MARK: IBAction
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0: // Picture
            // default image
            colorPickerImageView.image = UIImage(named: "demo_colorful_city")
            colorPickerImageView.mode = .getColorByPixel
            
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.delegate = self
            imagePickerController.sourceType = .savedPhotosAlbum
            self.present(imagePickerController, animated: true, completion: nil)
            
        case 1:
            colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
            colorPickerImageView.mode = .makeHSBColor
        default :
            
            self.performSegue(withIdentifier: "CameraView", sender: nil)

            // 카메라뷰 열고 ColorView는 Picker모드로
            modeChanger.selectedSegmentIndex = 1
            colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
            colorPickerImageView.mode = .makeHSBColor
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        // 카메라뷰로 넘어갈 때 오디오 instance 전달
        if segue.identifier == "CameraView" {
            
            let destinaion = segue.destination as! CameraViewController
            destinaion.engine = self.engine
            destinaion.tonePlayer = self.tonePlayer
            
        }
    }
    
}

extension ColorViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.colorPickerImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
