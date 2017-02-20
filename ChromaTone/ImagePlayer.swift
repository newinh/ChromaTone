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
    
    // pixel 하나 고를 때 마다 표현할 UI
    var pickedSingleColor : ( (UIColor, _ x : Int, _ y : Int )  -> Void )?
    // 동작이 끝났을 때 표현할 UI
    var completionHandler: ( (Void) -> Void )?
    
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
        
        self.pixelData = image.cgImage?.dataProvider?.data
        self.data = CFDataGetBytePtr(self.pixelData)
        
        self.prepare()
        
    }
    
    
    /*
     step1. Image 에서 픽셀location 가져오기 x
     step2. pixel을 색 정보 가져오기
     step3. 얻어온 색정보로 소리 재생
     
     step4 현란하게 재생...
     */
    
    var i = 0
    
    var pixelLocations : [Int] = []
    let pixelData : CFData?
    let data : UnsafePointer<UInt8>
    
    // 새로운 음악을 만들자
    public func prepare() {

        self.preparePixel()
        
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
        ToneController.sharedInstance().stop()
        // timer stop
        self.timer?.invalidate()
        self.prepare()
        
        if let completionHandler = completionHandler {
            completionHandler()
        }
        
    }
    
    public func resume() {
        // 1 비트를 4박자로 쪼갬
        let interval = TimeInterval(  (60 / self.option.bpm) / 4 )
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(self.performImage), userInfo: nil, repeats: true)
    }
    
    public func pause() {
        ToneController.sharedInstance().stop()
        self.timer?.invalidate()
    }
    
    
    @objc public func performImage() {
        
        if self.pixelLocations.isEmpty {
            self.stop()
            return
        }
        let color = getSingleColor()
        ToneController.sharedInstance().play(color: color)
        
    }
    
    /// step1
    public func preparePixel() {
        let lastPixelLocation = Int(self.image.size.width) * Int(self.image.size.height)
        
        // lastPixelLocation 이 2^32승을 넘어 가면 gg
        // 즉, 이미지 크기가 2^32 보다 크면 안된다...
        // 2^16 = 65,536
        for _ in 0 ..< self.option.noteCount {
            let rand = arc4random_uniform(UInt32(lastPixelLocation))
            self.pixelLocations.append( Int(rand) )
        }
    }
    
    /// step2
    // pixelLocations 에서 pixel 하나 꺼내와서 컬러고 바꿈!
    public func getSingleColor() -> UIColor{
        
        let pixelLocation = pixelLocations.removeFirst() * 4
        
        // get color
        let r = CGFloat(data[pixelLocation]) / CGFloat(255.0)
        let g = CGFloat(data[pixelLocation+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelLocation+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelLocation+3]) / CGFloat(255.0)
        
        let color = UIColor(red: r, green: g, blue: b, alpha: a)
        
        let y = (pixelLocation / 4) / Int(self.image.size.width)
        let x = (pixelLocation / 4) % Int(self.image.size.width)
        
        if let pickedSingleColor = pickedSingleColor {
            pickedSingleColor(color, x, y )
        }
        
        return color
    }
    
}
