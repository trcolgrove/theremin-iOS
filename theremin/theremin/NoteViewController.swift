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

class NoteViewController {
    var leftmost_note: Int = 0
    var key: String = ""
    var Grid: GridViewController
    
    init(){
        leftmost_note = 60
        key = "CM"
        Grid = GridViewController()
    }
    
}