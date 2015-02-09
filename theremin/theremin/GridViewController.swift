//
//  GridViewController.swift
//  theremin
//
//  Created by McCall Bliss on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class GridViewController: InstrumentViewController {
    
    let max_volume: Int = 50
    var leftmost_note: Int = 60
    var pitch: CGFloat = 60
    var vel: CGFloat = 5
    var prev_x: CGFloat = 0
    var prev_y: CGFloat = 0
    var w: CGFloat = 0
    var h: CGFloat = 0
    
    override func viewDidLoad() {
        println("Grid View Controller is loaded");
    }
    
    override func updateKey(key: String) {
        
        self.key = key
        var map = super.key_map[key]
        // additional code for changing grid key
        
    }
    
    func setRange(note: Int) {
        self.leftmost_note = note
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

