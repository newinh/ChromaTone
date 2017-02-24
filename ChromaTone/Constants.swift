//
//  Constants.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 11..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation

struct Constants {
    static let colorPickerImage : String = "demo_color_wheel"
    static let playIcon : String = "icon_play"
    static let pauseIcon : String = "icon_pause"
    
    static let kick: String = "Bass-Drum-1"
    static let snare: String = "Hip-Hop-Snare-2"
    static let hiHat: String = "Hi-Hat-1"
    
    static let minimumPianoMIDINoteNumber : Int = 56
    static let maximumPianoMIDINoteNumber : Int = 81
    
    static let keys : [String : String ] = [
        
        "Instrument" : "Tone Instrument Type Key",
        "Detail" : "Tone Instrument DetailType Key",
        "BPM" : "ImagePlayer Option BPM Key",
        "Time" : "ImagePlayer Option TimerPerBeat Key",
        "Note Count" : "ImagePlayer Option NoteCount Key",
        "Play Mode" : "ImagePlayer Option PlayMode Key",
        "Number Of Sample" : "ImagePlayer Option Scan Sample Number Key" ,
        "Staccato" : "ImagePlayer Option Staccato Key",
        
        ]
    
    
    
    static let instrument : [String] = [
        ToneController.Instrument.oscillator.rawValue,
        ToneController.Instrument.oscillatorBank.rawValue,
        ToneController.Instrument.piano.rawValue,
        ToneController.Instrument.pianoFM.rawValue
    ]
    
    static let detail : [String] = [
        ToneController.Instrument.DetailType.sine.rawValue,
        ToneController.Instrument.DetailType.triangle.rawValue,
        ToneController.Instrument.DetailType.square.rawValue,
        ToneController.Instrument.DetailType.sawtooth.rawValue,
        ToneController.Instrument.DetailType.reverseSawtooth.rawValue,
        ToneController.Instrument.DetailType.positiveSine.rawValue,
        ToneController.Instrument.DetailType.positiveTriangle.rawValue,
        ToneController.Instrument.DetailType.positiveSquare.rawValue,
        ToneController.Instrument.DetailType.positiveSawtooth.rawValue,
        ToneController.Instrument.DetailType.reverseSawtooth.rawValue,
    ]
    
    static let toneController : [ String : [String] ] = [
//        "Tone" : [],
        "Instrument" : instrument,
        "Detail" : detail
    ]
    
    static let playMode : [String] = [
        ImagePlayer.Option.PlayMode.random.rawValue,
        ImagePlayer.Option.PlayMode.horizontalScanBar.rawValue,
        ImagePlayer.Option.PlayMode.verticalScanBar.rawValue,
    ]
    
    
    
    static let imagePlayer : [ String : Any ] = [
        
//        "Image Player" : "",
        "BPM" : 50...150,
        "Time" : 2...4,
        "Note Count" : 10...200,
        "Play Mode" : playMode,
        "Number Of Sample" : 5...25 ,
        "Staccato" : [true, false]
        ]
    
    static let options : [ String : [String : Any] ] = [
        "Tone " : toneController,
        "Image Player" : imagePlayer
    ]
}

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[ index(startIndex, offsetBy: i) ]
        }
    }
}

