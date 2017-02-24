//
//  UIColor+frequency.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 24..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit
import AudioKit

// midi = 69 + 12 * { log( freq / 440) / log(2) }
// A3 (라) / 220Hz / 57
extension Double {
    func frequency2midiNumber() -> MIDINoteNumber {
        return MIDINoteNumber ( 69 + ( 12 * log2( self / 440) ) )
    }
}

extension UIColor {
    
    // 220Hz ~ 880Hz / A3 ~ A5
    func color2sound() -> (frequency: Double, volume: Int){
        
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
//            if saturation + brightness < 100 {
            
                // 가장 낮은 음 발생
//                print("무채색.. , MIDINoteNumber : \(219.frequencyToMIDINote())")
//                //                return (219, (Int(saturation) / 10) * 10 )
//                return (220, Int(saturation) )
            
//            }else {
            
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
                
//            }
            
        }
        // 기본음 A (라)
        print("color2soundTest : 변환 실패")
        return (440, 0)
    }
    
    
    
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
}
