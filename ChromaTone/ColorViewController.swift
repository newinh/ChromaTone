//
//  ViewController.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 7..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit

class ColorViewController: UIViewController {
    
    
    // MARK: IBOuelt
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var modeChanger : UISegmentedControl!
    @IBOutlet weak var cTest: UIImageView!
    
    var colorPickerImageView : ColorPickerImageView!
    let pictureImageView = UIImageView(image: UIImage(named: "demo_colorful_picture"))
    
    
    
    var c3 : NSLayoutConstraint!
    var c4 : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.colorPickerImageView = ColorPickerImageView()
        self.colorPickerImageView.pickedColor = { (color) in
            self.preview.backgroundColor = color
        }
        self.cTest.image = UIImage(named: "demo_colorful_picture")
        self.colorView.addSubview(self.colorPickerImageView)
//        self.colorView.addSubview(self.pictureImageView)
        self.pictureImageView.isHidden = true
        
        modeChanger.selectedSegmentIndex = 1
        
        let c1 = NSLayoutConstraint(item: self.colorPickerImageView, attribute: .centerX, relatedBy: .equal, toItem: self.colorView, attribute: .centerX, multiplier: 1, constant: 0)
        let c2 = NSLayoutConstraint(item: self.colorPickerImageView, attribute: .centerY, relatedBy: .equal, toItem: self.colorView, attribute: .centerY, multiplier: 1, constant: 0)
        c3 = NSLayoutConstraint(item: self.colorPickerImageView, attribute: .height, relatedBy: .equal, toItem: self.colorPickerImageView, attribute: .width, multiplier: 1, constant: 0)
        
        c4 = NSLayoutConstraint(item: self.colorPickerImageView, attribute: .width, relatedBy: .equal, toItem: self.colorView, attribute: .width, multiplier: 1, constant: 0)
        
        c4.priority = 990
        
        self.colorPickerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let c5 = NSLayoutConstraint(item: self.colorPickerImageView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.modeChanger, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.view.addConstraint(c5)
        self.view.addConstraint(c1)
        self.view.addConstraint(c2)
        self.view.addConstraint(c3)
        self.view.addConstraint(c4)

    }
    
    
    // MARK: IBAction
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            colorPickerImageView.isHidden = true
            cTest.isHidden = false
            pictureImageView.isHidden = false
            
        case 1:
            colorPickerImageView.isHidden = false
            pictureImageView.isHidden = true
            cTest.isHidden = true
        default :
            print("2")
        }
    }
}
