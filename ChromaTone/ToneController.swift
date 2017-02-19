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
    
    public enum Instrument{
        // 뭐 기타 등등등 추가해보자
        case oscillator
        case oscillatorBank
        case drum
        case flute
    }
    
    private struct StaticInstance {
        static var instance: ToneController?
    }
    
    public class func sharedInstance() -> ToneController {
        if StaticInstance.instance == nil {
            StaticInstance.instance = ToneController()
        }
        return StaticInstance.instance!
    }
    private init() {
        
        print("ToneGenerator init")
        self.type = .oscillatorBank
        self.detailType = .square
        
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
                
                // positiveRecerseSawe
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
    
    var isPlaying: Bool = false
    
    
    
    // 기준 : A4.
    var memory : MIDINoteNumber = 0
    
    public func play(color: UIColor) {
        
        switch self.type {
            
        case .oscillator:
            let tone = AudioKit.output as! AKOscillator
            tone.frequency = color.color2soundSimple()
            
            if !isPlaying{
                print("Playing")
                tone.amplitude = 1
                tone.play()
            }
            
        case .oscillatorBank:
            
            let midiNumber = color.color2midiNumberSimple()
            
            if memory == midiNumber && isPlaying{
                return
            }else {
                let tone = AudioKit.output as! AKOscillatorBank
                tone.play(noteNumber: midiNumber, velocity: 255)
                tone.stop(noteNumber: memory)
                memory = midiNumber
            }
            
        default:
            print("play default")
        }
        self.isPlaying = true
        
    }
    
    public func stop() {
        
        print("tone stop")
        switch self.type {
        case .oscillator:
            let tone = AudioKit.output as! AKOscillator
            tone.amplitude = 0
            
        case .oscillatorBank:
            let tone = AudioKit.output as! AKOscillatorBank
            tone.stop(noteNumber: memory)
            memory = 0
        default:
            print("stop default")
        }
        
        self.isPlaying = false
        
    }
    
    public func stopAll() {
        switch self.type {
            
        case .oscillator:
            let tone = AudioKit.output as! AKOscillator
            tone.stop()
            
        case .oscillatorBank:
            let tone = AudioKit.output as! AKOscillatorBank
            
            for midiNumber in 0...255 {
                tone.stop(noteNumber: MIDINoteNumber(midiNumber))
            }
            
        default:
            print("stop default")
        }
        self.isPlaying = false
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
    func color2sound() -> Double{
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        
        let result = self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        
        if result {
            let hue = Double(hue)
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
            let hue = Double(hue)
            let frequency = 220 *  pow(2, hue*2)
            let formattedFrequency = String(format: "%.2f", frequency)
            print("frequency : \(formattedFrequency)Hz")
            print("brightness : \(brightness)")
            return frequency
            
        }
        // 기본음 A (라)
        return 440
    }
    
    
    // midi = 69 + 12 * { log( freq / 440) / log(2) }
    func color2midiNumberSimple() -> MIDINoteNumber {
        return MIDINoteNumber ( 69 + ( 12 * log2( self.color2soundSimple() / 440) ) )
    }
}
