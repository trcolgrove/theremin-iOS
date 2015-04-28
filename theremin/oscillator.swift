//
//  oscilllator.swift
//  theremin
//
//  Created by Thomas Colgrove on 4/21/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
class oscillator{
    
    enum wave{
        case SINE, TRIANGLE, SAWTOOTH, SQUARE, BRIGHT, IVORY, GLASS, CLAV, BASS_1, BASS_2, DEEP, METALLIC, ORGAN_1, ORGAN_2, BOW_1, BOW_2, BOW_3, STEEL, BRASS_1, BRASS_2, SAX, TRUMP, WOOD_1, WOOD_2
    }
    
    var waveform: wave
    var phase_offset: CGFloat
    var volume: CGFloat
    var pitch_offset: Int
    var on: Boolean
    
    
    init(wave: oscillator.wave, phase: CGFloat, vol: CGFloat, pitch: Int, isOn: Boolean){
        waveform = wave
        phase_offset = phase
        volume = vol
        pitch_offset = pitch
        on = isOn
    }
    
}