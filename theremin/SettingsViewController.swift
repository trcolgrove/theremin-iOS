//
//  SettingsViewController.swift
//  theremin
//
//  Created by McCall Bliss on 4/5/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: InstrumentViewController {
    
    @IBOutlet var loop_toggle: UISwitch!


    @IBAction func changeKey(sender: AnyObject) {
        println("function key")
    }
    
    @IBAction func changeWave(sender: AnyObject) {
        
        println("function changeWave")
        
    }
    
    @IBAction func addGridlines(sender: AnyObject) {
        
        println("function gridlines")
        
    }
    
    @IBAction func clearAllNotes(sender: AnyObject) {
    
        println("function clearnotes")
        
    }
    
    
}
