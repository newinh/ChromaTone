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
            
            let instrumentKey = Constants.keys["Instrument"]!
            let detailKey = Constants.keys["Detail"]!
            let instrumentRawValue : String = UserDefaults.standard.string(forKey: instrumentKey)!
            let detailTypeRawValue : String = UserDefaults.standard.string(forKey: detailKey)!
            
            let type = ToneController.Instrument(rawValue: instrumentRawValue)!
            let detailType = AKTableType.init(rawValue: detailTypeRawValue)!
            StaticInstance.instance = ToneController(type: type, detailType: detailType)
        }
        
        return StaticInstance.instance!
    }
    
    public enum Instrument: String{
        // 뭐 기타 등등등 추가해보자
        case oscillatorBank = "OscillatorBank"
        case piano = "Piano"
        case pianoFM = "PianoFM"
        
    }
    
    
    private init(type : Instrument, detailType : AKTableType) {
        
        print("ToneGenerator init")
        print(type.rawValue)
        print(detailType.rawValue)
        self.type = type
        self.detailType = detailType
        
        prepare()
    }
    
    public var detailType : AKTableType {
        didSet{
            stop()
            
            switch detailType {
            case .sine:
                mainOscillator = oscillatorSine
            case .triangle:
                mainOscillator = oscillatorTriangle
            case .square:
                mainOscillator = oscillatorSquare
            case .sawtooth:
                mainOscillator = oscillatorSawtooth
            default:
                mainOscillator = oscillatorSine
            }
        }
    }
    
    var oscillatorSine : AKOscillatorBank!
    var oscillatorTriangle : AKOscillatorBank!
    var oscillatorSquare : AKOscillatorBank!
    var oscillatorSawtooth : AKOscillatorBank!
    
    var mainOscillator : AKOscillatorBank!
    
    var mainMixer = AKMixer()
    var melodyMixer = AKMixer()
    var fmMixer = AKMixer()
    
    let kick = AKSynthKick()
    let snare = AKSynthSnare()
    let hiHat = AKSampler()
    
    var melody : [AKSampler] = []
    
    var pianoFM = AKSampler()
    
    
    
    public var type : Instrument {
        willSet {
            stop()
        }
    }
    
    // 기준 : A4.
    var memory : MIDINoteNumber = 0
    var volumeMemory : MIDIVelocity = 0
    
    // Volum : 0 ~ 100 사이로 받자.
    // 특정한 음 재생
    public func playMelody(color: UIColor , volume: Int? = nil, staccato : Bool? = nil) {
        
        let soundInfo = color.color2sound()
        
        print("PLAY!!")
        switch self.type {
            
        case .oscillatorBank:
            
            
            let MIDINumber = MIDINoteNumber( soundInfo.frequency.frequencyToMIDINote() )
            var MIDIVolume : MIDIVelocity
            
            if let volume = volume {
                MIDIVolume = MIDIVelocity((volume * 255 )  / 100 )
            }else {
                MIDIVolume = MIDIVelocity ((soundInfo.volume * 255 )  / 100 )
            }
            print("MIDINoteNumber : \(MIDINumber)")
            
            if memory == MIDINumber {
                mainOscillator.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                return
            }else {
                
                mainOscillator.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                mainOscillator.stop(noteNumber: memory)
                memory = MIDINumber
            }
            
        case .piano:
            let MIDINumber = MIDINoteNumber( soundInfo.frequency.frequency2midiNumber() )
            
            var MIDIVolume : MIDIVelocity
            if let volume = volume {
                MIDIVolume = MIDIVelocity((volume * 255 )  / 100 )
            }else {
                MIDIVolume = MIDIVelocity ((soundInfo.volume * 255 )  / 100 )
            }
            let index : Int = Int(MIDINumber) - Constants.minimumPianoMIDINoteNumber

            
            if let staccato = staccato, staccato == true {
                
                print("I'm here")
                
                melody[index].play(velocity : MIDIVolume)
                
                // 화성 test
                if index > 3 {
                    melody[index-4].play(velocity : MIDIVolume)
                }
                
            }else if memory == MIDINumber {
                break
            }else {
                melody[index].play(velocity : MIDIVolume)
                // 화성 test
                if index > 3 {
                    melody[index-4].play(velocity : MIDIVolume)
                }
                memory = MIDINumber
            }

            
        case .pianoFM:
            
            let MIDINumber = MIDINoteNumber( soundInfo.frequency.frequencyToMIDINote() )
            var MIDIVolume : MIDIVelocity
            
            if let volume = volume {
                MIDIVolume = MIDIVelocity((volume * 255 )  / 100 )
            }else {
                MIDIVolume = MIDIVelocity ((soundInfo.volume * 255 )  / 100 )
            }
            print("MIDINoteNumber : \(MIDINumber)")
            
            pianoFM.play(noteNumber: MIDINumber, velocity: MIDIVolume)
            
        }
        
    }
    
    
    
    public func stop() {
        
        print("tone stop")
        
        switch self.type {
            
        case .oscillatorBank:
            mainOscillator.stop(noteNumber: memory)
            memory = 0
            
        default:
            memory = 0
            print("stop default")
        }
        
        
    }
    
    public func playKick(_ velocity : MIDIVelocity = 255) {
        kick.play(noteNumber: 60, velocity: velocity)
    }
    
    public func playSnare(_ velocity : MIDIVelocity = 255) {
        snare.play(noteNumber: 60, velocity: velocity)
    }
    
    public func playHiHat(_ velocity : MIDIVelocity = 255) {
        hiHat.play(noteNumber: 60, velocity: velocity)
    }
    
}
