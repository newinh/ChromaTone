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
    
    
    
    // MARK: Local Variable
    var centerPoint: CGPoint = CGPoint(x: 0, y: 0)
    var radius  : CGFloat = 0
    
    // 0 ... 1
    var hue: CGFloat = 1
    var saturation: CGFloat = 1
    var brightness: CGFloat = 1
    
    let colorPickerImageView = UIImageView(image: UIImage(named: "demo_color_wheel2"))
    
    let PictureImageView = UIImageView(image: UIImage(named: "demo_colorful_picture"))
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        self.colorView.frame = CGRect(x: size.width/2 - radius, y: size.height/2 - radius
            , width: 2*radius, height: 2*radius)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let colorPickerImageView = ColorPickerImageView()
        colorPickerImageView.closure = { (color) in
            self.preview.backgroundColor = color
        }
        self.colorView.addSubview(colorPickerImageView)
        
//        updateCenterPoint()
        
//        initColorPicker()
        
        modeChanger.selectedSegmentIndex = 1
//        initPaletteView()
        
    }
    
    private func updateCenterPoint() {
        let viewWidth = view.frame.size.width
        let viewHeight = view.frame.size.height
        
        radius = (min(viewWidth, viewHeight) - 5) / 2
        centerPoint = CGPoint(x: viewWidth/2, y: viewHeight/2)
    }
    
    private func initColorPicker() {
        
        self.colorPickerImageView.frame = CGRect(x: 0, y: 0, width: 2*radius, height: 2*radius)
        self.colorPickerImageView.layer.cornerRadius = radius
        self.colorPickerImageView.layer.masksToBounds = true
        self.colorPickerImageView.clipsToBounds = true
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.touchedColorPicker(_:)))
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.touchedColorPicker(_:)))
        
        self.colorPickerImageView.isUserInteractionEnabled = true
//        self.colorPickerImageView.addGestureRecognizer(panGesture)
//        self.colorPickerImageView.addGestureRecognizer(tapGesture)
    }

    private func initPaletteView() {
        
        updateCenterPoint()
        
        self.colorView.frame = CGRect(x: centerPoint.x - radius, y: centerPoint.y - radius
            , width: 2*radius, height: 2*radius)
        
        self.colorView.layer.cornerRadius = radius
        self.colorView.clipsToBounds = true
        self.colorView.addSubview(self.colorPickerImageView)
    
    }
    
    private func initPictureView() {
        
        updateCenterPoint()
        
        self.colorView.frame = CGRect(x: centerPoint.x - radius, y: centerPoint.y - radius
            , width: 2*radius, height: 2*radius)
        
        self.colorView.layer.cornerRadius = 0
        self.colorView.clipsToBounds = true
        self.colorView.addSubview(self.PictureImageView)
    }
    
    @objc private func touchedColorPicker (_ sender: UIGestureRecognizer){
        
        let touchedPoint = sender.location(in: self.view)
        let touchedColor = Calculator.HSBcolor(center: self.centerPoint, touched: touchedPoint, radius: self.radius)
        
        preview.backgroundColor = touchedColor
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let firstTouch = touches.first
//        let point = firstTouch?.location(in: self.colorPickerImageView)
//        print("fistTouch : \(point)")
//    }
    
    
    // MARK: IBAction
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            colorPickerImageView.removeFromSuperview()
            initPictureView()
            
        case 1:
            PictureImageView.removeFromSuperview()
            initPaletteView()
        default :
            print("2")
        }
    }
}
