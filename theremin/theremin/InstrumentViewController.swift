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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func buttonClicked (sender: AnyObject) {
        println("Button pressed: " + sender.currentTitle!!);
        self.updateKey(sender.currentTitle!!)
    }
    
    // sets the theremin key if it exists in the key_map dictionary
    func updateKey(key:String) {
        if (lookupKey(key) != []) {
            self.key = key
        } else {
            println("Key does not exist")
        }
    }
    
    // returns key set from key_map dictionary
    func lookupKey(key: String) -> [String] {
        var possibleKey = self.key_map[key]
        if let foundKey = possibleKey {
            println("Name: \(foundKey)")
            return foundKey
        }
        return []
    }
    
    override func viewDidLoad() {
        println("Instrument View Controller is loaded")
        insertKeysToMap()
        println(self.key_map[self.key])
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
    
}