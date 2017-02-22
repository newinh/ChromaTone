//
//  ColorViewController+ImagePlayer.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 23..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import AudioKit


extension ColorViewController {
    
    func prepareImagePlayer() -> ImagePlayer{
        
        // ImagePlyer 종료시 동작
        self.imagePlayerCompleted = {
            for sublayer in self.colorPickerImageView.layer.sublayers ?? [] {
                sublayer.removeFromSuperlayer()
            }
            self.playToggleButton.setImage(UIImage(named: Constants.playIcon), for: .normal)
            self.pickerSoundOn()
            self.view.backgroundColor = UIColor.white
            
            self.scanBarIsMoving = false
        }
        
        prepareReceivingSingleColor()
        prepareReceivingScanColor()
        
        // image 바꾸면 imagePlayer 생성
        // 1beat 에 4 노트
        let option = ImagePlayer.getOption()
        let imagePlayer = ImagePlayer(source: self.colorPickerImageView.image!, option: option)
        imagePlayer.completionHandler = self.imagePlayerCompleted
        imagePlayer.pickedSingleColor = self.receivedSingleColorByImagePlyer
        imagePlayer.pickedScanColor = self.receivedScanColorByImagePlyer
        
        return imagePlayer
    }
    
    func prepareReceivingScanColor() {
        
        let imageFrame = self.colorPickerImageView.imageFrame()
        
        
        self.receivedScanColorByImagePlyer = { (color, x, y, option, count) in
            
            if self.scanBarIsMoving {
                return
            }
            
            self.scanBarIsMoving = true
            
            let bpm = Double(option.bpm)
            let timePerBeat = Double ( option.timePerBeat)
            let noteCount = Double (option.noteCount)
            
            let layer = CALayer()
            layer.borderWidth = 1.5
            layer.borderColor = UIColor.red.cgColor
            
            let animation = CABasicAnimation(keyPath: "position")
            
            if option.playMode == .verticalScanBar {
                
                let x = imageFrame.minX + (imageFrame.width / CGFloat(option.scanUnit)) * CGFloat(count - 1)
                
                layer.frame = CGRect(x: -100, y: imageFrame.minY, width: 1.5, height: imageFrame.height)
                
                animation.fromValue = NSValue (cgPoint :CGPoint(x: x, y: layer.position.y) )
                animation.toValue = NSValue(cgPoint : CGPoint(x: imageFrame.maxX + 0.75, y: layer.position.y) )
                
                animation.duration = (1 / ( (bpm / 60) * timePerBeat ) * (noteCount - count + 1) )
                animation.repeatCount = 1
                layer.add(animation, forKey: "position")
                
            }else if option.playMode == .horizontalScanBar {
                
                let y = imageFrame.minY + (imageFrame.height / CGFloat(option.scanUnit)) * CGFloat(count - 1)
                
                layer.frame = CGRect(x: imageFrame.minX, y: -100, width: imageFrame.width, height: 1.5)
                
                animation.fromValue = NSValue (cgPoint :CGPoint(x: layer.position.x, y: y) )
                animation.toValue = NSValue(cgPoint : CGPoint(x: layer.position.x , y: imageFrame.maxY + 0.75) )
                
                animation.duration = (1 / ( (bpm / 60) * timePerBeat ) * (noteCount - count + 1) )
                animation.repeatCount = 1
                layer.add(animation, forKey: "position")
            }
            self.colorPickerImageView.layer.insertSublayer(layer, at: 0)
            
        }
    }
    
    func prepareReceivingSingleColor() {
        // ImagePlayer가 `색`을 만들었을 때 동작
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 1
        animation.repeatCount = 1
        
        let imageFrame = self.colorPickerImageView.imageFrame()
        let makerSize: CGFloat = 40
        
        
        self.receivedSingleColorByImagePlyer = {
            (color, x, y ) in
            
            self.view.backgroundColor = color
            
            // animation
            let scale =  imageFrame.size.width / self.colorPickerImageView.intrinsicContentSize.width
            let revisedX = imageFrame.minX + CGFloat(x!) * scale
            let revisedY = imageFrame.minY + CGFloat(y!) * scale
            
            let layer = CALayer()
            layer.backgroundColor = color.cgColor
            layer.frame = CGRect(x: revisedX - makerSize/2, y: revisedY - makerSize/2, width: makerSize, height: makerSize)
            
            layer.cornerRadius = makerSize/2
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.cgColor
            
            layer.opacity = 0
            layer.add(animation, forKey: "opacity")
            
            self.colorPickerImageView.layer.insertSublayer(layer, at: 1)
            
        }
        
    }
}
