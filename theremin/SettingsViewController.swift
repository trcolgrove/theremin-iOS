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
    
    var container_view: BottomMenuController!
    var instrument_view: InstrumentViewController!
    var knob_menu: KnobViewController!
    var record_control: RecordViewController!
    
    @IBOutlet weak var grid_lines_btn: UIButton!
    @IBOutlet weak var clear_notes_btn: UIButton!
    
    @IBAction func gridLinesPressed(sender: UIButton!) {
        if (grid_lines_showing) {
            sender.backgroundColor = UIColor(white: 137/255, alpha: 1.0)
            grid_lines_showing = false
            instrument_view.removeGridLines()
        } else {
            sender.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
            instrument_view.drawGridLines()
            grid_lines_showing = true
        }
    }
    
    @IBAction func clearNotesPressed(sender: AnyObject) {
    }
    
    @IBOutlet var loop_toggle: UISwitch!
    @IBOutlet weak var showSynth: UIButton!

    @IBAction func synthButtonPressed(sender: AnyObject) {
        container_view.displaySynth()
    }
/*

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
    */
    @IBOutlet weak var note_button: UIButton!
    @IBOutlet weak var key_button: UIButton!
    
    override func viewDidLoad() {
        //knob_menu.instrument_view = instrument_view
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "key_menu") {
            let key_menu = segue.destinationViewController as! KeyTableViewController
            self.key_popover = key_menu
            key_menu.isNote = false
            key_menu.keys = key_names
            key_menu.parent = instrument_view
        }
        
        else if (segue.identifier == "note_menu") {
            let note_menu = segue.destinationViewController as! KeyTableViewController
            self.key_popover = note_menu
            note_menu.isNote = true
            note_menu.keys = note_names
            note_menu.parent = instrument_view
        }
        
        else if (segue.identifier == "record_init") {
            //nothing to do here
            record_control = segue.destinationViewController as! RecordViewController
        }
        
        else if (segue.identifier == "knob_init") {
            knob_menu = segue.destinationViewController as! KnobViewController
        }

    }
}
    
    

