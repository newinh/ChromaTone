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

    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        
        // add plot
        self.plot.addSubview(AKRollingOutputPlot(frame: self.plot.bounds))
        
        super.viewDidLoad()
        
        // Color Picker 이미지 선택
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        colorPickerImageView.isUserInteractionEnabled = true
        
        // Color Picked Completion Handler
        colorPickerImageView.pickedColor = { [unowned self] (newColor) in
            
            // 색 미리보기
            self.preview.backgroundColor = newColor
            ToneController.sharedInstance().play(color: newColor)
            
        }
        colorPickerImageView.endedTouch = {
            ToneController.sharedInstance().stop()
        }
        
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
    
    @IBAction func play(_ sender: UIButton) {
        
        let option = ImagePlayer.option(bpm: 120, rhythm: 3, noteCount: 100)
        let player = ImagePlayer(source: self.colorPickerImageView.image!, option: option)
        player.play()
        
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.5
        animation.repeatCount = 1
        
        let imageFrame = self.colorPickerImageView.imageFrame()
        let makerSize: CGFloat = 40
        player.pickedSingleColor = { (color, x, y ) in
            
            let scale =  imageFrame.size.width / self.colorPickerImageView.intrinsicContentSize.width
            let revisedX = imageFrame.minX + CGFloat(x) * scale
            let revisedY = imageFrame.minY + CGFloat(y) * scale
            
            let layer = CALayer()
            layer.backgroundColor = color.cgColor
            layer.frame = CGRect(x: revisedX - makerSize/2, y: revisedY - makerSize/2, width: makerSize, height: makerSize)
            
            layer.cornerRadius = makerSize/2
            layer.borderWidth = 1
            layer.borderColor = UIColor.red.cgColor
            
            layer.opacity = 0
            layer.add(animation, forKey: "opacity")
            
            self.colorPickerImageView.layer.addSublayer(layer)
        }
        
        player.completionHandler = {
            for sublayer in self.colorPickerImageView.layer.sublayers ?? [] {
                sublayer.removeFromSuperlayer()
            }
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
