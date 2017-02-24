//
//  ImagePlayer.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 19..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit
import AudioKit

public class ImagePlayer {
    
    let image : UIImage
    
    // pixel 하나 고를 때 마다 표현할 UI
    var pickedSingleColor : ( (UIColor, _ x : Int, _ y : Int )  -> Void )?
    var pickedScanColor : ( (UIColor, _ x : Int, _ y : Int ,_ option: Option, _ count: Int)  -> Void )?
    // 동작이 끝났을 때 표현할 UI
    var completionHandler: ( (Void) -> Void )?
    
    var timer : Timer?
    

    /// TODO : Customizable
    public struct Option {
        var bpm : TimeInterval = 100
        var timePerBeat : Int = 4    /// 1비트당 박자
        var noteCount : Int = 0
        var playMode : PlayMode = .verticalScanBar
        var scanSampleNumber : Int = 10 /// 1번에 scanBar 가져올 샘플 수
        var staccato : Bool = false
        
        var scanUnit: Int {     /// Random하게 재생할 때는 noteCount 수 만큼 재생하는데 , Scan으로 재생할 때도 맞추자.
            get {
                return noteCount
            }
        }
        
        enum PlayMode : String{
            case random = "Random"
            case verticalScanBar = "Vertical ScanBar"
            case horizontalScanBar = "Horizontal ScanBar"
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
    /// New step 1. prepare         ->  배열 준비
    /// New step 2. getColor        ->  배열에서 색 생성
    /// New step 3. performImage    ->  타이밍 맞춰 색 반환(음 재생)
    
    var i = 0
    
    let pixelData : CFData?
    let data : UnsafePointer<UInt8>
    
