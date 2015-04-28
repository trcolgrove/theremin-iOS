//
//  subsynth.swift
//  theremin
//
//  Created by Thomas Colgrove on 4/21/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation


class subsynth{
    var osc1 : oscillator
    var osc2 : oscillator
    var osc3 : oscillator
    
    init(osc1 : oscillator, osc2 : oscillator, osc3: oscillator){
        self.osc1 = osc1
        self.osc2 = osc2
        self.osc3 = osc3
    }
}
