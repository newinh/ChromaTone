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
    var endedTouch : ( (Void) -> (Void) )?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            pickingColor(touch: firstTouch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            pickingColor(touch: firstTouch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Completion Handler
        if let endedTouch = endedTouch {
            endedTouch()
        }
    }
    
    
    func pickingColor(touch: UITouch) {
        
        let touchedPoint = touch.location(in: self)
        let centerPoint = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        let radius: CGFloat
        if self.frame.width < self.frame.height {
            radius = (self.frame.width) / 2
        }else {
            radius = (self.frame.height) / 2
        }

        // 거리가 1보다 커지면 nil 반환
        let newColor = Calculator.HSBcolor(center: centerPoint, touched: touchedPoint, radius: radius)
        
        guard let color = newColor else {
            if let endedTouch = endedTouch {
                endedTouch()
            }
            return
        }
        
        // Completion Handler
        if let pickedColor = pickedColor {
            pickedColor(color)
        }
    }
    
}
