//
//  GridViewController.swift
//  theremin
//
//  Created by McCall Bliss on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class GridViewController: UIViewController {
    
    // get xy coord
    // touch on
    // touch move
    // touch off
    // convert to midi
    
    var pitch: CGFloat = 60
    var vel: CGFloat = 10
    var prev_x: CGFloat = 0
    var prev_y: CGFloat = 0
    
    override func viewDidLoad() {
        println("Grid View Controller is loaded");
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject = touches.allObjects[0]
        let loc = touch.locationInView(self.view)
        println("touch is at: (\(loc.x), \(loc.y))")
        pitch = 60
        prev_x = 0
        prev_y = 0
        PdBase.sendList([1, self.pitch, vel], toReceiver: "pitch-vel")

    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject = touches.allObjects[0]
        let loc = touch.locationInView(self.view)
        println("touch is at: (\(loc.x), \(loc.y))")
        

        pitch += (prev_x < loc.x ? 0.05 : -0.05)
        vel += (prev_y < loc.y ? 1 : (vel > 1 ? -1 : 0))
       
        
        PdBase.sendList([1, pitch, vel], toReceiver: "pitch-vel")
        prev_x = loc.x
        prev_y = loc.y
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touch up")
        PdBase.sendList([1, 60, 0], toReceiver: "pitch-vel")

    }
    
}

