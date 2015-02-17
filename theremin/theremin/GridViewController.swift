//
//  GridViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class GridViewController: InstrumentViewController, RangeViewDelegate {
    
    let max_volume: Int = 50
    var leftmost_note: Int = 60
    var pitch: CGFloat = 60
    var vel: CGFloat = 5
    let circle_d = CGFloat(25)
    var circles: [CircleView] = []
    
    // grid position
    @IBOutlet weak var grid_image: UIImageView!
    var grid_origin: CGFloat = 0
    let grid_width: CGFloat = 72.5

    override func viewDidLoad() {
        println("Grid View Controller is loaded");
    }
    
    override func updateKey(new_key: String) {
        var notes = super.lookupKey(new_key)
        super.updateKey(new_key)
    }
    
    func setRange(note: Int) {
        // moves grid to left based on the offset
        leftmost_note = note
    }
    
    func snapToGrid(note_offset: CGFloat) {
        // moves view's origin based on offset
        grid_origin = note_offset
    }
    
    func drawCircle(x: CGFloat, y: CGFloat, context: CGContext) {
        println("in draw circle")
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let w = self.view.bounds.width
        let h = self.view.bounds.height
        let touch: AnyObject = touches.allObjects[0]
        let touch_loc = touch.locationInView(self.view)
        pitch = CGFloat(leftmost_note) + (touch_loc.x / w) * 12
        vel = CGFloat(max_volume)
        PdBase.sendList([1, pitch, vel], toReceiver: "pitch-vel")
        
        // Create a new CircleView
        var circleView = CircleView(frame: CGRectMake(touch_loc.x - 0.5 * circle_d, touch_loc.y - 0.5 * circle_d, circle_d, circle_d))
        circles.append(circleView);
        view.addSubview(circleView)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let w = self.view.bounds.width
        let h = self.view.bounds.height
        let touch: AnyObject = touches.allObjects[0]
        let loc = touch.locationInView(self.view)
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        vel = (loc.y / h) * (CGFloat(max_volume))
        PdBase.sendList([1, pitch, vel], toReceiver: "pitch-vel")
        var last: CircleView = circles.last!
        last.center.y = loc.y //- circle_d * 0.5
        last.center.x = loc.x //- circle_d * 0.5
        
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        PdBase.sendList([1, pitch, 0], toReceiver: "pitch-vel")
        view.subviews.last?.removeFromSuperview()
        
    }
    
}

