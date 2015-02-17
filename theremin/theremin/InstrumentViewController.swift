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
    var grid: GridViewController!
    var range_controller: RangeViewContainerController!
    
    @IBOutlet var key_btn: UIButton?
    
    var octave: Int = 5
    
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
    
    func setRange(leftmost_note: Int){
        grid.setRange(leftmost_note)
    }
    
    // sets the theremin key if it exists in the key_map dictionary
    func updateKey(key: String) {
        key_btn?.setTitle("\(key)", forState: UIControlState.Normal)
        if (lookupKey(key) != []) {
            self.key = key
            key_btn?.setTitle("\(key)", forState: UIControlState.Normal)
            // send a message to update the key in both note & grid
            // update the key value label
        } else {
            println("Key \(key) does not exist")
        }
    }
    
    // returns key set from key_map dictionary
    func lookupKey(key: String) -> [String] {
        var possibleKey = key_map[key]
        if let foundKey = possibleKey {
            println("Key: \(foundKey)")
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
            "GMajor" : ["G", "", "A", "", "B", "C", "", "D", "", "E", "", "F#", "G"],
            "DMajor" : ["D", "", "E", "", "F#", "G", "", "A", "", "B", "", "C#", "D"],
            "AMajor" : ["A", "", "B", "", "C#", "D", "", "E", "", "F#", "", "G#", "A"],
            "EMajor" : ["E", "", "F#", "", "G#", "A", "", "B", "", "C#", "", "D#", "E"],
            "BMajor" : ["B", "", "C#", "", "D#", "E", "", "F#", "", "G#", "", "A#", "B"],
            "F#Major": ["F#", "", "G#", "", "A#", "B", "", "C#", "", "D#", "", "E#", "F#"],
            "C#Major": ["C#", "", "D#", "", "E#", "F#", "", "G#", "", "A#", "", "B#", "C#"]
        ]
    }
    
    // Debugging function to make sure keys get stored
    func printKeys() {
        for (myKey,myValue) in key_map {
            println("\(myKey) \t \(myValue)")
        }
    }
    
}