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
        colorPickerImageView.endedTouch = {
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
            colorPickerImageView.image = UIImage(named: "demo_colorful_city")
            colorPickerImageView.mode = .getColorByPixel
        case 1:
            colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
            colorPickerImageView.mode = .makeHSBColor
        default :
            print("2")
            colorPickerImageView.mode = .none
        }
    }
    
}
