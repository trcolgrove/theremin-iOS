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
    
    var reverb_knob: Knob!
    var chorus_knob: Knob!
    var tremolo_knob: Knob!
    var gain_knob: Knob!
    
    @IBOutlet var reverb_placeholder: UIView!
    @IBOutlet var chorus_placeholder: UIView!
    @IBOutlet var tremolo_placeholder: UIView!
    @IBOutlet var gain_placeholder: UIView!
    
    @IBOutlet var reverb_value: UILabel!
    @IBOutlet var chorus_value: UILabel!
    @IBOutlet var tremolo_value: UILabel!
    @IBOutlet var gain_value: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reverb_knob = Knob(frame: reverb_placeholder.bounds)
        chorus_knob = Knob(frame: chorus_placeholder.bounds)
        tremolo_knob = Knob(frame: tremolo_placeholder.bounds)
        gain_knob = Knob(frame: gain_placeholder.bounds)
        initializeKnob(reverb_knob, placeholder: reverb_placeholder, value: reverb)
        initializeKnob(chorus_knob, placeholder: chorus_placeholder, value: chorus)
        initializeKnob(tremolo_knob, placeholder: tremolo_placeholder, value: tremolo)
        initializeKnob(gain_knob, placeholder: gain_placeholder, value: gain)
        updateLabel(reverb_knob, label: reverb_value)
        updateLabel(chorus_knob, label: chorus_value)
        updateLabel(tremolo_knob, label: tremolo_value)
        updateLabel(gain_knob, label: gain_value)
    }
    
    func initializeKnob(knob: Knob!, placeholder: UIView!, value: Float) {
        knob.addTarget(self, action: "knobValueChanged:", forControlEvents: .ValueChanged)
        placeholder.addSubview(knob)
        knob.value = value
    }
    
    func knobValueChanged(knob: Knob) {
        //var knob_label =
        updateLabel(reverb_knob, label: reverb_value)
        updateLabel(chorus_knob, label: chorus_value)
        updateLabel(tremolo_knob, label: tremolo_value)
        updateLabel(gain_knob, label: gain_value)
    }
    
    @IBAction func randomButtonTouched(button: UIButton) {
        let randomValue = Float(arc4random_uniform(101)) / 100.0
        reverb_knob.setValue(randomValue, animated: false)
        
        updateLabel(reverb_knob, label: reverb_value)
        updateLabel(chorus_knob, label: chorus_value)
        updateLabel(tremolo_knob, label: tremolo_value)
        updateLabel(gain_knob, label: gain_value)
    }
    
    func updateLabel(knob: Knob!, label: UILabel) {
        label.text = NSNumberFormatter.localizedStringFromNumber(knob.value, numberStyle: .NoStyle)
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