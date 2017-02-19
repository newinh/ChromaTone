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
    @IBOutlet weak var playButton : UIButton!

    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Color Picker 이미지 선택
        colorPickerImageView.image = UIImage(named: Constants.colorPickerImage)
        colorPickerImageView.isUserInteractionEnabled = true
        
        
        /// Todo: userDefault 적용
        /// 흠.. 요상한 코드가 되버림
        
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
        
        let newFrame = self.colorPickerImageView.imageFrame()
        
        
        let width = Int(newFrame.size.width)
        let height = Int(newFrame.size.height)
        
        let size = width * height
        var pixels : Set<Int> = []
        
        // 0 ~ 99
        for location in 0 ..< 100 {
            pixels.insert(location)
        }
        
        
        let queue = DispatchQueue(label: "painter")
        
        for i in 0 ..< 100 {
            
            queue.async {
                var pixelPointer = pixels.removeFirst()
                
                // 0 ~ 100
                // 0 1 2 3 ... 9
                // 10 11 12 ...19
                
                usleep(125000)
                
                let y = Int(newFrame.minY) + (pixelPointer / 10) * height/10
                let x = Int(newFrame.minX) + (pixelPointer % 10) * width/10
            
                print(Int(newFrame.minY))
                print(pixelPointer)
                print(height)
                print(width)
                
                print(" (\(x), \(y))")
            
                
                let rect = CGRect(x: x, y: y, width: width/10, height: height/10)
                let view1 = UIView(frame: rect)
                view1.backgroundColor = UIColor.black
                
                DispatchQueue.main.async {
//                    self.colorPickerImageView.image = newImage
                    self.colorPickerImageView.addSubview(view1)
                    
                    view1.setNeedsDisplay()
                    print(i)
//                    self.view.invalidateIntrinsicContentSize()
                }
            }
           
            
        }
        
        queue.async {
            DispatchQueue.main.async {
                for subview in self.colorPickerImageView.subviews {
                    subview.removeFromSuperview()
                }
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
