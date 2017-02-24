//
//  ToneController+prepare.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 24..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import AudioKit

extension ToneController {
    
    func prepare() {
        
        mainMixer = AKMixer()
        prepareDrum()
        prepareOscillator()
        prepareMelody()
        
        defer{
            AudioKit.output = mainMixer
            AudioKit.start()
        }
    }
    
    
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
        
        
        mainMixer.connect(pianoFM)
        
    }
    
    
    
    
}
