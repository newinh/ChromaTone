//
//  Tone.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 19..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import AudioKit
import UIKit

public class ToneController {
    
    private struct StaticInstance {
        static var instance: ToneController?
    }
    
    public class func sharedInstance() -> ToneController {
        if StaticInstance.instance == nil {
            StaticInstance.instance = ToneController()
        }
        return StaticInstance.instance!
    }
    
    /// Todo: Customize!
    public enum Instrument{
        // 뭐 기타 등등등 추가해보자
        case oscillator
        case oscillatorBank
        case drum
        case flute
    }
    private init() {
        
        print("ToneGenerator init")
        self.type = .oscillatorBank
        self.detailType = .sine
        
        /* 괜찮은 타입들
         oscillatorBank - positiveReverseSaw 포켓몬
         oscillatorBank - sine
         */
    }
    
    public var detailType : AKTableType {
        didSet{
            let type = self.type
            self.type = type // type의 willSet을 부르자!
        }
    }
    
    public var type : Instrument {
        
        didSet {
            print("Type will Set")
            switch type {
                
            case .oscillator:
                let tone = AKOscillator(waveform: AKTable(self.detailType))
                AudioKit.output = tone
                tone.amplitude = 0
                tone.play()
                
            case .oscillatorBank:
                let tone = AKOscillatorBank(waveform: AKTable(self.detailType),
                                            attackDuration: 0.01,
                                            releaseDuration: 0.01)
                AudioKit.output = tone
            default :
                print("default")
            }
            defer{
                AudioKit.start()
            }
        }
    }
    
//    var isPlaying: Bool = false
    
    
    
    // 기준 : A4.
    var memory : MIDINoteNumber = 0
    
    
    // Volum : 0 ~ 100 사이로 받자.
    // 특정한 볼륨 재생
    public func play(color: UIColor , volume: Int? = nil) {
        
        switch self.type {
            
        case .oscillator:
            let tone = AudioKit.output as! AKOscillator
            
            let soundInfo = color.color2soundTest()
            
            tone.frequency = soundInfo.frequency
            tone.play()
            
            
            if let volume = volume {
                tone.amplitude = Double(volume) / 100
            }else {
                tone.amplitude = Double(soundInfo.volume) / 100
            }
            
            
        case .oscillatorBank:
            
            let tone = AudioKit.output as! AKOscillatorBank
            
            let soundInfo = color.color2soundTest()
            
            let MIDINumber = MIDINoteNumber( soundInfo.frequency.frequencyToMIDINote() )
            var MIDIVolume : MIDIVelocity
            
            if let volume = volume {
                MIDIVolume = MIDIVelocity((volume * 255 )  / 100 )
            }else {
                MIDIVolume = MIDIVelocity ((soundInfo.volume * 255 )  / 100 )
            }
            
            if memory == MIDINumber {
                tone.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                return
            }else {
                
                tone.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                tone.stop(noteNumber: memory)
                memory = MIDINumber
            }
            
        default:
            print("play default")
        }
        
    }
    
    
    
    public func stop() {
        
        print("tone stop")
        switch self.type {
        case .oscillator:
            let tone = AudioKit.output as! AKOscillator
            tone.amplitude = 0
//            tone.stop()
            
        case .oscillatorBank:
            let tone = AudioKit.output as! AKOscillatorBank
            tone.stop(noteNumber: memory)
            memory = 0
        default:
            print("stop default")
        }
        
        
    }
    
}

// midi = 69 + 12 * { log( freq / 440) / log(2) }
extension Double {
    func frequency2midiNumber() -> MIDINoteNumber {
        return MIDINoteNumber ( 69 + ( 12 * log2( self / 440) ) )
    }
}
extension UIColor {
    
    // frequency = 110 * pow(2, (saturation*2)) * pow(2, hue)
    func color2soundOne() -> Double{
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        
        let result = self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        
        if result {
            var hue : Double {
                get {
                    let hue = Double(hue)
                    if hue < 0.75 {
                        return 0.75 - hue
                    }else {
                        return 1.75 - hue
                    }
                }
            }
            
            let saturation = Double(saturation)
            let frequency = 110 * pow(2,saturation*2) * pow(2, hue)
            
            let formattedFrequency = String(format: "%.2f", frequency)
            print("frequency : \(formattedFrequency)Hz")
            return frequency
            
        }
        // 기본음 A (라)
        return 440
    }
    
    // frequency = 220 *  pow(2, hue*2)
    func color2soundSimple() -> Double {
        var hue: CGFloat = 0
        var brightness : CGFloat = 0
        let result = self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: nil)
        
        if result {
            
            var hue : Double {
                get {
                    let hue = Double(hue)
                    if hue < 0.75 {
                        return 0.75 - hue
                    }else {
                        return 1.75 - hue
                    }
                }
            }
            let frequency = 220 *  pow(2, hue*2)
            let formattedFrequency = String(format: "%.2f", frequency)
            
            print("frequency : \(formattedFrequency)Hz")
            print("hue : \(hue)")
            print("brightness : \(brightness)")
            return frequency
            
        }
        // 기본음 A (라)
        return 440
    }
    
    func color2soundTest() -> (frequency: Double, volume: Int){
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness : CGFloat = 0
        let result = self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        
        if result {
            var hue : Double {
                get {
                    let hue = Double(hue)
                    if hue < 0.75 {
                        return 0.75 - hue
                    }else {
                        return 1.75 - hue
                    }
                }
            }
            // saturation 이 볼륨
            let saturation: Double = min(Double(saturation) * 100, 100)
            let brightness = Double(brightness) * 100
            
            // 거의 무채색이라고보자.
            /// Todo
            if saturation + brightness < 115 {
                
                // 가장 낮은 음 발생
                print("무채색..")
//                return (219, (Int(saturation) / 10) * 10 )
                return (219, Int(saturation) )
                
            }else {
                
                // frequencty : 220 ~ 880
                let frequency = 220 *  pow(2, hue*2)
                let formattedFrequency = String(format: "%.2f", frequency)
                print("frequency : \(formattedFrequency)Hz")
                print("brightness : \(brightness)")
                print("saturation : \(saturation)")
                
//                print("일의 자리 버림 :  \((Int(saturation) / 10) * 10) ")
                // 1의 자리 버림
//                return (frequency, (Int(saturation) / 10) * 10 )
                return (frequency, Int(saturation) )
                
            }
            
        }
        // 기본음 A (라)
        print("color2soundTest : 변환 실패")
        return (440, 0)
    }
}
