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

    
    enum Mode {
        case makeHSBColor
        case getColorByPixel
        case none
    }
    
    var mode : Mode = .makeHSBColor
    
    // Completion Handler
    var pickedColor :  ( (UIColor) -> () )?
    var endedTouch : ( (Void) -> (Void) )?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let firstTouch = touches.first else{
            print("colorPickerImageView : touch error")
            return
        }
        
        switch mode {
        case .makeHSBColor:
            makeColor(touch: firstTouch)
        case .getColorByPixel:
            getColorByPixel(touch: firstTouch)
        default:
            print("maybe camera mode...")
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let firstTouch = touches.first else{
            print("colorPickerImageView : touch error")
            return
        }
        
        switch mode {
        case .makeHSBColor:
            makeColor(touch: firstTouch)
        case .getColorByPixel:
            getColorByPixel(touch: firstTouch)
        default:
            print("maybe camera mode...")
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Completion Handler
        if let endedTouch = endedTouch {
            endedTouch()
        }
    }
    
    
    func makeColor(touch: UITouch) {
        
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
    
    
    
    func getColorByPixel(touch : UITouch){
        
        let touchPoint = touch.location(in: self)
        
        guard let image = self.image else {
            print("ColorPickerImageView : No Image")
            return
        }

        // touch 좌표 보정
        let newImageFrame = Calculator.imageFrame(origin: image, inImageViewAspectFit: self)
        let scale = self.intrinsicContentSize.width / newImageFrame.size.width
        let revisedPoint = Calculator.revisedPoint(from: touchPoint, to: newImageFrame, scale: scale)
        
        // get pixel data
        let pixelInfo: Int = ((Int(image.size.width) * Int(revisedPoint.y)) + Int(revisedPoint.x)) * 4
        let pixelData = image.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        // 허용범위를 넘어선다면 endTouch()
        let maximumPixelInfo: Int = Int( image.size.width * image.size.height  ) * 4
        if pixelInfo < 0 || pixelInfo > maximumPixelInfo {
            
            if let endedTouch = endedTouch {
                endedTouch()
            }
            return
        }
        // get color
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        let newColor = UIColor(red: r, green: g, blue: b, alpha: a)
        
        // Completion Handler
        if let pickedColor = pickedColor {
            pickedColor(newColor)
        }
    }
    
}
