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

    // Completion Handler
    var pickedColor :  ( (UIColor) -> () )?
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstTouch = touches.first
        
        guard let touchedPoint = firstTouch?.location(in: self) else {
            print("ColorPicerImageView touchPoint error")
            return
        }
        
        let centerPoint = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        let newColor = Calculator.HSBcolor(center: centerPoint, touched: touchedPoint, radius: self.frame.height/2)
        
        // Completion Handler
        if let pickedColor = pickedColor {
            pickedColor(newColor)
        }
    }
}
