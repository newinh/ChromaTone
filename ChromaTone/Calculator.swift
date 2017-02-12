//
//  Converter.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 10..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit

open class Calculator {
    
    
    // frequency = 110 * pow(2, (saturation*2)) * pow(2, hue)
    static func color2sound(color: UIColor) -> Double{
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        
        let result = color.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        
        if result {
            let hue = Double(hue)
            let saturation = Double(saturation)
            let frequency = 110 * pow(2,saturation*2) * pow(2, hue)
            print("frequency : \(frequency)Hz")
            return frequency
            
        }
        return 440
    }
    
    static func sound2color() {
        
    }
    
    // 극좌표계를 이용, HSB모델 색 생성
    // hue : 각
    // saturation : 거리
    // bright : 기본값 (1)
    // alpha : 기본값 (1)
    static func HSBcolor(center: CGPoint, touched: CGPoint, radius: CGFloat) -> UIColor? {
        
        print("centerX : \(center.x)   touchedX : \(touched.x)")
        print("centerY : \(center.y)   touchedY : \(touched.y)")
        
        let x = Double (touched.x - center.x)
        let y = Double (center.y - touched.y)   // 헷갈리는 부분. ios y좌표는 반대다.
        let radius = Double(radius)
        
        print("x : \(x)")
        print("y : \(y)")
        
        var distance = sqrt( pow(x, 2)  + pow(y, 2)  )
        print("distance : \(distance)")
        print("radius : \(radius)")
        
        distance /=  radius
        print("distance /= radius : \(distance)")
        
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
//        print("degree /= 360 : \(degree)")
        
        return UIColor(hue: CGFloat(degree), saturation: CGFloat(distance), brightness: 1, alpha: 1)
    }
    
    
}
