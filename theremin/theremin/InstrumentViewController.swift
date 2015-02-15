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
    // the midi values in that key
    var key_map = [
        "CMajor" : [0, 2, 4, 5, 7, 9, 11],
        "GMajor" : [7, 9, 11, 0, 2, 4, 6]
    ]
    
    // the current key of the theremin
    var key: String = ""
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func buttonClicked (sender: AnyObject) {
        println("Button pressed: " + sender.currentTitle!!);
        self.updateKey(sender.currentTitle!!)
    }
    
    // sets the theremin key
    func updateKey(key: String) {
        self.key = key
        println("Key changed to " + self.key)
    }
    
    override func viewDidLoad() {
        println("Instrument View Controller is loaded")
    }
    
}