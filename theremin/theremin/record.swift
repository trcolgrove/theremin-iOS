//
//  record.swift
//  theremin
//
//  Created by Thomas Colgrove on 3/15/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation


class record: recordingProtocol{
    
    var samples : [recData.sample]
    var timer : NSTimer
    var beginTime : NSDate
    
  

    init(){
        samples = []
        timer = NSTimer()
        beginTime = NSDate()
    }
    

    func doneRecording() -> [recData.sample]{
        return samples
    }

    func recordNote(pt: CGPoint, command: recData.command, note_index: Int) {
        let new_sample = recData.sample(elapsed_time: -(beginTime.timeIntervalSinceNow) , note_loc: pt, cmd: command, note_index : note_index)
        samples.append(new_sample)
        
    }
    
}