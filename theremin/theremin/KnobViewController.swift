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
    
    var knobs = [String:Knob]()
    var knob_ids = ["reverb", "chorus", "tremolo", "gain"]
    
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
        initializeKnobs()
        updateLabels()
    }
    
    /** Creates all knobs specified by the knob ids and gives them all the that id **/
    func initializeKnobs() {
        var id = ""
        for (var i = 0; i < knob_ids.count; i++) {
            id = knob_ids[i]
            if let placeholder = getPlaceholder(id) {
                knobs[id] = Knob(frame: placeholder.bounds)
                assignID(knobs[id]!, id: id)
                if let value = getKnobValue(id) {
                    initializeKnob(knobs[id], placeholder: placeholder , value: value)
                }
            }
        }
    }
    
    /** Initializes an individual knob view and value **/
    func initializeKnob(knob: Knob!, placeholder: UIView!, value: Float) {
        knob.addTarget(self, action: "knobValueChanged:", forControlEvents: .ValueChanged)
        placeholder.addSubview(knob)
        knob.value = value
    }
    
    /** Assigns the knob an id based on the function of the knob **/
    func assignID(knob: Knob, id: String) {
        knob.setID(id)
    }
    
    /** Gets the placeholder view based on the id **/
    func getPlaceholder(id: String) -> UIView? {
        switch id {
            case "reverb":
                return reverb_placeholder
            case "chorus":
                return chorus_placeholder
            case "tremolo":
                return tremolo_placeholder
            case "gain":
                return gain_placeholder
            default:
                return nil
        }
    }
    
    /** Gets the knob's value based on the id **/
    func getKnobValue(id: String) -> Float? {
        switch id {
            case "reverb":
                return reverb
            case "chorus":
                return chorus
            case "tremolo":
                return tremolo
            case "gain":
                return gain
            default:
                return nil
        }
    }
    
    /** Gets the knob label based on the id **/
    func getKnobLabel(id: String) -> UILabel? {
        switch id {
            case "reverb":
                return reverb_value
            case "chorus":
                return chorus_value
            case "tremolo":
                return tremolo_value
            case "gain":
                return gain_value
            default:
                return nil
        }
    }
    
    func knobValueChanged(knob: Knob) {
        if let knob_label = getKnobLabel(knob.id) {
            updateLabel(knobs[knob.id], label: knob_label)
            if let cur_value = getKnobValue(knob.id) {
                PdBase.sendFloat(cur_value, toReceiver: knob.id)
            }
        }
    }
    
    func updateKnobValues(randValue: Float) {
        var id = ""
        for (var i = 0; i < knob_ids.count; i++) {
            id = knob_ids[i]
            var current_knob = knobs[id]
            current_knob?.setValue(randValue, animated: false)
            knobValueChanged(current_knob!)
        }
    }
    
    @IBAction func randomButtonTouched(button: UIButton) {
        let randomValue = Float(arc4random_uniform(101)) / 100.0
        updateKnobValues(randomValue)
    }
    
    func updateLabels() {
        var id = ""
        for (var i = 0; i < knob_ids.count; i++) {
            id = knob_ids[i]
            if let value = getKnobLabel(id) {
                updateLabel(knobs[id], label: value)
            }
        }
    }
    
    func updateLabel(knob: Knob!, label: UILabel) {
        label.text = NSNumberFormatter.localizedStringFromNumber(knob.value, numberStyle: .NoStyle)
    }
    
}