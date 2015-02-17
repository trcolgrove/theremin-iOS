//
//  GridViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class GridViewController: InstrumentViewController, RangeViewInstrument {
    
    let default_velocity: Int = 40
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
    
    /*this function sets up delegation/communication between RangeViewContainerController and
    GridViewController at runtime*/
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "grid_init"{
            let range_controller = segue.destinationViewController as RangeViewContainerController
            range_controller.instrument = self
            println("Grid-Range-DelegationSet")
        }
    }
    */
    override func setRange(note: Int) {
        // moves grid to left based on the offset
        leftmost_note = note
    }
    
    func snapToGrid(note_offset: CGFloat) {
        // moves view's origin based on offset
        grid_origin = note_offset
    }
    
    private func calculateAmplification(y: CGFloat, h: CGFloat) -> CGFloat{
        return 0.5 * y / h
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let w = self.view.bounds.width
        let h = self.view.bounds.height
        let touch: AnyObject = touches.allObjects[0]
        let loc = touch.locationInView(self.view)
        
        //Create current note
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        PdBase.sendList([1, pitch, default_velocity], toReceiver: "pitch-vel")
        PdBase.sendList([1, calculateAmplification(loc.y, h: h)], toReceiver: "amp")
        
        // Create a new CircleView for current touch location
        var circleView = CircleView(frame: CGRectMake(loc.x - 0.5 * circle_d, loc.y - 0.5 * circle_d, circle_d, circle_d))
        circles.append(circleView);
        view.addSubview(circleView)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let w = self.view.bounds.width
        let h = self.view.bounds.height
        let touch: AnyObject = touches.allObjects[0]
        let loc = touch.locationInView(self.view)
        
        //Update current note
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        if (loc.y < 0) {
            PdBase.sendList([1, pitch, 0], toReceiver: "pitch-vel")
            PdBase.sendList([1, 0], toReceiver: "amp")
        } else if (loc.x < 0) {
            PdBase.sendList([1, leftmost_note, default_velocity], toReceiver: "pitch-vel")
            PdBase.sendList([1, calculateAmplification(loc.y, h: h)], toReceiver: "amp")
        } else {
            PdBase.sendList([1, pitch, default_velocity], toReceiver: "pitch-vel")
            PdBase.sendList([1, calculateAmplification(loc.y, h: h)], toReceiver: "amp")
        }
        //Move highlight
        var last: CircleView = circles.last!
        last.center.y = loc.y
        last.center.x = loc.x
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        PdBase.sendList([1, pitch, 0], toReceiver: "pitch-vel")
        PdBase.sendList([1, 0], toReceiver: "amp")
        view.subviews.last?.removeFromSuperview()
    }
    
}

