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
    

    /// Toto : Customizable
    struct Option {
        var bpm : TimeInterval = 100
        var timePerBeat : Int = 4    /// 1비트당 박자
        var noteCount : Int = 0
        var playMode : PlayMode = .verticalScanBar
        
        enum PlayMode : String{
            case random
            case verticalScanBar
            case horizontalScanBar
        }
    }
    var option : ImagePlayer.Option
    
    
    enum PlayerStatus: String {
        case playing
        case pause
        case stop
    }
    var status : ImagePlayer.PlayerStatus = .stop
    
    init(source image: UIImage, option: ImagePlayer.Option) {
        
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
    /// New step 1.
    ///
    ///
    
    var i = 0
    
    var pixelLocations : [Int] = []
    let pixelData : CFData?
    let data : UnsafePointer<UInt8>
    
    // 새로운 음악을 만들자
    public func prepare() {
        
        print("prepare")

        self.preparePixel()
        self.prepareScan()
        
        //timer setup
        let interval = TimeInterval( 1 / ( Double(self.option.bpm/60) * Double(self.option.timePerBeat) ))
        print("interval : \(interval)" )
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(self.performImage), userInfo: nil, repeats: true)
    }
    
    public func play() {
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
        self.status = .playing
    }
    
    public func stop() {
        // timer stop
        self.timer?.invalidate()
        self.prepare()
        self.status = .stop
        count = 0
        
        if let completionHandler = completionHandler {
            completionHandler()
        }
        ToneController.sharedInstance().stop()
    }
    
    public func resume() {
        let interval = TimeInterval( 1 / ( Double(self.option.bpm/60) * Double(self.option.timePerBeat) ))
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(self.performImage), userInfo: nil, repeats: true)
        play()
    }
    
    public func pause() {
        ToneController.sharedInstance().stop()
        self.timer?.invalidate()
        self.status = .pause
    }
    
    
    var count = 0
