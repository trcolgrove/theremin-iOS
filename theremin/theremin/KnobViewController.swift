//
//  KnobViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/5/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class KnobViewController: InstrumentViewController {
    
    var reverb: Float = 0
    var chorus: Float = 0
    var tremolo: Float = 0
    var gain: Float = 0
    
    override func viewDidLoad() {
        println("Knob View Controller is loaded")
    }
    
    @IBAction func changeReverb (sender: UIButton) {
        println("Changing " + sender.titleLabel!.text!)
    }
    
    func updateEffect (effect: String, new_value: Float) {
        
        switch effect{
        case "reverb":
            reverb = new_value
            PdBase.sendFloat(new_value, toReceiver: "reverb")
        case "chorus":
            chorus = new_value
            PdBase.sendFloat(new_value, toReceiver: "chorus")
        case "tremolo":
            tremolo = new_value
            PdBase.sendFloat(new_value, toReceiver: "tremolo")
        case "gain":
            gain = new_value
            PdBase.sendFloat(new_value, toReceiver: "gain")
        default:
            println("Not an option to change")
        }
        
    }
    
}