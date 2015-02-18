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
    let CIRCLE_DIAMETER = CGFloat(25)
    var circles: [CircleView] = []
    var note_count = 0
    var current_note = 0
    let pan_rec = UIPanGestureRecognizer()
    let touch2_rec = UITapGestureRecognizer()
    var w: CGFloat = 0
    var h: CGFloat = 0
    var no_delete_flag: Bool = false
    
    
    // grid position
    @IBOutlet weak var grid_image: UIImageView!
    var grid_origin: CGFloat = 0
    let grid_width: CGFloat = 72.5

    override func viewDidLoad() {
        println("Grid View Controller is loaded");
        w = self.view.bounds.width
        h = self.view.bounds.height
        pan_rec.addTarget(self, action: "handlePan:")
        pan_rec.minimumNumberOfTouches = 1
        pan_rec.maximumNumberOfTouches = 1
        touch2_rec.addTarget(self, action: "handleDoubleTap:")
        touch2_rec.numberOfTapsRequired = 2
        touch2_rec.cancelsTouchesInView = true
        for i in 0...4 {
            //init off the screen for shits
            circles.append(CircleView(frame: CGRectMake(-500 - 0.5 * CIRCLE_DIAMETER, -500 - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: i, view_controller: self))
        }
        self.view.addGestureRecognizer(pan_rec)
        self.view.addGestureRecognizer(touch2_rec)
    }
    
    override func updateKey(new_key: String) {
        var notes = super.lookupKey(new_key)
        super.updateKey(new_key)
    }
    
    /*this function sets up delegation/communication between RangeViewContainerController and
    GridViewController at runtime*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "grid_init"{
            let range_controller = segue.destinationViewController as RangeViewContainerController
            range_controller.instrument = self
            println("Grid-Range-DelegationSet")
        }
    }

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
    
    //gesture recognizer stuff
    func handleDoubleTap(sender: UITapGestureRecognizer){
        println("DOUBLE TAP")
        
        //add gesture recognizer for tap on this circle
        var double_tap_rec = UITapGestureRecognizer(target: circles[current_note], action: "handleDoubleTap:")
        double_tap_rec.numberOfTapsRequired = 2
        double_tap_rec.cancelsTouchesInView = true
        circles[current_note].addGestureRecognizer(double_tap_rec)
    }
    
    
    func handlePan(sender: UIPanGestureRecognizer){
        var loc: CGPoint
        switch sender.state {
        case UIGestureRecognizerState.Began:
            println("began")
            loc = sender.locationOfTouch(0, inView: self.view)
            updateNote(loc)
        case UIGestureRecognizerState.Changed:
            loc = sender.locationOfTouch(0, inView: self.view)
            println("changed")
            updateNote(loc)
        case UIGestureRecognizerState.Ended:
            println("ended")
            if no_delete_flag == true {
                no_delete_flag = false
            } else {
                deleteNote(current_note)
            }
        case UIGestureRecognizerState.Cancelled:
            println("cancelled")
            deleteNote(current_note)
        default:
            println("default")
        }
    }
   
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touches began")
        let touch: AnyObject = touches.allObjects[0]
        var loc: CGPoint
        //if in a circle, don't make a new note, instead just update one we are touching now
        for c in circles {
            loc = touch.locationInView(c)
            if c.pointInside(loc, withEvent: nil) {
                current_note = c.index
                no_delete_flag = true
                return
            }
        }
        loc = touch.locationInView(self.view)
        
        //if not in a circle, then go ahead
        createNote(loc)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touches ended")
        if no_delete_flag == true {
            no_delete_flag = false
        } else {
            deleteNote(current_note)
        }
    }
    
    func deleteNote(index: Int) {
        if current_note == -1 {
            println("trying to delete index -1")
            return
        }
        println("deleting note \(index) ")
        PdBase.sendList([index, pitch, 0], toReceiver: "pitch-vel")
        PdBase.sendList([index, 0], toReceiver: "amp")
        circles[index].removeFromSuperview()
        note_count--
        current_note = -1
    }
    
    func createNote(loc: CGPoint) {
        if note_count == 5 {
            //arbitrary max note count, probs should be global const or something TODO
            return
        }
        
        note_count++
        current_note = note_count - 1
        println("creating note \(current_note) ")
        
        //Create current note
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        PdBase.sendList([current_note, pitch, default_velocity], toReceiver: "pitch-vel")
        PdBase.sendList([current_note, calculateAmplification(loc.y, h: h)], toReceiver: "amp")
        
        // Create a new CircleView for current touch location
        var new_circle = CircleView(frame: CGRectMake(loc.x - 0.5 * CIRCLE_DIAMETER, loc.y - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: current_note, view_controller: self)
        circles[current_note] = new_circle
        view.addSubview(new_circle)
    }
    
    private func updateNote(loc: CGPoint) {
        if current_note == -1 {
            println("trying to update -1")
            return
        }
        //Update current note
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        if (loc.y < 0) {
            PdBase.sendList([current_note, pitch, 0], toReceiver: "pitch-vel")
            PdBase.sendList([current_note, 0], toReceiver: "amp")
        } else if (loc.x < 0) {
            PdBase.sendList([current_note, leftmost_note, default_velocity], toReceiver: "pitch-vel")
            PdBase.sendList([current_note, calculateAmplification(loc.y, h: h)], toReceiver: "amp")
        } else if (loc.x >= w) {
            PdBase.sendList([current_note, leftmost_note + 12, default_velocity], toReceiver: "pitch-vel")
            PdBase.sendList([current_note, calculateAmplification(loc.y, h: h)], toReceiver: "amp")
        } else {
            PdBase.sendList([current_note, pitch, default_velocity], toReceiver: "pitch-vel")
            PdBase.sendList([current_note, calculateAmplification(loc.y, h: h)], toReceiver: "amp")
        }
        
        //Move highlight
        var circle: CircleView = circles[current_note]
        circle.center.y = loc.y
        circle.center.x = loc.x
    }
    /*

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
        var circle_view = CircleView(frame: CGRectMake(loc.x - 0.5 * CIRCLE_DIAMETER, loc.y - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER))
        circles.append(circle_view);
        view.addSubview(circle_view)
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
        } else if (loc.x >= w) {
            PdBase.sendList([1, leftmost_note + 12, default_velocity], toReceiver: "pitch-vel")
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
 */
    
}