//    var melodyChecker : Bool = true
//    var melodyLength: Int = 0
    
    /// step3
    @objc public func performImage() {  /// 한박자
        
//        if self.pixelLocations.isEmpty {
//            print("ImagePlayer.performImage() : pixels empty")
//            self.stop()
//            return
//        }
        
//        if colors.isEmpty {
//            print("ImagePlayer.performImage() : pixels empty")
//            self.stop()
//            return
//        }
        
        if RGBAs.isEmpty {
//            print("ImagePlayer.performImage() : pixels empty")
            self.stop()
            return
        }
        
        count += 1
        
        
        let onFirstBeat = count % self.option.timePerBeat == 0
        let everyOtherBeat = count % self.option.timePerBeat == self.option.timePerBeat/2

        var oddBeat : Bool = false
        if self.option.timePerBeat % 2 == 1{ // 홀수 일때 마지막 박자에 true!
            oddBeat = count % self.option.timePerBeat == self.option.timePerBeat - 1
        }
        
//        let melodyBeat = Array(0...3).randomElement() == 0
//        let randomHit2 = Array(0...7).randomElement() == 0
//        let randomHit3 = Array(0...7).randomElement() == 0
        
//        let color = getSingleColor()
//        let color = colors.removeFirst()
//        let info = color.color2soundTwo()
        let color = getScanColor()
        
        // 무채색
//        let achroma = info.frequency < 220
//        let rand = arc4random_uniform(2) == 0

        
//        if onFirstBeat {
//            ToneController.sharedInstance().playKick()
//        }else if everyOtherBeat || oddBeat {
//            ToneController.sharedInstance().playSnare()
//        }
        ToneController.sharedInstance().playMelody(color: color)
        ToneController.sharedInstance().playHiHat(50)
        
    }
    
    /// step1
    public func preparePixel() {

        switch self.option.playMode {
        case .random:
            
            let lastPixelLocation = Int(self.image.size.width) * Int(self.image.size.height)
            
            // lastPixelLocation 이 2^32승을 넘어 가면 gg
            // 즉, 이미지 크기가 2^32 보다 크면 안된다...
            // 2^16 = 65,536
            for _ in 0 ..< self.option.noteCount {
                let rand = arc4random_uniform(UInt32(lastPixelLocation))
                self.pixelLocations.append( Int(rand) )
            }
            
        case .horizontalScanBar:
            print()
        case .verticalScanBar :
            print()
        }
        
    }
    
    /// step2
    // pixelLocations 에서 pixel 하나 꺼내와서 `색`으로 바꿈!
    public func getSingleColor() -> UIColor{
        
        var color = UIColor.cyan
        
        switch self.option.playMode {
            case .random:
                
            let pixelLocation = pixelLocations.removeFirst() * 4
            
            // get color
            let r = CGFloat(data[pixelLocation]) / CGFloat(255.0)
            let g = CGFloat(data[pixelLocation+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelLocation+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelLocation+3]) / CGFloat(255.0)
            
            color = UIColor(red: r, green: g, blue: b, alpha: a)
            
            let y = (pixelLocation / 4) / Int(self.image.size.width)
            let x = (pixelLocation / 4) % Int(self.image.size.width)
            
            if let pickedSingleColor = pickedSingleColor {
                pickedSingleColor(color, x, y )
            }
           
        case .horizontalScanBar:
            color = UIColor.brown
            
        case .verticalScanBar :
            
            
            color = UIColor.brown
        }
        
        return color
    }
    

    var colors : [UIColor] = []
    var RGBAs : [(r: CGFloat,g: CGFloat, b: CGFloat, a: CGFloat, location : Int )] = []
    ///vertical
    private func prepareScan() {
        print("\(self.image.size.debugDescription)")
        /// test 10개
        for i in 0...10 {
            
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            var a : CGFloat = 0
            
            
            for j in 0...10 {
                let pixelLocation = j * (Int(self.image.size.height) / 10)  * Int(self.image.size.width) + ( i * Int(self.image.size.width/10) )
                
                print("///////////////// : \(pixelLocation)")
                let pixelLocationPointer = pixelLocation * 4
                
                let debugR = (CGFloat(data[pixelLocationPointer]) / CGFloat(255.0) )
                let debugG = (CGFloat(data[pixelLocationPointer+1]) / CGFloat(255.0) )
                let debugB = (CGFloat(data[pixelLocationPointer+2]) / CGFloat(255.0) )
                let debugA = (CGFloat(data[pixelLocationPointer+3]) / CGFloat(255.0) )
//                let debugColor = UIColor(red: debugR, green: debugG, blue: debugB, alpha: debugA)
                
                
                RGBAs.append((debugR,debugG,debugB,debugA , pixelLocation) )
                
                
//                r += (CGFloat(data[pixelLocationPointer]) / CGFloat(255.0) ) / 10
//                g += (CGFloat(data[pixelLocationPointer+1]) / CGFloat(255.0) ) / 10
//                b += (CGFloat(data[pixelLocationPointer+2]) / CGFloat(255.0) ) / 10
//                a += (CGFloat(data[pixelLocationPointer+3]) / CGFloat(255.0) ) / 10
            }
            
//            let color = UIColor(red: r, green: g, blue: b, alpha: a)
//            colors.append(color)
        }
    }
    
    public func getScanColor() -> UIColor {
        
        let RGBA = RGBAs.removeFirst()
        
        // get color
        let r = RGBA.r
        let g = RGBA.g
        let b = RGBA.b
        let a = RGBA.a
        
        let x = RGBA.location % Int(image.size.width)
        let y = RGBA.location / Int(image.size.width)
        
        let color = UIColor(red: r, green: g, blue: b, alpha: a)
        
//        let y = (pixelLocation / 4) / Int(self.image.size.width)
//        let x = (pixelLocation / 4) % Int(self.image.size.width)
        
        if let pickedSingleColor = pickedSingleColor {
            pickedSingleColor(color, x, y )
        }
        
        return color
    }
}
