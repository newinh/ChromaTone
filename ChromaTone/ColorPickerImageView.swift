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
        
        
        for (_, touch) in touches.enumerated() {
            
            switch mode {
            case .makeHSBColor:
                makeColor(touch: touch)
            case .getColorByPixel:
                getColorByPixel(touch: touch)
            default:
                print("maybe camera mode...")
            }
            
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for (_, touch) in touches.enumerated() {
            
            switch mode {
            case .makeHSBColor:
                makeColor(touch: touch)
            case .getColorByPixel:
                getColorByPixel(touch: touch)
            default:
                print("maybe camera mode...")
            }
            
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
        let newColor = self.makeHSBcolor(center: centerPoint, touched: touchedPoint, radius: radius)
        
        guard let color = newColor else {
            if let endedTouch = self.endedTouch {
                endedTouch()
            }
            return
        }
        
        // Completion Handler
        if let pickedColor = self.pickedColor {
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
        let imageFrame = self.imageFrame()
        let scale = self.intrinsicContentSize.width / imageFrame.size.width
        let revisedPoint = touchPoint.revisedPoint(to: imageFrame, scale: scale)
        
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
    
    // 극좌표계를 이용, HSB모델 색 생성
    // hue : 각
    // saturation : 거리
    // bright : 기본값 (1)
    // alpha : 기본값 (1)
    func makeHSBcolor(center: CGPoint, touched: CGPoint, radius: CGFloat) -> UIColor? {
        
        print(String(format: "centerX : %.2f   touchedX : %.2f", center.x, touched.x))
        print(String(format: "centerY : %.2f   touchedY : %.2f", center.y, touched.y))
        
        let x = Double (touched.x - center.x)
        let y = Double (center.y - touched.y)   // 헷갈리는 부분. ios y좌표는 반대다.
        let radius = Double(radius)
        
        print("x : \(x)     y : \(y)")
        
        var distance = sqrt( pow(x, 2)  + pow(y, 2)  )
        print("distance : \(distance)   radius : \(radius)")
        distance /=  radius
        //        print("distance /= radius : \(distance)")
        
        if distance > 1.1 {
            return nil
        }
        
        let radian = atan2(y, x)
        var degree = (radian/M_PI) * 180
        if degree < 0 {
            degree += 360
        }
        print ("degree : \(degree)")
        degree /= 360
        
        return UIColor(hue: CGFloat(degree), saturation: CGFloat(distance), brightness: 1, alpha: 1)
    }
    
}


extension UIImageView {
    
    // AspectFit에 적용된 image 크기
    func imageFrame() -> CGRect {
        
        guard let image = self.image else {
            print("imageFrame : No image")
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        let imageRatio : CGFloat = image.size.width / image.size.height
        let viewRatio: CGFloat = self.frame.size.width / self.frame.size.height
        
        // imageView의 heigt에 꽉 차게 맞춰짐
        if imageRatio < viewRatio {
            
            let scale: CGFloat = self.frame.size.height / image.size.height
            let width = scale * image.size.width
            let topLeftX = (self.frame.size.width - width) / 2
            return CGRect(x: topLeftX, y: CGFloat(0), width: width, height: self.frame.size.height)
        }
            // imageView의 width에 꽉 차게 맞춰짐
        else {
            let scale: CGFloat = self.frame.size.width / image.size.width
            let height = scale * image.size.height
            let topLeftY = (self.frame.size.height - height) / 2
            return CGRect(x: CGFloat(0), y: topLeftY, width: self.frame.size.width, height: height)
        }
    }
}

extension CGPoint {
    
    // touch Point 입력받은 frame에 맞게 보정
    func revisedPoint(to frame: CGRect, scale: CGFloat) -> CGPoint {
        
        
        let revisedX = self.x - frame.minX
        let revisedY = self.y - frame.minY
        
        let scaledX = revisedX * scale
        let scaledY = revisedY * scale
        
        return CGPoint(x: scaledX, y: scaledY)
    }
    
}
