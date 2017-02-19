//
//  ImagePlayer.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 19..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class ImagePlayer {
    
    let image : UIImage
    
    // pixel 넣어서 MainUI update 할것 : 해당하는 픽셀 없어진것처럼 표현
    var playHandler : ( (CGRect)  -> Void )?
    var pixelHandler : ( (CGRect)  -> Void )?
    
    var timer : Timer?
    
    
    struct option {
        var bpm = 0
        var rhythm = 0
    }
    var option : ImagePlayer.option
    
    init(source image: UIImage, option: ImagePlayer.option) {
        self.image = image
        self.option = option
    }
    
    
    /*
     step1. Image 에서 픽셀location 가져오기
     step2. pixel을 색 정보 가져오기
     step3. 얻어온 색정보로 소리 재생
     
     step4 현란하게 재생...
     */
    
    public func prepare() {
        
        //timer setup
//        self.timer = Timer(timeInterval: <#T##TimeInterval#>, repeats: <#T##Bool#>, block: <#T##(Timer) -> Void#>)
//        self.timer = Timer(timeInterval: <#T##TimeInterval#>, target: <#T##Any#>, selector: <#T##Selector#>, userInfo: <#T##Any?#>, repeats: <#T##Bool#>)
        
    }
    
    public func play() {
        // timer start
        // timer fire
//        Timer.scheduledTimer(withTimeInterval: <#T##TimeInterval#>, repeats: <#T##Bool#>, block: <#T##(Timer) -> Void#>)
    }
    
    public func stop() {
        // timer stop
        
    }
    
    public func resume() {
        
    }
    
    public func pause() {
        
    }
    
    public func step() {
        // timer 단계
    }
    
    
    
    
    public func getPixelLocation() {
        
    }
    
}
