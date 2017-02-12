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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Color Picker 이미지 선택
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        colorPickerImageView.isUserInteractionEnabled = true
        
        initAudio()
        
        // Color Picked Completion Handler
        colorPickerImageView.pickedColor = { (makedColor) in
            
            // 색 미리보기
            self.preview.backgroundColor = makedColor
            // 주파수 변환
            self.tonePlayer.frequency = Calculator.color2sound(color: makedColor)
            
            if self.tonePlayerAvailable {
                
                self.engine.mainMixerNode.outputVolume = 1.0
                self.tonePlayer.preparePlaying()
                self.tonePlayer.play()
                self.tonePlayerAvailable = false
            }
        }
        colorPickerImageView.endedTouch = {
            self.tonePlayer.stop()
            self.tonePlayerAvailable = true
        }
        
    }
    
    func initAudio() {
        self.tonePlayer = AVTonePlayer()
        self.engine = AVAudioEngine()
        self.engine.attach(tonePlayer)
        let mixer = engine.mainMixerNode
        let format = AVAudioFormat(standardFormatWithSampleRate: tonePlayer.sampleRate, channels: 1)
        
        self.engine.connect(tonePlayer, to: mixer, format: format)
        
        do{
            try self.engine.start()
        }catch let error as NSError {
            print(error)
        }
    }
    
    
    // MARK: IBAction
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            colorPickerImageView.image = UIImage(named: "demo_colorful_picture")
            colorPickerImageView.isUserInteractionEnabled = false
        case 1:
            colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
            colorPickerImageView.isUserInteractionEnabled = true
        default :
            print("2")
        }
    }
}
