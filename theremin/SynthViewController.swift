//
//  SynthViewController.swift
//  theremin
//
//  Created by Thomas Colgrove on 4/23/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class SynthViewController: UIViewController{
    
    var container_view: BottomMenuController!
    var instrument_view: InstrumentViewController!
    
    var low_index = 0 //the lowest channel being effected by synth change
    var high_index = 9
        //highest channel being effected by synth change
    @IBOutlet weak var toSettings: UIButton!
    
    @IBOutlet weak var osc1_mix_temp: UIView!
    @IBOutlet weak var osc1_phase_temp: UIView!
    @IBOutlet weak var osc1_pitch_temp: UIView!
    
    @IBOutlet weak var osc2_mix_temp: UIView!
    @IBOutlet weak var osc2_phase_temp: UIView!
    @IBOutlet weak var osc2_pitch_temp: UIView!

    @IBOutlet weak var osc3_mix_temp: UIView!
    @IBOutlet weak var osc3_phase_temp: UIView!
    @IBOutlet weak var osc3_pitch_temp: UIView!
    
    @IBOutlet weak var osc1_mix_label: UILabel!
    @IBOutlet weak var osc1_phase_label: UILabel!
    @IBOutlet weak var osc1_pitch_label: UILabel!
    
    @IBOutlet weak var osc2_mix_label: UILabel!
    @IBOutlet weak var osc2_phase_label: UILabel!
    @IBOutlet weak var osc2_pitch_label: UILabel!
    
    @IBOutlet weak var osc3_mix_label: UILabel!
    @IBOutlet weak var osc3_phase_label: UILabel!
    @IBOutlet weak var osc3_pitch_label: UILabel!
    
    @IBOutlet weak var osc1_toggle: UISwitch!
    @IBOutlet weak var osc2_toggle: UISwitch!
    @IBOutlet weak var osc3_toggle: UISwitch!
    
    @IBAction func switchDidMove(sender: UISwitch!) {
        var on_off = 0
        if(sender.on){
            on_off = 1
        }
        if(sender == osc1_toggle){
            sendToChannelsInRange(low_index, high: high_index, msg: ["osc1", "on", on_off])
        } else if(sender == osc2_toggle){
            sendToChannelsInRange(low_index, high: high_index, msg: ["osc2", "on", on_off])
        } else if(sender == osc3_toggle){
            sendToChannelsInRange(low_index, high: high_index, msg: ["osc3", "on", on_off])
        }
    }
    
    var osc1 : [Float] = [0, 0, 0]
    var osc2 : [Float] = [0, 0, 0]
    var osc3 : [Float] = [0, 0, 0]
    
    var knobs = [String:Knob]()
    var knob_ids = ["mix1", "phase1", "pitch1", "mix2", "phase2", "pitch2", "mix3", "phase3", "pitch3"]
    

    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        container_view.displaySettings()
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeKnobs()
        updateLabels()
    }
    
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
    
    
    func getPlaceholder(id: String) -> UIView? {
        switch id {
        case "mix1":
            return osc1_mix_temp
        case "phase1":
            return osc1_phase_temp
        case "pitch1":
            return osc1_pitch_temp
        case "mix2":
            return osc2_mix_temp
        case "phase2":
            return osc2_phase_temp
        case "pitch2":
            return osc2_pitch_temp
        case "mix3":
            return osc3_mix_temp
        case "phase3":
            return osc3_phase_temp
        case "pitch3":
            return osc3_pitch_temp
        default:
            return nil
        }
    }
    
    func getKnobValue(id: String) -> Float? {
        switch id {
        case "mix1":
            return osc1[0]
        case "phase1":
            return osc1[1]
        case "pitch1":
            return osc1[2]
        case "mix2":
            return osc2[0]
        case "phase2":
            return osc2[1]
        case "pitch2":
            return osc2[2]
        case "mix3":
            return osc3[0]
        case "phase3":
            return osc3[1]
        case "pitch3":
            return osc3[2]
        default:
            return nil
        }
    }
    
    func getKnobLabel(id: String) -> UILabel? {
        switch id {
        case "mix1":
            return osc1_mix_label
        case "phase1":
            return osc1_phase_label
        case "pitch1":
            return osc1_pitch_label
        case "mix2":
            return osc2_mix_label
        case "phase2":
            return osc2_phase_label
        case "pitch2":
            return osc2_pitch_label
        case "mix3":
            return osc3_mix_label
        case "phase3":
            return osc3_phase_label
        case "pitch3":
            return osc3_pitch_label
        default:
            return nil
        }

    }
    
    /** Assigns the knob an id based on the function of the knob **/
    func assignID(knob: Knob, id: String) {
        knob.setID(id)
    }
    
    func knobValueChanged(knob: Knob) {
        if let knob_label = getKnobLabel(knob.id) {
            updateLabel(knobs[knob.id], label: knob_label)
            if let cur_value = getKnobValue(knob.id) {
                switch knob.id {
                default:
                    println("Asdf")
                }
            }
        }
    }
    
    
    /** Send a PdList to a range of Channels **/
    func sendToChannelsInRange(low: Int, high: Int, msg: [AnyObject]){
        for i in low...high {
            var new_msg = msg
            new_msg.insert(i, atIndex: 0)
            PdBase.sendList( new_msg, toReceiver: "note")
        }
        
    }
    
    /** Changes all knob values to a given float **/
    func updateKnobValues(value: Float) {
        var id = ""
        for (var i = 0; i < knob_ids.count; i++) {
            id = knob_ids[i]
            var current_knob = knobs[id]
            current_knob?.setValue(value, animated: false)
            knobValueChanged(current_knob!)
        }
    }
    
    /** Updates all of the knob labels for values **/
    func updateLabels() {
        var id = ""
        for (var i = 0; i < knob_ids.count; i++) {
            id = knob_ids[i]
            if let value = getKnobLabel(id) {
                updateLabel(knobs[id], label: value)
            }
        }
    }
    
    /** Updates a label for a knob **/
    func updateLabel(knob: Knob!, label: UILabel) {
        label.text = NSNumberFormatter.localizedStringFromNumber(knob.value, numberStyle: .NoStyle)
    }
}