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
    
    static func color2sound() {
        
    }
    
    static func sound2color() {
        
    }
    
    // 극좌표계를 이용, HSB모델 색 생성
    // hue : 각
    // saturation : 거리
    // bright : 기본값 (1)
    // alpha : 기본값 (1)
    static func HSBcolor(center: CGPoint, touched: CGPoint, radius: CGFloat) -> UIColor {
        
        print("centerX : \(center.x)   touchedX : \(touched.x)")
        print("centerY : \(center.y)   touchedY : \(touched.y)")
        
        let x = Double (touched.x - center.x)
        let y = Double (center.y - touched.y)
        let radius = Double(radius)
        
        print("x : \(x)")
        print("y : \(y)")
        
        var distance = sqrt( pow(x, 2)  + pow(y, 2)  )
        print("distance : \(distance)")
        print("radius : \(radius)")
        
        distance /=  radius
        print("distance /= radius : \(distance)")
        
        let radian = atan2(y, x)
        var degree = (radian/M_PI) * 180
        if degree < 0 {
            degree += 360
        }
        print ("degree : \(degree)")
        degree /= 360
        print("degree /= 360 : \(degree)")
        
        
        return UIColor(hue: CGFloat(degree), saturation: CGFloat(distance), brightness: 1, alpha: 1)
    }
    
    
}
