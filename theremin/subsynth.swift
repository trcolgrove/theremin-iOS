//
//  subsynth_model.swift
//  theremin
//
//  Created by Thomas Colgrove on 4/21/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation

enum wave{
    case SINE, TRIANGLE, SAWTOOTH, SQUARE, BRIGHT, IVORY, GLASS, CLAV, BASS_1, BASS_2, DEEP, METALLIC, ORGAN_1, ORGAN_2, BOW_1, BOW_2, BOW_3, STEEL, BRASS_1, BRASS_2, SAX, TRUMP, WOOD_1, WOOD_2
}
struct osc{
    var waveform: wave
    var phase_offset: CGFloat
    var volume: CGFloat
    var pitch_offset: Int
    var on: Boolean
}

struct synth_setting{
    var osc1: osc
    var osc2: osc
    var osc3: osc
}
/*
class subsynth{
    init(osc1, osc2, osc3){
        
    }
    
}
*/