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
        
        case piano
        case pianoFM
        
        case drum
        case flute
    }
    private init() {
        
        print("ToneGenerator init")
        self.type = .piano
        self.detailType = .sine
        
        /* 괜찮은 타입들
         oscillatorBank - positiveReverseSaw 포켓몬
         oscillatorBank - sine
         */

        try! hiHat.loadWav(Constants.hiHat)
        
        for i in 56...81 {
            let file = try! AKAudioFile(readFileName: "piano-\(i).wav")
            melody.append(try! AKAudioPlayer(file: file)) 
        }
        
        for i in 56...81 {
            melody2.append(AKSampler())
            try! melody2[i-56].loadWav("piano-\(i)")
        }
        
        try! pianoFM.loadWav("FM-Piano")
    }
    
    public var detailType : AKTableType {
        didSet{
            let type = self.type
            self.type = type // type의 willSet을 부르자!
        }
    }
    
    var oscillatorBank : AKOscillatorBank!
    var oscillator : AKOscillator!
    var mixer = AKMixer()
    
    var mixer2 = AKMixer()
    
    let kick = AKSynthKick()
    let snare = AKSynthSnare()
    let hiHat = AKSampler()
    
    var melody : [AKAudioPlayer] = []
    
    /// TODO : Sampler
    var melody2 : [AKSampler] = []
    
    var pianoFM = AKSampler()
    
    public var type : Instrument {
        
        didSet {
            print("TonController type didSet")
            
            mixer = AKMixer()
            mixer.connect(kick)
            mixer.connect(snare)
            mixer.connect(hiHat)
            
            
            switch type {
                
            case .oscillator:
                oscillator = AKOscillator(waveform: AKTable(self.detailType))
                
                oscillator.amplitude = 0
                oscillator.play()
                mixer.connect(oscillator)
                
            case .oscillatorBank:
                oscillatorBank = AKOscillatorBank(waveform: AKTable(self.detailType),
                                            attackDuration: 0.01,
                                            releaseDuration: 0.01)
                mixer.connect(oscillatorBank!)
                
            case .piano:
                
                for (i, node) in melody.enumerated() {
                    mixer.connect(node)
                }
                
                for (i, node) in melody2.enumerated() {
                    mixer2.connect(node)
                }
                mixer.connect(mixer2)
                
            case .pianoFM :
                
                var delay  = AKDelay(pianoFM)
//                delay.time = pulse * 1.5
                delay.dryWetMix = 0.3
                delay.feedback = 0.2
                
                let reverb = AKReverb(delay)
                reverb.loadFactoryPreset(.largeRoom)
                let mix = AKMixer(reverb)
                mix.volume = 5.0
                mixer.connect(mix)
                
            default :
                print("default")
            }
            defer{
                AudioKit.output = mixer
                AudioKit.start()
            }
        }
    }
    
//    var isPlaying: Bool = false
    
    
    
    // 기준 : A4.
    var memory : MIDINoteNumber = 0
    
    
    // Volum : 0 ~ 100 사이로 받자.
    // 특정한 볼륨 재생
    public func playMelody(color: UIColor , volume: Int? = nil, interval : Double? = nil) {
        
        let soundInfo = color.color2soundTwo()
        
        switch self.type {
            
        case .oscillator:
            oscillator.frequency = soundInfo.frequency
            oscillator.play()
            
            if let volume = volume {
                oscillator.amplitude = Double(volume) / 100
            }else {
                oscillator.amplitude = Double(soundInfo.volume) / 100
            }
            
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
                oscillatorBank.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                return
            }else {
                
                oscillatorBank.play(noteNumber: MIDINumber, velocity: MIDIVolume )
                oscillatorBank.stop(noteNumber: memory)
                memory = MIDINumber
            }
            
        case .piano:
            let MIDINumber = MIDINoteNumber( soundInfo.frequency.frequency2midiNumber() )
//            var MIDIVolume : MIDIVelocity
            let index : Int = Int(MIDINumber) - 56
            
            
            if melody[index].isPlaying {
                print("ToneController.play : 이미 연주중")
                return
            }

            
            if let interval = interval {
                melody[index].play(from: 0, to: interval)
                
                // 화성 테스트
                if index > 3 {
                    melody[index-4].play(from: 0, to: interval)
                }
                
            }else {
              melody[index].play()
                if index > 3 {
                    melody[index-4].play()
                }
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
            
            
        default:
            print("play default")
        }
        
    }
    
    
    
    public func stop() {
        
        print("tone stop")
        switch self.type {
        case .oscillator:
            oscillator.amplitude = 0
            
        case .oscillatorBank:
            oscillatorBank.stop(noteNumber: memory)
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
