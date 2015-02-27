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
    var leftmost_note: CGFloat = 60.0
    var pitch: CGFloat = 60
    var vel: CGFloat = 5
    let CIRCLE_DIAMETER = CGFloat(50)
    let MAX_NOTES = 5
    var circles: [CircleView] = []
    var note_count = 0
    @IBOutlet var grid_view: UIView!
    
    //invariant: current_note is always the index of current touch, or -1 if no current touch
    var current_note = -1
    let pan_rec = UIPanGestureRecognizer()
    let double_touch_rec = UITapGestureRecognizer()
    
    var w: CGFloat = 0
    var h: CGFloat = 0
    
    //used as a hack to do moving of sustain notes
    //TODO make it not hacky
    var no_delete_flag: Bool = false
    
    // grid position
    @IBOutlet weak var grid_image: UIImageView!
    var grid_origin: CGFloat = 0
    let grid_width: CGFloat = 72.5

    override func viewDidLoad() {
        println("Grid View Controller is loaded");
        
        pan_rec.addTarget(self, action: "handlePan:")
        pan_rec.minimumNumberOfTouches = 1
        pan_rec.maximumNumberOfTouches = 1
        
        double_touch_rec.addTarget(self, action: "handleDoubleTap:")
        double_touch_rec.numberOfTapsRequired = 2
        double_touch_rec.cancelsTouchesInView = true
        
        //init 5 circles off screen
        for i in 0...4 {
            circles.append(CircleView(frame: CGRectMake(-500 - 0.5 * CIRCLE_DIAMETER, -500 - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: i, view_controller: self))
        }
        
        self.view.addGestureRecognizer(pan_rec)
        self.view.addGestureRecognizer(double_touch_rec)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        w = grid_view.frame.size.width
        h = grid_view.bounds.size.height
        println("w: \(w) h: \(h)")
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

    /* setRange
     * moves grid image to the left based on note view controller offset
     */
    override func setRange(note: CGFloat) {
        leftmost_note = note
        println("lmostnote", note)
        //changes the grid to wherever the new range is
        //var offset = (grid_origin + note_offset) % grid_width
        //var new_location = CGPoint(x: (grid_image.center.x + offset), y: grid_image.center.y)
        //grid_image.center = new_location
    }
    
    override func updateKey(key: String, notes: [Int]) {
        self.key = key
        println(notes)
    }
    
    func snapToGrid(note_offset: CGFloat) {
        // moves view's origin based on offset
        grid_origin = note_offset
    }
    
    // returns amplification level for current y value
    private func calculateAmplification(y: CGFloat) -> CGFloat{
        return 0.5 * y / h
    }
    
/***************** Touch stuff ******************/

    
    // Make sustain
    func handleDoubleTap(sender: UITapGestureRecognizer){
        //add gesture recognizer for tap on this circle
        var double_tap_rec = UITapGestureRecognizer(target: circles[current_note], action: "handleDoubleTap:")
        double_tap_rec.numberOfTapsRequired = 2
        double_tap_rec.cancelsTouchesInView = true
        circles[current_note].addGestureRecognizer(double_tap_rec)
    }
    
    // Handles updating sustains and just a normal drag
    func handlePan(sender: UIPanGestureRecognizer){
        var loc: CGPoint
        switch sender.state {
        case UIGestureRecognizerState.Began:
            loc = sender.locationOfTouch(0, inView: self.view)
            updateNote(loc)
        case UIGestureRecognizerState.Changed:
            loc = sender.locationOfTouch(0, inView: self.view)
            updateNote(loc)
        case UIGestureRecognizerState.Ended:
            if no_delete_flag == true {
                no_delete_flag = false
            } else {
                deleteNote(current_note)
            }
        case UIGestureRecognizerState.Cancelled:
            println("cancelled")
            if no_delete_flag == true {
                no_delete_flag = false
            } else {
                deleteNote(current_note)
            }
        default:
            println("ERROR: default switch case met")
        }
    }
   
    
    // Creates new note if not touching existing note, otherwise makes that note current
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject = touches.allObjects[0]
        var loc: CGPoint
        //if in a circle, don't make a new note, instead just update the one we are touching now
        for c in circles {
            loc = touch.locationInView(c)
            if c.pointInside(loc, withEvent: nil) {
                current_note = c.index
                no_delete_flag = true //don't delete circle after touch up
                return
            }
        }
        //if not in a circle, then go ahead and create new note
        loc = touch.locationInView(self.view)
        createNote(loc)
    }
    
    // Stop playing the note if it wasn't a drag from a sustain
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        //if no_delete_flag is true, we are dragging a sustain note, so we don't want to delete it
        if no_delete_flag == true {
            no_delete_flag = false
        } else {
            deleteNote(current_note)
        }
    }
    
    // Deletes note with the given index
    func deleteNote(index: Int) {
        if current_note == -1 {
            println("error: trying to delete index -1")
            return
        }
        PdBase.sendList([index, pitch, 0], toReceiver: "pitch-vel")
        PdBase.sendList([index, 0], toReceiver: "amp")
        circles[index].removeFromSuperview()
        note_count--
        current_note = -1 //no more current touch
    }
    
    // Creates a new note based on the location of the touch
    func createNote(loc: CGPoint) {
        if note_count == MAX_NOTES {
            return
        }
        
        //Create current note
        current_note = note_count
        note_count++
        pitch = CGFloat(leftmost_note) + (loc.x / w) * 12
        PdBase.sendList([current_note, pitch, default_velocity], toReceiver: "pitch-vel")
        PdBase.sendList([current_note, calculateAmplification(loc.y)], toReceiver: "amp")
        
        // Create a new CircleView for current touch location
        var new_circle = CircleView(frame: CGRectMake(loc.x - 0.5 * CIRCLE_DIAMETER, loc.y - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: current_note, view_controller: self)
        circles[current_note] = new_circle
        view.addSubview(new_circle)
    }
    
    //Updates the note with index current_note to new pitch/volume based on loc
    private func updateNote(loc: CGPoint) {
        if current_note == -1 {
            println("Internal error: trying to update -1")
            return
        }
        
        let clipped_x = loc.x >= w ? w : loc.x < 0 ? 0 : loc.x
        let clipped_y = loc.y >= h ? h : loc.y < 0 ? 0 : loc.y
        pitch = CGFloat(leftmost_note) + (clipped_x / w) * 12
        PdBase.sendList([current_note, pitch, default_velocity], toReceiver: "pitch-vel")
        PdBase.sendList([current_note, calculateAmplification(clipped_y)], toReceiver: "amp")
        let circle: CircleView = circles[current_note]
        circle.center.x = clipped_x
        circle.center.y = clipped_y
    }
    
}

