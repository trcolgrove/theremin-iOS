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
    
    // data structure that takes a key and returns 
    // the label values for the 13 notes possible
    var key_map = [String:[String]]()

    // the current key of the theremin
    var key: String = "CMajor"
    //var leftmost_note = "C"
    var octave: Int = 5
    var grid: GridViewController!
    var range_controller: RangeViewContainerController!
    
    @IBOutlet var key_btn: UIButton?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //set up intrument view as a delegate of subcontrollers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "init_range"{
            let range_container = segue.destinationViewController as RangeViewContainerController
            range_container.instrument = self
            println("Range Delegation Set")
        }
        else if segue.identifier == "init_grid"{
            let grid = segue.destinationViewController as GridViewController
            self.grid = grid
            println("Grid Delegation Set")
        }
        else if segue.identifier == "key_menu"{
            let key_menu = segue.destinationViewController as KeyTableViewController
            key_menu.parent = self
            println("Menu Clicked/Initialized")
        }
    }
    
    /* setRange
     * sets the grid range to that of the leftmost note
     */
    func setRange(leftmost_note: Int){
        grid.setRange(leftmost_note)
    }
    
    /* updateKey
     * if a given key exists, sets current key to that value
     * and retrieves the notes for that key
     */
    func updateKey(key: String, notes: [String]) {
        var notes = lookupKey(key)
        if (notes != []) {
            self.key = key
            //self.leftmost_note = notes[0]
            key_btn?.setTitle("\(key)", forState: UIControlState.Normal)
            // set range of grid view controller - wants an int but we have a string?
            grid.updateKey(key, notes: notes)
            //range_controller.updateKey(key, notes: notes)
        } else {
            println("Key \(key) does not exist")
        }
    }
    
    /* lookupKey
     * returns key set from key_map dictionary
     */
    func lookupKey(key: String) -> [String] {
        var possibleKey = key_map[key]
        if let foundKey = possibleKey {
            //println("Key: \(foundKey)")
            return foundKey
        }
        return []
    }
    
    override func viewDidLoad() {
        println("Instrument View Controller is loaded")
        insertKeysToMap()
    }
    
    func insertKeysToMap() {
        self.key_map = [
            "CMajor" : ["C", "", "D", "", "E", "F", "", "G", "", "A", "", "B", "C"],
            "C#Major": ["C#", "", "D#", "", "E#", "F#", "", "G#", "", "A#", "", "B#", "C#"],
            "CMinor" : ["C", "", "D", "D#", "", "F", "", "G", "G#", "", "A#", "", "C"],
            "C#Minor": ["C#", "", "D#", "E", "", "F#", "", "G#", "A", "", "B", "", "C#"],
            "GMajor" : ["G", "", "A", "", "B", "C", "", "D", "", "E", "", "F#", "G"],
            "GbMajor": ["Gb"],
            "GMinor" : ["G"],
            "G#Minor": ["G#"],
            "DMajor" : ["D", "", "E", "", "F#", "G", "", "A", "", "B", "", "C#", "D"],
            "DbMajor": ["Db", "", "Eb", "", "F", "Gb", "", "Ab", "", "Bb", "", "C", "Db"],
            "DMinor" : ["D"],
            "D#Minor": ["D#"],
            "AMajor" : ["A", "", "B", "", "C#", "D", "", "E", "", "F#", "", "G#", "A"],
            "AbMajor": ["Ab"],
            "AMinor" : ["A", "", "B", "C", "", "D", "", "E", "F", "", "G", "", "A"],
            "EMajor" : ["E", "", "F#", "", "G#", "A", "", "B", "", "C#", "", "D#", "E"],
            "EbMajor": ["Eb"],
            "EbMinor": ["Eb"],
            "EMinor" : ["E"],
            "BMajor" : ["B", "", "C#", "", "D#", "E", "", "F#", "", "G#", "", "A#", "B"],
            "BbMajor": ["Bb"],
            "BbMinor": ["Bb"],
            "BMinor" : ["B"],
            "F#Major": ["F#", "", "G#", "", "A#", "B", "", "C#", "", "D#", "", "E#", "F#"],
            "FMajor" : ["F"],
            "FMinor" : ["F"],
            "F#Minor": ["F#"],
        ]
    }
    
    // Debugging function to make sure keys get stored
    func printKeys() {
        for (myKey,myValue) in key_map {
            println("\(myKey) \t \(myValue)")
        }
    }
    
}