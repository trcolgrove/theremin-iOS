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

class NoteViewController: UIViewController {
    
    var leftmost_note: Int = 0
    var key: String = ""
    //var Grid: GridViewController
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        self.leftmost_note = 60
        self.key = "CMajor"
        //self.Grid = GridViewController()
        super.init()
    }
    
    override func viewDidLoad() {
        println("Note View Controller is loaded")
    }
    
//    func shiftOctave (){
//        leftmost_note += 8
//        Grid.setRange(leftmost_note)
//    }
    
}