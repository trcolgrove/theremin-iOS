//
//  RangeViewContainer.swift
//  theremin
//
//  Created by Thomas Colgrove on 2/16/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

protocol RangeViewInstrument{
    func setRange(num_semitones:CGFloat)
}

class RangeViewContainerController: InstrumentViewController, RangeSlideParentDelegate {
    
    var leftmost_note: CGFloat = 60
    var touch_origin: CGFloat = 0
    var instrument: InstrumentViewController!
    var range_control: RangeSlideController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
    }
    
    override func setRange(num_semitones: CGFloat)
    {
        leftmost_note += num_semitones
        instrument.setRange(num_semitones)
    }
    
    override func updateKey(key: String, notes: [String]) {
        self.key = key
        range_control.updateNoteLabels(key)
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "init_slider"{
            range_control = segue.destinationViewController as! RangeSlideController
            range_control.container_delegate = self
        }
    }
    
    @IBAction func rightOctave(sender: AnyObject) {
        self.range_control.shiftOctave("right")
    }
    
    @IBAction func leftOctave(sender: AnyObject) {
        self.range_control.shiftOctave("left")
    }
   
}
