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
        var bpm : TimeInterval = 0
        var rhythm : Int = 0
        var noteCount : Int = 0
    }
    var option : ImagePlayer.option
    
    init(source image: UIImage, option: ImagePlayer.option) {
        self.image = image
        self.option = option
    }
    
    
    /*
     step1. Image 에서 픽셀location 가져오기 x
     step2. pixel을 색 정보 가져오기
     step3. 얻어온 색정보로 소리 재생
     
     step4 현란하게 재생...
     */
    
    var i = 0
    
    var pixelLocations : [Int] = []
    let pixelData = self.image.
    
    public func prepare() {

        self.choosePixel()
        
//        let pixelData = self.cgImage!.dataProvider?.data
//        let data : UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        //timer setup
        // 1 비트를 4박자로 쪼갬
        let interval = TimeInterval(  (60 / self.option.bpm) / 4 )
        print("interval : \(interval)" )
        
        
        
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(self.performImage), userInfo: nil, repeats: true)
    }
    
    public func play() {
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    public func stop() {
        // timer stop
        self.timer?.invalidate()
        self.timer = nil
        
    }
    
    public func resume() {
        print("timer resum")
        self.timer = Timer(timeInterval: 0.125, repeats: true, block: { (timer) in
            
            /// 디버그용
            self.i += 1
            print(self.i)
            print( Date.timeIntervalSinceReferenceDate.debugDescription )
            
            if self.i > 10 {
                self.pause()
            }
        })
        self.play()
    }
    
    public func pause() {
        self.timer?.invalidate()
    }
    
    public func step() {
        // timer 단계
    }
    
    
    @objc public func performImage() {
        
        if self.pixelLocations.isEmpty {
            self.stop()
        }
        
        /// 디버그용
        self.i += 1
        print(self.i)
        print( Date.timeIntervalSinceReferenceDate.debugDescription )
        
        if self.i > 10 {
            self.pause()
        }
    }
    
    public func choosePixel() {
        let lastPixelLocation = Int(self.image.size.width) * Int(self.image.size.height)
        
        // lastPixelLocation 이 2^32승을 넘어 가면 gg
        // 즉, 이미지 크기가 2^32 보다 크면 안된다...
        // 2^16 = 65,536
        for _ in 0 ..< self.option.noteCount {
            let rand = arc4random_uniform(UInt32(lastPixelLocation))
            self.pixelLocations.append( Int(rand) )
        }
    }
    
}
