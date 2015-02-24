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
    func setRange(num_semitones:Int)
}

class RangeViewContainerController: InstrumentViewController, RangeSlideParentDelegate{
    
    var leftmost_note: Int = 60
    var touch_origin: CGFloat = 0
    var instrument: InstrumentViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
    }
    
    override func setRange(num_semitones: Int)
    {
        leftmost_note += num_semitones
        instrument.setRange(leftmost_note)
    }
    
    override func updateKey(key: String, notes: [String]) {
        self.key = key
        println(notes)
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        println("Range Container is loaded");
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "init_slider"{
            let range_control = segue.destinationViewController as RangeSlideController
            range_control.container_delegate = self
            println("Container Delegation Set")
        }
    }
    //implement later
    /*
    @IBAction func handleSwipe(recognizer: UISwipeGestureRecognizer) {
    
    }
    */
    
    
}
