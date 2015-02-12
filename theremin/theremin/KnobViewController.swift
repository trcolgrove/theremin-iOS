//
//  KnobViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/5/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class KnobViewController: InstrumentViewController {
    
    var reverb: Int = 0
    var chorus: Int = 0
    var tremolo: Int = 0
    var gain: Int = 0
    
    override func viewDidLoad() {
        println("Knob View Controller is loaded");
    }
    
}