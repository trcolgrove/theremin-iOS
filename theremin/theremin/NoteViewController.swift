//
//  NoteViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/5/15.
//  Implemented by Thomas Colgrove
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class NoteViewController: InstrumentViewController {

    var leftmost_note: Int = 0
    //var key: String = ""
    var note_shift: CGFloat = 0
    var touch_origin: CGFloat = 0
    var pan_view: UIView = UIView()
    
    override func viewDidLoad() {
        println("Note View Controller is loaded");
    }
    
    //implement later
    /*
    @IBAction func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        
    }
    */
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
}