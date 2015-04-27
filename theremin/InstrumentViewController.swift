//
//  InstrumentViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/8/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class InstrumentViewController: UIViewController {
    
    /*
    let FLT : Int = 0
    let NAT : Int = 1
    let SHP : Int = 2
    */
    // data structure that takes a key and returns 
    // the label values for the 13 notes possible
    var key_map : [String:[String]]!
    
    // choices for key change
    let note_names = [ "Cb", "C", "C#", "Db", "D", "D#", "Eb", "E", "E#", "Fb", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B", "B#"]
    
    let note_positions = ["C" : 0, "C#" : 1, "Db" : 1, "D" : 2, "D#" : 3, "Eb" : 3, "E" : 4, "Fb" : 4, "E#" : 5, "F" : 5, "F#" : 6, "Gb" : 6, "G" : 7, "G#" : 8, "Ab" : 8, "A" : 9, "A#" : 10, "Bb" : 10, "B" : 11, "B#" : 11, "Cb" : 11]
    
    let yeffects = ["volume", "tremolo", "vibrato"]
    
    let waveforms = ["sine", "triangle", "sawtooth", "square", "bright", "ivory", "glass", "clav", "bass 1", "bass 2", "deep", "metallic", "organ 1", "organ 2", "bow 1", "bow 2", "bow 3", "steel", "brass 1", "brass 2", "sax", "trump", "wood 1", "wood 2"]
    
    var bottom_menu: BottomMenuController!
    var key_popover: KeyTableViewController?
    var isRecording = false
    var key_names = ["Major", "Minor"]
    
    var key_note: String = "C"
    var key_type: String = "Major"
    var key: String = "CMajor"
    
    
    
    @IBOutlet weak var y_effect: UIButton!

    let num_oct: Int = 4
    let bottom_note: CGFloat = 59.0
    
    var grid: GridViewController!
    var range_controller: RangeViewContainerController!
    var record_controller: RecordViewController!
    
    var grid_lines_showing: Bool = false
    
  
    
    var y_axis_string: String = "volume"
    
    override func viewDidLoad() {
        if let y_button = y_effect {
            y_effect.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2));
        }/*
        if let y = key_btn? {
            self.view.bringSubviewToFront(y)
        }*/

    }
     
    
    func removeGridLines(){
        grid.removeGridLines()
    }
    
    func drawGridLines(){
        grid.drawGridLines()
    }
    
    func playButtonPressed(sender: UIView) {
        if(grid.inPlayback){
            grid.pausePlayback()
        }
        else{
            grid.playRecording()
        }
    }
    
    func stopButtonPressed(sender: UIView) {
        if(isRecording){
            isRecording = false
            grid.stopRecording()
        }
        else{
            grid.stopPlayback()
        }
    }
   
    func recordButtonPressed(sender: UIView) {
        if(isRecording){
            //grid.stopRecording()
            //isRecording = false
            grid.loopRecording()
        }
        else{
            isRecording = true
            grid.beginRecording()
        }

    }
    
    func resetPlayButton(){
        bottom_menu.settings_control.record_control.resetPlayButton()
    }
 
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        insertKeysToMap()
    }
        
    
    
    //set up instrument view as a delegate of subcontrollers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        
        if segue.identifier == "init_range"{
            range_controller = segue.destinationViewController as! RangeViewContainerController
            range_controller.instrument = self
        } else if segue.identifier == "init_grid"{
            let grid = segue.destinationViewController as! GridViewController
            self.grid = grid
        } else if (segue.identifier == "key_menu") {
            let key_menu = segue.destinationViewController as! KeyTableViewController
            self.key_popover = key_menu
            key_menu.isNote = false
            key_menu.keys = key_names
            key_menu.parent = self
        } else if (segue.identifier == "note_menu") {
            let note_menu = segue.destinationViewController as! KeyTableViewController
            self.key_popover = note_menu
            note_menu.isNote = true
            note_menu.keys = note_names
            note_menu.parent = self
        } else if (segue.identifier == "knob_init") {
            //nothing to do here
        } else if (segue.identifier == "record_init") {
            record_controller = segue.destinationViewController as! RecordViewController
        } else if (segue.identifier == "yeffect_popover"){
            let yeffect_menu = segue.destinationViewController as! PopoverViewController
            yeffect_menu.options = yeffects
            yeffect_menu.popoverType = "yeffect"
            yeffect_menu.parent = self as InstrumentViewController
        } else if (segue.identifier == "waveform_popover"){
            let wave_menu = segue.destinationViewController as! PopoverViewController
            wave_menu.options = waveforms
            wave_menu.popoverType = "waveform"
            wave_menu.parent = self as InstrumentViewController
        } else if segue.identifier == "bottom_init"{
            self.bottom_menu = segue.destinationViewController as! BottomMenuController
            bottom_menu.instrument_view = self
        } 
        else {
            println("Internal Error: unknown segue.identifier \(segue.identifier) in InstrumentViewController.prepareForSegue")
        }
    }
    
    /* setRange
     * sets the grid range to that of the leftmost note
     */
    func setRange(offset: CGFloat){
        grid.setRange(offset)
    }

    /* updateKey (value, type)
     * changes the key based on a value and updates key of instrument
     */
    func updateKey(value: String, isNote: Bool) {
        if (isNote) {
            self.key_note = value
            if(key_map["\(self.key_note)" + "\(self.key_type)"] == nil){
                self.key_type = (self.key_type == "Major") ? "Minor" : "Major"
            }
        } else {
            self.key_type = value
        }
        self.key = "\(self.key_note)" + "\(self.key_type)"
        updateKey(self.key, notes: [])
    }
    
    /* updateKey (key, notes)
     * if a given key exists, sets current key to that value
     * and retrieves the notes for that key
     */
    func updateKey(key: String, notes: [String]) {
        var found_notes = lookupKey(key)
        if (found_notes != nil) {
            self.key = key
            println(key_note)
            bottom_menu.settings_control.note_button!.setTitle("\(key_note)", forState: UIControlState.Normal)
            bottom_menu.settings_control.key_button!.setTitle("\(key_type)", forState: UIControlState.Normal)
            self.view.bringSubviewToFront(bottom_menu.settings_control.key_button!)
            grid.updateKey(key, notes: notes)
            range_controller.updateKey(key, notes: notes)
        } else {
            showNoKeyFound()
        }
    }
    
    /* lookupKey
     * returns key set from key_map dictionary
     */
    func lookupKey(key: String) -> [String]? {
        var possibleKey = key_map[key]
        if let foundKey = possibleKey {
            return foundKey
        }
        return nil
    }
    
    func showNoKeyFound() {
        bottom_menu.settings_control.key_popover?.dismissViewController()
        var alert = UIAlertController(title: "Error", message: "Unsupported Key", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func insertKeysToMap() {
        self.key_map = [
            "CbMajor": ["Cb", "Db", "Eb", "Fb", "Gb", "Ab", "Bb"],
            "AbMinor": ["Cb", "Db", "Eb", "Fb", "Gb", "Ab", "Bb"],
            "GbMajor": ["Cb", "Db", "Eb", "F" , "Gb", "Ab", "Bb"],
            "EbMinor": ["Cb", "Db", "Eb", "F" , "Gb", "Ab", "Bb"],
            "DbMajor": ["C" , "Db", "Eb", "F" , "Gb", "Ab", "Bb"],
            "BbMinor": ["C" , "Db", "Eb", "F" , "Gb", "Ab", "Bb"],
            "AbMajor": ["C" , "Db", "Eb", "F" , "G" , "Ab", "Bb"],
            "FMinor" : ["C" , "Db", "Eb", "F" , "G" , "Ab", "Bb"],
            "EbMajor": ["C" , "D" , "Eb", "F" , "G" , "Ab", "Bb"],
            "CMinor" : ["C" , "D" , "Eb", "F" , "G" , "Ab", "Bb"],
            "BbMajor": ["C" , "D" , "Eb", "F" , "G" , "A" , "Bb"],
            "GMinor" : ["C" , "D" , "Eb", "F" , "G" , "A" , "Bb"],
            "FMajor" : ["C" , "D" , "E" , "F" , "G" , "A" , "Bb"],
            "DMinor" : ["C" , "D" , "E" , "F" , "G" , "A" , "Bb"],
            "CMajor" : ["C" , "D" , "E" , "F" , "G" , "A" , "B" ],
            "AMinor" : ["C" , "D" , "E" , "F" , "G" , "A" , "B" ],
            "GMajor" : ["C" , "D" , "E" , "F#", "G" , "A" , "B" ],
            "EMinor" : ["C" , "D" , "E" , "F#", "G" , "A" , "B" ],
            "DMajor" : ["C#", "D" , "E" , "F#", "G" , "A" , "B" ],
            "BMinor" : ["C#", "D" , "E" , "F#", "G" , "A" , "B" ],
            "AMajor" : ["C#", "D" , "E" , "F#", "G#", "A" , "B" ],
            "F#Minor": ["C#", "D" , "E" , "F#", "G#", "A" , "B" ],
            "EMajor" : ["C#", "D#", "E" , "F#", "G#", "A" , "B" ],
            "C#Minor": ["C#", "D#", "E" , "F#", "G#", "A" , "B" ],
            "BMajor" : ["C#", "D#", "E" , "F#", "G#", "A#", "B" ],
            "G#Minor": ["C#", "D#", "E" , "F#", "G#", "A#", "B" ],
            "F#Major": ["C#", "D#", "E#", "F#", "G#", "A#", "B" ],
            "D#Minor": ["C#", "D#", "E#", "F#", "G#", "A#", "B" ],
            "C#Major": ["C#", "D#", "E#", "F#", "G#", "A#", "B#"],
            "A#Minor": ["C#", "D#", "E#", "F#", "G#", "A#", "B#"],
        ]
    }
    
    // Debugging function to make sure keys get stored
    func printKeys() {
        for (myKey,myValue) in key_map {
            println("\(myKey) \t \(myValue)")
        }
    }
    
    func disableScroll() {
        var slider = range_controller.range_control.scrollView as UIScrollView
        slider.setContentOffset(slider.contentOffset, animated: false)
    }
    
    func enableScroll() {
        var slider = range_controller.range_control.scrollView as UIScrollView
        slider.setContentOffset(slider.contentOffset, animated: true)
    }
    
    func updateQuantizeLevel(level: Float) {
        grid.updateQuantizeLevel(level)
    }
    
    @IBAction func deleteAllNotes(sender: AnyObject) {
        grid.deleteAllNotes()
    }
}