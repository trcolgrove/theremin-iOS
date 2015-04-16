//
//  looper.swift
//  theremin
//
//  Created by Thomas Colgrove on 4/16/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

/*
import Foundation

class looper{
    private var samples: [recData.sample] = []
    var num_measures : Int = 0
    var BPM : Int = 0
    var time_sig : time_signature = time_signature(numerator: 4, denominator: 4)
    
    struct time_signature{
        var numerator : Int
        var denominator : Int
    }
    
    init(initSamples: [recData.sample], tempo : Int, time : time_signature){
        samples = initSamples
        BPM = tempo
        time_sig = time
    }
    
    func addSamples(newRecording : [recData.sample]){
        samples = samples + newRecording
        samples.sort({(s1: recData.sample , s2: recData.sample) -> Bool in return (s1.elapsed_time > s2.elapsed_time)
        })
    }
    
    
    func setTempo(tempo : Int){
        BPM = tempo
    }


    private func setMeasureNumber(){
        var total_time : NSTimeInterval = samples.last!.elapsed_time
        let MeasuresPerSecond : CGFloat = (CGFloat(BPM)/CGFloat(time_sig.numerator))/60
        num_measures = Int(MeasuresPerSecond * CGFloat(total_time))
        let endTime : NSTimeInterval = NSTimeInterval(num_measures) / NSTimeInterval(MeasuresPerSecond)
        
        //truncate sample array to fit within bounds of num_measures
        var index : Int = samples.count - 1
        while(samples[index].elapsed_time > endTime && index >= 0) {
            samples.removeAtIndex(index)
            index--
        }
    }
    
}

*/