//
//  UIImage.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 18..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit

extension UIImage {
    
    func playByRandomPixel() {
        let size = Int(self.size.width) * Int(self.size.height)
        var pixels : Set<Int> = []
        
        for location in 0 ..< size {
            pixels.insert(location)
        }
        
        
        for _ in 0 ..< size {
            var pixelPointer = pixels.removeFirst()
            
            let y = pixelPointer / Int(self.size.width)
            let x = pixelPointer % Int(self.size.width)
            
            let imageSize = self.size
            let scale: CGFloat = 0
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
            let context = UIGraphicsGetCurrentContext()
            
            self.draw(at: CGPoint(x: 0, y: 0) )
            
            let rectangle = CGRect(x: x, y: y, width: 1, height: 1)
            context?.setFillColor(UIColor.black.cgColor)
            context?.addRect(rectangle)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    func getRandomColorsByPiexels() -> [UIColor] {
        var colors = [UIColor]()
        
        let pixelData = self.cgImage!.dataProvider?.data
        let data : UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let size = Int(self.size.width) * Int(self.size.height)
        var pixels : Set<Int> = []
        
        
        for location in 0 ..< size {
            pixels.insert(location)
        }
        print(size)
        
        for _ in 0 ..< size {
            let pixelPointer = pixels.removeFirst()
            
            let r = CGFloat(data[pixelPointer]) / CGFloat(255.0)
            let g = CGFloat(data[pixelPointer+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelPointer+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelPointer+3]) / CGFloat(255.0)
            
            let color = UIColor(red: r, green: g, blue: b, alpha: a)
            
            print("colors")
            colors.append(color)
        }
        
        return colors
    }
}
