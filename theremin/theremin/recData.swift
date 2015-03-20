//
//  recData.swift
//  theremin
//
//  Created by Thomas Colgrove on 3/19/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation

class recData{
    
    enum command {
        case ON
        case OFF
        case HOLD //triggered while user is still pressing down
        case SUS //triggered by double tap sustain
    }
    
    struct sample{
        var elapsed_time: NSTimeInterval
        var note_loc: CGPoint
        var cmd: command
    }
    
}