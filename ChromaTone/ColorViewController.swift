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

    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Color Picker 이미지 선택
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        colorPickerImageView.isUserInteractionEnabled = true
        
    
//        var tone = AKOscillator(waveform: AKTable(.sine) )
        let tone = AKOscillatorBank(waveform: AKTable(.sine),
                                    attackDuration: 0.01,
//                                    sustainLevel: 1.0,
                                    releaseDuration: 0.01)
//        AKOscillatorBank(waveform: <#T##AKTable#>, attackDuration: <#T##Double#>, decayDuration: <#T##Double#>, sustainLevel: <#T##Double#>, releaseDuration: <#T##Double#>, detuningOffset: <#T##Double#>, detuningMultiplier: <#T##Double#>)
        
        AudioKit.output = tone
        
        // Color Picked Completion Handler
        colorPickerImageView.pickedColor = { [unowned self] (newColor) in
            
            // 색 미리보기
            self.preview.backgroundColor = newColor
            
            tone.play(noteNumber: newColor.color2midiNumberSimple(), velocity: 80)
            
        }
        colorPickerImageView.endedTouch = { [unowned self] in
            tone.stop(noteNumber: self.preview.backgroundColor?.color2midiNumberSimple() ?? 57)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioKit.start()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioKit.stop()
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
//            destinaion.engine = self.engine
//            destinaion.tonePlayer = self.tonePlayer
            
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
