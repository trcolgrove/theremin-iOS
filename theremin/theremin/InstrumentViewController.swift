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
    
    let FLT : Int = 0
    let NAT : Int = 1
    let SHP : Int = 2
    // data structure that takes a key and returns 
    // the label values for the 13 notes possible
    var key_map : [String:[Int]]!
    
    // choices for key change
    let note_names = [ "Cb", "C", "C#", "Db", "D", "D#", "Eb", "E", "E#", "Fb", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B", "B#"]
    let note_positions = ["C" : 0, "C#" : 1, "Db" : 1, "D" : 2, "D#" : 3, "Eb" : 3, "E" : 4, "Fb" : 4, "E#" : 5, "F" : 5, "F#" : 6, "Gb" : 6, "G" : 7, "G#" : 8, "Ab" : 8, "A" : 9, "A#" : 10, "Bb" : 10, "B" : 11, "B#" : 11, "Cb" : 11]

    var key_names = ["Major", "Minor"]
    
    var key_note: String = "C"
    var key_type: String = "Major"
    var key: String = "CMajor"
    
    var key_popover: KeyTableViewController?

    //var leftmost_note = "C"
    var octave: Int = 5
    var grid: GridViewController!
    var range_controller: RangeViewContainerController!
   
    
    @IBOutlet var note_btn: UIButton?
    @IBOutlet var key_btn: UIButton?
    @IBOutlet weak var grid_switch: UISwitch?
    
    
    
    @IBAction func switchChanged(sender: UISwitch) {
        if(sender.on){
            grid.gridOn()
        }
        else{
            grid.gridOff()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        insertKeysToMap()
    }

    //set up intrument view as a delegate of subcontrollers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "init_range"{
            range_controller = segue.destinationViewController as RangeViewContainerController
            range_controller.instrument = self
            println("Range Delegation Set")
        }
        else if segue.identifier == "init_grid"{
            let grid = segue.destinationViewController as GridViewController
            self.grid = grid
            println("Grid Delegation Set")
        }
        else if (segue.identifier == "key_menu") {
            let key_menu = segue.destinationViewController as KeyTableViewController
            self.key_popover = key_menu
            key_menu.table_type = false
            key_menu.keys = key_names
            key_menu.parent = self
            println("Key Menu Clicked/Initialized")
        }
        else if (segue.identifier == "note_menu") {
            let note_menu = segue.destinationViewController as KeyTableViewController
            self.key_popover = note_menu
            note_menu.table_type = true
            note_menu.keys = note_names
            note_menu.parent = self
            println("Note Menu Clicked/Initialized")
        }
        else{
            println("unknown id")
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
    func updateKey(key: String, notes: [Int]) {
        var found_notes = lookupKey(key)
        if (found_notes != nil) {
            self.key = key
            note_btn?.setTitle("\(key_note)", forState: UIControlState.Normal)
            key_btn?.setTitle("\(key_type)", forState: UIControlState.Normal)
            grid.updateKey(key, notes: notes)
            range_controller.updateKey(key, notes: notes)
        } else {
            showNoKeyFound()
            println("Key \(key) does not exist")
        }
    }
    
    /* lookupKey
     * returns key set from key_map dictionary
     */
    func lookupKey(key: String) -> [Int]? {
        var possibleKey = key_map[key]
        if let foundKey = possibleKey {
            return foundKey
        }
        return nil
    }
    
    func showNoKeyFound() {
        self.key_popover?.dismissViewController()
        var alert = UIAlertController(title: "Error", message: "Unsupported Key", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        println("Instrument View Controller is loaded")
    }
    
    func insertKeysToMap() {
        self.key_map = [
            "CbMajor": [FLT, FLT, FLT, FLT, FLT, FLT, FLT],
            "AbMinor": [FLT, FLT, FLT, FLT, FLT, FLT, FLT],
            "GbMajor": [FLT, FLT, FLT, NAT, FLT, FLT, FLT],
            "EbMinor": [FLT, FLT, FLT, NAT, FLT, FLT, FLT],
            "DbMajor": [NAT, FLT, FLT, NAT, FLT, FLT, FLT],
            "BbMinor": [NAT, FLT, FLT, NAT, FLT, FLT, FLT],
            "AbMajor": [NAT, FLT, FLT, NAT, NAT, FLT, FLT],
            "FMinor" : [NAT, FLT, FLT, NAT, NAT, FLT, FLT],
            "EbMajor": [NAT, NAT, FLT, NAT, NAT, FLT, FLT],
            "CMinor" : [NAT, NAT, FLT, NAT, NAT, FLT, FLT],
            "BbMajor": [NAT, NAT, FLT, NAT, NAT, NAT, FLT],
            "GMinor" : [NAT, NAT, FLT, NAT, NAT, NAT, FLT],
            "FMajor" : [NAT, NAT, NAT, NAT, NAT, NAT, FLT],
            "DMinor" : [NAT, NAT, NAT, NAT, NAT, NAT, FLT],
            "CMajor" : [NAT, NAT, NAT, NAT, NAT, NAT, NAT],
            "AMinor" : [NAT, NAT, NAT, NAT, NAT, NAT, NAT],
            "GMajor" : [NAT, NAT, NAT, SHP, NAT, NAT, NAT],
            "EMinor" : [NAT, NAT, NAT, SHP, NAT, NAT, NAT],
            "DMajor" : [SHP, NAT, NAT, SHP, NAT, NAT, NAT],
            "BMinor" : [SHP, NAT, NAT, SHP, NAT, NAT, NAT],
            "AMajor" : [SHP, NAT, NAT, SHP, SHP, NAT, NAT],
            "F#Minor": [SHP, NAT, NAT, SHP, SHP, NAT, NAT],
            "EMajor" : [SHP, SHP, NAT, SHP, SHP, NAT, NAT],
            "C#Minor": [SHP, SHP, NAT, SHP, SHP, NAT, NAT],
            "BMajor" : [SHP, SHP, NAT, SHP, SHP, SHP, NAT],
            "G#Minor": [SHP, SHP, NAT, SHP, SHP, SHP, NAT],
            "F#Major": [SHP, SHP, SHP, SHP, SHP, SHP, NAT],
            "D#Minor": [SHP, SHP, SHP, SHP, SHP, SHP, NAT],
            "C#Major": [SHP, SHP, SHP, SHP, SHP, SHP, SHP],
            "A#Minor": [SHP, SHP, SHP, SHP, SHP, SHP, SHP]
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
}