//
//  ColorPickerImageView.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 11..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerImageView : UIImageView {
    
//    var pickedColor: UIColor = UIColor.white
    
    var pickC :  ( (UIColor) -> () )?
        
    
    
    init() {
        let img = UIImage(named: Constants.colorPickerImage)
        super.init(image: img)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstTouch = touches.first
        
        guard let touchedPoint = firstTouch?.location(in: self) else {
            print("ColorPicerImageView touchPoint error")
            return
        }
        
        let centerPoint = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        let newColor = Calculator.HSBcolor(center: centerPoint, touched: touchedPoint, radius: self.frame.height/2)
        
        if let closure = closure {
            closure(newColor)
        }
        
    }
}
