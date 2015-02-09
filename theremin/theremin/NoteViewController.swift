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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var leftmost_note: Int = 0
    var key: String = ""
    var note_shift: CGFloat = 0
    var Grid: GridViewController
    var touch_origin: CGFloat = 0
    
    
    override func viewDidLoad() {
        println("Note View Controller is loaded");
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
        let touch: AnyObject = touches.allObjects[0]
        let loc =  touch.locationInView(self.view)
        touch_origin = loc.x
    }
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent){
        let touch: AnyObject = touches.allObjects[0]
        let loc =  touch.locationInView(self.view)
        note_shift += (touch_origin < loc.x ? 1 : -1)
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touch up")
        //Grid.shiftRange(note_shift)
    }
    
    func shiftRange (shiftAmount: Int){
        leftmost_note += shiftAmount
    }
    
}