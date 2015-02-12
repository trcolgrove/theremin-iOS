//
//  GridViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class GridViewController: InstrumentViewController {
    
    let max_volume: Int = 50
    var leftmost_note: Int = 60
    var pitch: CGFloat = 60
    var vel: CGFloat = 5
    var w: CGFloat = 0
    var h: CGFloat = 0
    
    // grid position
    @IBOutlet weak var grid_image: UIImageView!
    var grid_origin: CGFloat = 0
    let grid_width: CGFloat = 50
    override func viewDidLoad() {
        println("Grid View Controller is loaded");
    }
    
    override func updateKey(new_key: String) {
        key = new_key
        // get the leftmost note information from the key_map
        // leftmost_note = super.key_map[key]
    }
    
    func setRange(note: Int, offset: CGFloat) {
        // moves grid to left based on the offset
        var note_offset = (offset % grid_width)
        snapToGrid(note_offset)
        
        // sets the leftmost note
        leftmost_note = note
    }
    
    func snapToGrid(note_offset: CGFloat) {
        // moves view's origin based on offset
        grid_origin = note_offset
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        w = self.view.bounds.width
        h = self.view.bounds.height
        let touch: AnyObject = touches.allObjects[0]
        let loc = touch.locationInView(self.view)
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        vel = (loc.y / h) * (CGFloat(max_volume))
        PdBase.sendList([1, pitch, vel], toReceiver: "pitch-vel")

    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject = touches.allObjects[0]
        let loc = touch.locationInView(self.view)
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        vel = (loc.y / h) * (CGFloat(max_volume))
        PdBase.sendList([1, pitch, vel], toReceiver: "pitch-vel")
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        PdBase.sendList([1, pitch, 0], toReceiver: "pitch-vel")
    }
    
}

