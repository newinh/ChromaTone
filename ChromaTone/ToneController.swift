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
            let drum : Bool = UserDefaults.standard.bool(forKey: Constants.keys["Drum"]!)
            
            let type = ToneController.Instrument(rawValue: instrumentRawValue)!
            let detailType = AKTableType.init(rawValue: detailTypeRawValue)!
            StaticInstance.instance = ToneController(type: type, detailType: detailType)
            StaticInstance.instance?.drumToggle = drum
        }
        
        return StaticInstance.instance!
    }
    
    public enum Instrument: String{
        // 뭐 기타 등등등 추가해보자
        case oscillatorBank = "OscillatorBank"
        case piano = "Piano"
        case guitarAcoustic = "Acoustic Guitar"
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
    
    var preparedPorts : Set<AVAudioSessionPortDescription> = []
    
    var oscillatorSine : AKOscillatorBank!
    var oscillatorTriangle : AKOscillatorBank!
    var oscillatorSquare : AKOscillatorBank!
    var oscillatorSawtooth : AKOscillatorBank!
    
    var mainOscillator : AKOscillatorBank!
    
    var mainMixer = AKMixer()
    var melodyMixer = AKMixer()
    var fmMixer = AKMixer()
    
    var kick = AKSynthKick()
    var snare = AKSynthSnare()
    var hiHat = AKSampler()
    
    var melody : [AKSampler] = []
    
    var pianoFM = AKSampler()
    var guitarAcuostic = AKSampler()
    
    var aChromaOff : Bool = false
    var drumToggle : Bool = false
    
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
        
        print("PLAY MELODY")
        
        let soundInfo = color.color2sound()
        let MIDINumber = MIDINoteNumber( soundInfo.frequency.frequencyToMIDINote() )
        var MIDIVolume : MIDIVelocity
        
        print("MIDINoteNumber : \(MIDINumber)")
        
        if let volume = volume {
            MIDIVolume = MIDIVelocity((volume * 255 )  / 100 )
        }else {
            MIDIVolume = MIDIVelocity ((soundInfo.volume * 255 )  / 100 )
        }
        
        
        switch self.type {
            
        case .oscillatorBank:
            
            
            if memory == MIDINumber {
                mainOscillator.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                return
            }else {
                
                mainOscillator.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                mainOscillator.stop(noteNumber: memory)
                memory = MIDINumber
            }
            
        case .piano:
            let index : Int = Int(MIDINumber) - Constants.minimumPianoMIDINoteNumber

            if let staccato = staccato, staccato == true {
                
                melody[index].play(velocity : MIDIVolume)
                
            }else if memory == MIDINumber {
                break
            }else {
                melody[index].play(velocity : MIDIVolume)
                memory = MIDINumber
            }

            
        case .pianoFM:
            pianoFM.play(noteNumber: MIDINumber, velocity: MIDIVolume)
            
        case .guitarAcoustic:
            guitarAcuostic.play(noteNumber: MIDINumber, velocity: MIDIVolume)
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
        }
        
        
    }
    
    public func playKick(_ velocity : MIDIVelocity = 255) {
        if drumToggle {
            kick.play(noteNumber: 60, velocity: velocity)
        }
        
    }
    
    public func playSnare(_ velocity : MIDIVelocity = 255) {
        if drumToggle{
            snare.play(noteNumber: 60, velocity: velocity)
        }
        
    }
    
    public func playHiHat(_ velocity : MIDIVelocity = 255) {
        if drumToggle {
            hiHat.play(noteNumber: 60, velocity: velocity)
        }
        
    }
    
}