    // 새로운 음악을 만들자
    public func prepare() {
        
        print("ImagePlayer prepare")

        switch self.option.playMode {
        case .random:
            self.prepareRandomPixel()
        default:
            self.prepareScan()
        }
        
        
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
        colorMemory = UIColor.clear
        
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
    
    
    /// step1 random version
    
    var pixelLocations : [Int] = []
    public func prepareRandomPixel() {
        
        let lastPixelLocation = Int(self.image.size.width) * Int(self.image.size.height)
        
        // lastPixelLocation 이 2^32승을 넘어 가면 gg
        // 즉, 이미지 크기가 2^32 보다 크면 안된다...
        // 2^16 = 65,536
        for _ in 0 ..< self.option.noteCount {
            let rand = arc4random_uniform(UInt32(lastPixelLocation))
            self.pixelLocations.append( Int(rand) )
        }
        
    }

    /// step 1 scan version
    var colorPieces : [(r: CGFloat,g: CGFloat, b: CGFloat, a: CGFloat, location : Int )] = []
    private func prepareScan() {
        print("\(self.image.size.debugDescription)")
        
        let sampleNumber = CGFloat(option.scanSampleNumber)
        print(sampleNumber)
        
        /// 이미지를 샘플 수로 쪼갬
        var widthUnit : Int = 0
        var heightUnit : Int = 0
        
        var wr : Int = 0
        var hr : Int = 0
        
        var dwr : Double = 0
        var dhr : Double = 0
        
        if option.playMode == .verticalScanBar {
            
            widthUnit = Int( image.size.width) / option.scanUnit
            
            
            heightUnit = Int( image.size.height) / option.scanSampleNumber
            
            wr = Int( image.size.width) % option.scanUnit
            hr = Int( image.size.height) % option.scanSampleNumber
            dwr = Double(wr) / Double(option.scanUnit)
            dhr = Double(hr) / Double(option.scanSampleNumber)
            
        }else if option.playMode == .horizontalScanBar{
            widthUnit = Int( image.size.width / sampleNumber )
            heightUnit = Int (image.size.height / CGFloat(option.scanUnit) )
            
            wr = Int( image.size.width) % option.scanSampleNumber
            hr = Int( image.size.height) % option.scanUnit
            dwr = Double(wr) / Double(option.scanSampleNumber)
            dhr = Double(hr) / Double(option.scanUnit)
            
        }else {
            print("ImagePlayer.prepareScan() : Error")
        }
        
        print("widthUnit : \(widthUnit)")
        print("heightUnit : \(heightUnit)")
        
        let fwr = dwr
        let fhr = dhr
        
        for later in 0..<option.scanUnit {
            
            for faster in 0..<option.scanSampleNumber {
                
                var pixelLocation : Int = 0
                
                switch option.playMode {
                case .verticalScanBar:
                    pixelLocation =  faster * ( heightUnit ) * Int(self.image.size.width) + ( later * (widthUnit ) )
                    
//                    print ("pixelLocation : \(pixelLocation)")
//                    print ("x : \(pixelLocation % Int(self.image.size.width)) , y : \(pixelLocation / Int(self.image.size.width))")
                    
                    dwr += fwr
                    dhr += fhr
                    
                    if dwr > 1 {
                        pixelLocation += 1 * later
                        dwr -= 1
                    }
                    
                    if dhr > 1 {
                        pixelLocation += 1 * Int(self.image.size.width) * faster
                        dhr -= 1
                    }
                    
                    
                case .horizontalScanBar:
                    pixelLocation = ( later * heightUnit * Int(self.image.size.width) + ( faster * widthUnit ) )
                    
                    dwr += fwr
                    dhr += fhr
                    
                    if dwr > 1 {
                        pixelLocation += 1 * faster
                        dwr -= 1
                    }
                    
                    if dhr > 1 {
                        pixelLocation += 1 * Int(self.image.size.width) * later
                        dhr -= 1
                    }
                    
                default:
                    print("ImagePlayer.prepareScan() : 아무것도 안하고싶어...")
                    return
                }
                
                let pixelLocationPointer = pixelLocation * 4
                let r = CGFloat(data[pixelLocationPointer]) / CGFloat(255.0)
                let g = CGFloat(data[pixelLocationPointer+1]) / CGFloat(255.0)
                let b = CGFloat(data[pixelLocationPointer+2]) / CGFloat(255.0)
                let a = CGFloat(data[pixelLocationPointer+3]) / CGFloat(255.0)
                
                colorPieces.append( ( r, g, b, a, pixelLocation) )
                
            }
            
        }
    }
    
    
    
    var colorMemory : UIColor = UIColor.clear
    var count = 0
    /// step3
    @objc public func performImage() {  /// 한박자
        
        
        if pixelLocations.isEmpty && colorPieces.isEmpty {
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
        
        
        // 무채색
//        let achroma = info.frequency < 220
//        let rand = arc4random_uniform(2) == 0

        if onFirstBeat {
            ToneController.sharedInstance().playKick()
        }else if everyOtherBeat || oddBeat {
            ToneController.sharedInstance().playSnare()
        }
        
//        for (_, color) in fetchColor().enumerated() {
//            ToneController.sharedInstance().playMelody(color: color, staccato: true)
//        }
        let color = fetchColor().first!
        colorMemory = color
        ToneController.sharedInstance().playMelody(color: color, staccato: option.staccato)
        
        
        ToneController.sharedInstance().playHiHat(50)
        
    }
    
    /// step2
    // pixelLocations 에서 pixel 하나 꺼내와서 `색`으로 바꿈!
    public func fetchColor() -> [UIColor]{
        
        var colors : [UIColor] = []
        
        switch self.option.playMode {
            case .random:
                
            let pixelLocation = pixelLocations.removeFirst() * 4
            
            // get color
            let r = CGFloat(data[pixelLocation]) / CGFloat(255.0)
            let g = CGFloat(data[pixelLocation+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelLocation+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelLocation+3]) / CGFloat(255.0)
            
            colors.append(UIColor(red: r, green: g, blue: b, alpha: a))
            
            let y = (pixelLocation / 4) / Int(self.image.size.width)
            let x = (pixelLocation / 4) % Int(self.image.size.width)
            
            if let pickedSingleColor = pickedSingleColor, let color = colors.first  {
                pickedSingleColor(color, x, y )
            }
           
        case .horizontalScanBar , .verticalScanBar:
            
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            var a : CGFloat = 0
            
            // 화면에서 없애자...
            var x: Int = -100
            var y :Int = -100
            
            var color = UIColor.clear
            for _ in 0 ..< option.scanSampleNumber {
                let colorPiece = colorPieces.removeFirst()
                
                r = colorPiece.r
                g = colorPiece.g
                b = colorPiece.b
                a = colorPiece.a
                
                let newColor = UIColor(red: r, green: g, blue: b, alpha: a)
                
                if newColor > color {
                        
                    if option.staccato {
                        
                        
                        if newColor.color2sound().frequency.frequency2midiNumber() != colorMemory.color2sound().frequency.frequency2midiNumber(){
                            
                            color = newColor
                            x = colorPiece.location % Int(image.size.width)
                            y = colorPiece.location / Int(image.size.width)
                            colors.append(newColor)
                        }
                        
                        
                    }else {
                        color = newColor
                        x = colorPiece.location % Int(image.size.width)
                        y = colorPiece.location / Int(image.size.width)
                        colors.append(newColor)
                    }
                }
            }
            colors.append(color)
            colors.sort(by: { $0 > $1 })
            
//            let reducedColor = colors.reduce(UIColor.clear, { (origin, new) in
//            
//                if option.staccato {
//                    
//                    if origin > new && origin.color2soundTwo().frequency.frequency2midiNumber() != colorMemory.color2soundTwo().frequency.frequency2midiNumber(){
//                        return origin
//                    }else {
//                        return new
//                    }
//                    
//                }else {
//                    return origin > new ? origin : new
//                }
//                
//                }
//            )
//            
//            colors.removeAll()
//            colors.append(reducedColor)
            
            if let pickedSingleColor = pickedSingleColor , let pickedScanColor = pickedScanColor, let color = colors.first {
                pickedSingleColor(color, x, y)
                pickedScanColor(color, x, y, self.option, self.count)
            }
            return colors
            
        }
        
        return colors
    }
}

extension ImagePlayer {
    public static func getOption() -> ImagePlayer.Option {
        
        let bpm = UserDefaults.standard.double(forKey: Constants.keys["BPM"]!)
        let timerPerBeat = UserDefaults.standard.integer(forKey: Constants.keys["Time"]!)
        let noteCount = UserDefaults.standard.integer(forKey: Constants.keys["Note Count"]!)
        let playModeRawValue = UserDefaults.standard.string(forKey: Constants.keys["Play Mode"]!)!
        let playMode = ImagePlayer.Option.PlayMode(rawValue: playModeRawValue)!
        let scanSampleNumber = UserDefaults.standard.integer(forKey: Constants.keys["Number Of Sample"]!)
        let staccato = UserDefaults.standard.bool(forKey: Constants.keys["Staccato"]!)
        
        return ImagePlayer.Option(bpm: bpm, timePerBeat: timerPerBeat, noteCount: noteCount, playMode: playMode, scanSampleNumber: scanSampleNumber, staccato: staccato)
    }
}

extension UIColor : Comparable {
    static public func < (lhs: UIColor , rhs : UIColor) -> Bool {
        
        var lSaturation : CGFloat = 0
        var lBrightness : CGFloat = 0
        
        var rSaturation : CGFloat = 0
        var rBrightness : CGFloat = 0
        
        lhs.getHue(nil, saturation: &lSaturation, brightness: &lBrightness, alpha: nil)
        rhs.getHue(nil, saturation: &rSaturation, brightness: &rBrightness, alpha: nil)
        
        
        
        return (lSaturation < rSaturation) && (lBrightness < rBrightness)
    }
}
