//
//  NoteViewController.swift
//  theremin
//
//  Created by McCall Bliss on 2/5/15.
//  Implemented by Thomas Colgrove
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class NoteViewController: InstrumentViewController {
    
    var leftmost_note: Int = 0
    //var Grid: GridViewController
    
//    init() {
//        self.leftmost_note = 60
//        self.key = "CMajor"
//        super.init()
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    override func viewDidLoad() {
        println("Note View Controller is loaded")
    }
    
//    func shiftOctave (){
//        leftmost_note += 8
//        Grid.setRange(leftmost_note)
//    }
    
}