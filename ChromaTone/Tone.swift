//
//  Tone.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 19..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import AudioKit

public class Tone {
    
    public enum instument{
        // 뭐 기타 등등등 추가해보자
        case none
        case drum
        case flute
    }
    
    public static let shared = Tone()
    
    
    
    public var type : instument {
        
        willSet {
            switch newValue {
            case .none:
                let tone = AKOscillatorBank(waveform: AKTable(.sine),
                                            attackDuration: 0.02,
                                            releaseDuration: 0.05)
                AudioKit.output = tone
            default :
                print("default")
            }
        }
    }
    
    private init() {
        self.type = .none
    }
    
    // 기준 : A4.
    var memory : MIDINoteNumber = 0
    
    public func play(color: UIColor) {
        
        switch self.type {
        case .none:
            
            let midiNumber = color.color2midiNumberSimple()
            
            if memory == midiNumber {
                return
            }else {
                let tone = AudioKit.output as! AKOscillatorBank
                tone.play(noteNumber: midiNumber, velocity: 80)
                tone.stop(noteNumber: memory)
                memory = midiNumber
            }
            
        default:
            print("play default")
        }
        
    }
    
    public func stop() {
        
        switch self.type {
        case .none:
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
