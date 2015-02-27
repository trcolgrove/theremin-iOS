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
    
    let NAT : Int = 0
    let FLAT : Int = 1
    let SHARP : Int = 2
    // data structure that takes a key and returns 
    // the label values for the 13 notes possible
    var key_map : [String:[Int]]!
    
    // choices for key change
    var note_names = ["C", "Cb", "C#", "D", "Db", "D#", "E", "Eb", "E#", "F", "Fb", "F#", "G", "Gb", "G#", "A", "Ab", "A#", "B", "Bb", "B#"]
    var key_names = ["Major", "Minor"]
    
    var key_note: String = "C"
    var key_type: String = "Major"
    var key: String = "CMajor"
    
    //var leftmost_note = "C"
    var octave: Int = 5
    var grid: GridViewController!
    var range_controller: RangeViewContainerController!
    
    @IBOutlet var note_btn: UIButton?
    @IBOutlet var key_btn: UIButton?
    
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
            key_menu.table_type = false
            key_menu.keys = key_names
            key_menu.parent = self
            println("Key Menu Clicked/Initialized")
        }
        else if (segue.identifier == "note_menu") {
            let note_menu = segue.destinationViewController as KeyTableViewController
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
    func setRange(leftmost_note: CGFloat){
        grid.setRange(leftmost_note)
    }

    /* updateKey (value, type)
     * changes the key based on a value and updates key of instrument
     */
    func updateKey(value: String, isNote: Bool) {
        if (isNote) {
            self.key_note = value
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
        var notes = lookupKey(key)
        if (notes != []) {
            self.key = key
            //self.leftmost_note = notes[0]
            note_btn?.setTitle("\(key_note)", forState: UIControlState.Normal)
            key_btn?.setTitle("\(key_type)", forState: UIControlState.Normal)
            // set range of grid view controller - wants an int but we have a string?
            grid.updateKey(key, notes: notes)
            range_controller.updateKey(key, notes: notes)
        } else {
            println("Key \(key) does not exist")
        }
    }
    
    /* lookupKey
     * returns key set from key_map dictionary
     */
    func lookupKey(key: String) -> [Int] {
        var possibleKey = key_map[key]
        if let foundKey = possibleKey {
            return foundKey
        }

        return key_map[key]!
    }
    
    override func viewDidLoad() {
        println("Instrument View Controller is loaded")
    }
    
    func insertKeysToMap() {
        self.key_map = [
            "CMajor" : [NAT, NAT, NAT, NAT, NAT , NAT, NAT],
            "C#Major": [0],
            "CMinor" : [0],
            "C#Minor": [0],
            "GMajor" : [NAT, NAT, NAT, SHARP, NAT , NAT, NAT],
            "GbMajor": [],
            "GMinor" : [],
            "G#Minor": [],
            "DMajor" : [SHARP, NAT, NAT, SHARP, NAT , NAT, NAT],
            "DbMajor": [],
            "DMinor" : [],
            "D#Minor": [],
            "AMajor" : [],
            "AbMajor": [],
            "AMinor" : [],
            "EMajor" : [],
            "EbMajor": [],
            "EbMinor": [],
            "EMinor" : [],
            "BMajor" : [],
            "BbMajor": [],
            "BbMinor": [],
            "BMinor" : [],
            "F#Major": [],
            "FMajor" : [],
            "FMinor" : [],
            "F#Minor": [],
        ]
    }
    
    // Debugging function to make sure keys get stored
    func printKeys() {
        for (myKey,myValue) in key_map {
            println("\(myKey) \t \(myValue)")
        }
    }
    
}