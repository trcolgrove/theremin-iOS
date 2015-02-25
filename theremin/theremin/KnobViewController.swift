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
    
    @IBOutlet var reverb_placeholder: UIView!
    @IBOutlet var chorus_placeholder: UIView!
    @IBOutlet var tremolo_placeholder: UIView!
    @IBOutlet var gain_placeholder: UIView!
    
    @IBOutlet var reverb_value: UILabel!
    @IBOutlet var chorus_value: UILabel!
    @IBOutlet var tremolo_value: UILabel!
    @IBOutlet var gain_value: UILabel!
    
    @IBOutlet var valueSlider: UISlider!
    @IBOutlet var animateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reverb_knob = Knob(frame: reverb_placeholder.bounds)
        reverb_knob.addTarget(self, action: "knobValueChanged:", forControlEvents: .ValueChanged)
        reverb_placeholder.addSubview(reverb_knob)
        reverb_knob.value = valueSlider.value
        updateLabel()
    }
    
    func knobValueChanged(knob: Knob) {
        valueSlider.value = knob.value
        
        updateLabel()
    }
    
    @IBAction func sliderValueChanged(slider: UISlider) {
        reverb_knob.value = slider.value
        
        updateLabel()
    }
    
    @IBAction func randomButtonTouched(button: UIButton) {
        let randomValue = Float(arc4random_uniform(101)) / 100.0
        reverb_knob.setValue(randomValue, animated: animateSwitch.on)
        valueSlider.setValue(randomValue, animated: animateSwitch.on)
        
        updateLabel()
    }
    
    func updateLabel() {
        reverb_value.text = NSNumberFormatter.localizedStringFromNumber(reverb_knob.value, numberStyle: .NoStyle)
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