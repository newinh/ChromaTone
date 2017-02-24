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
        
        prepareType()
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
    
    func prepareDrum() {
        
        try! hiHat.loadWav(Constants.hiHat)
        
        mainMixer.connect(kick)
        mainMixer.connect(snare)
        mainMixer.connect(hiHat)
    }
    
    func prepareOscillator(){
        
        
        oscillatorSine = AKOscillatorBank(waveform: AKTable(AKTableType.sine),
                                          attackDuration: 0.01, releaseDuration: 0.01)
        
        oscillatorTriangle = AKOscillatorBank(waveform: AKTable(AKTableType.triangle),
                                          attackDuration: 0.01,releaseDuration: 0.01)
        
        oscillatorSquare = AKOscillatorBank(waveform: AKTable(AKTableType.square),
                                          attackDuration: 0.01, releaseDuration: 0.01)
        
        oscillatorSawtooth = AKOscillatorBank(waveform: AKTable(AKTableType.sawtooth),
                                          attackDuration: 0.01, releaseDuration: 0.01)
        
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
        
        mainMixer.connect(oscillatorSine)
        mainMixer.connect(oscillatorTriangle)
        mainMixer.connect(oscillatorSquare)
        mainMixer.connect(oscillatorSawtooth)
    }
    
    func prepareMelody() {
        
        melody = [AKSampler]()
        melodyMixer = AKMixer()
        
        for i in Constants.minimumPianoMIDINoteNumber...Constants.maximumPianoMIDINoteNumber {
            melody.append(AKSampler())
            try! melody[i-Constants.minimumPianoMIDINoteNumber].loadWav("piano-\(i)")
        }
        
        
        for (_, node) in melody.enumerated() {
            melodyMixer.connect(node)
        }
        melodyMixer.volume = 5
        mainMixer.connect(melodyMixer)

        
        try! pianoFM.loadWav("FM-Piano")
        
        let delay  = AKDelay(pianoFM)
        //        delay.time = pulse * 1.5
        delay.dryWetMix = 0.3
        delay.feedback = 0.2
        
        let reverb = AKReverb(delay)
        reverb.loadFactoryPreset(.largeRoom)
        fmMixer = AKMixer(reverb)
        fmMixer.volume = 5.0
        
        mainMixer.connect(fmMixer)
        
    }
    
    
    
    func prepareType() {
        
        mainMixer = AKMixer()
        
        prepareDrum()
        prepareOscillator()
        prepareMelody()
        
        defer{
            AudioKit.output = mainMixer
            AudioKit.start()
        }
    }
    
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
        
        let soundInfo = color.color2soundTwo()
        
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

// midi = 69 + 12 * { log( freq / 440) / log(2) }
// A3 (라) / 220Hz / 57
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
    
    // 220Hz ~ 880Hz / A3 ~ A5
    func color2soundTwo() -> (frequency: Double, volume: Int){
        
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
            if saturation + brightness < 100 {
                
                // 가장 낮은 음 발생
                print("무채색.. , MIDINoteNumber : \(219.frequencyToMIDINote())")
//                return (219, (Int(saturation) / 10) * 10 )
                return (220, Int(saturation) )
                
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
