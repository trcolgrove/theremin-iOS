//
//  GridViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class GridViewController: InstrumentViewController, UIScrollViewDelegate {
    let default_velocity: Int = 40
    var leftmost_note: CGFloat = 59.0
    let CIRCLE_DIAMETER: CGFloat = 50
    let MAX_NOTES = 5
    var circles: [CircleView] = []
    var note_count = 0
    var lines: [GridLineView] = []

    //var circles_view : UIView!
    @IBOutlet var grid_view: UIView!
    
    //invariant: current_note is always the index of current touch, or -1 if no current touch
    var current_note = -1
    let pan_rec = UIPanGestureRecognizer()
    let double_touch_rec = UITapGestureRecognizer()
    
    var w: CGFloat = 0
    var h: CGFloat = 0
    
    //used to move sustain notes
    var no_delete_flag: Bool = false
    
    // grid position
    @IBOutlet weak var grid_image: UIImageView!
    
    let GRID_WIDTH: CGFloat = 72.5

    override func viewDidLoad() {
        pan_rec.addTarget(self, action: "handlePan:")
        pan_rec.minimumNumberOfTouches = 1
        pan_rec.maximumNumberOfTouches = 1
        
        double_touch_rec.addTarget(self, action: "handleDoubleTap:")
        double_touch_rec.numberOfTapsRequired = 2
        double_touch_rec.cancelsTouchesInView = true
        
        //init 5 circles off screen
        initCircles()
        self.view.addGestureRecognizer(pan_rec)
        self.view.addGestureRecognizer(double_touch_rec)
    }
    
    //initialize all 5 CircleView objects off screen, with indices
    private func initCircles() {
        for i in 0...4 {
            circles.append(CircleView(frame: CGRectMake(-50000 - 0.5 * CIRCLE_DIAMETER, -50000 - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: i, view_controller: self))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        w = grid_view.frame.size.width
        h = grid_view.bounds.size.height
    }
    
    /*this function sets up delegation/communication between RangeViewContainerController and
    GridViewController at runtime*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "grid_init"{
            let range_controller = segue.destinationViewController as RangeViewContainerController
            range_controller.instrument = self
        }
    }

    /* setRange
     * moves grid image to the left based on note view controller offset
     */
    override func setRange(note_offset: CGFloat) {
        grid_image.frame = CGRectMake(grid_image.frame.origin.x - note_offset, grid_image.frame.origin.y, grid_image.frame.width, grid_image.frame.height)
        leftmost_note = leftmost_note + (note_offset/GRID_WIDTH)
    }
    
    override func updateKey(key: String, notes: [Int]) {
        self.key = key
        if(lines != []){
            drawGridLines()
        }
    }
    
    // returns amplification level for current y value
    private func calculateAmplification(y: CGFloat) -> CGFloat{
        return 0.5 * y / h
    }
    
    private func calculatePitch(x: CGFloat) -> CGFloat{
        return leftmost_note + (x / w) * 12
    }
    
/***************** Touch stuff ******************/

    
    // Make sustain
    func handleDoubleTap(sender: UITapGestureRecognizer){
        if (current_note == -1 || note_count == MAX_NOTES) {
            return
        }
        //add gesture recognizer for tap on this circle
        var double_tap_rec = UITapGestureRecognizer(target: circles[current_note], action: "handleDoubleTap:")
        double_tap_rec.numberOfTapsRequired = 2
        //double_tap_rec.cancelsTouchesInView = true
        circles[current_note].addGestureRecognizer(double_tap_rec)
        current_note = -1
        no_delete_flag = false
    }
    
    // Handles updating sustains and just a normal drag
    func handlePan(sender: UIPanGestureRecognizer){
        var loc: CGPoint
        var img_loc: CGPoint
        switch sender.state {
        case UIGestureRecognizerState.Began:
            loc = sender.locationOfTouch(0, inView: self.view)
            img_loc = sender.locationOfTouch(0, inView: grid_image)
            updateNote(loc, img_loc: img_loc)
        case UIGestureRecognizerState.Changed:
            loc = sender.locationOfTouch(0, inView: self.view)
            img_loc = sender.locationOfTouch(0, inView: grid_image)
            updateNote(loc, img_loc: img_loc)
        case UIGestureRecognizerState.Ended:
            if no_delete_flag == true {
                no_delete_flag = false
            } else {
                deleteNote(current_note)
            }
        case UIGestureRecognizerState.Cancelled:
            if no_delete_flag == true {
                no_delete_flag = false
            } else {
                deleteNote(current_note)
            }
        default:
            println("Internal error: default switch case met in GridViewController.handlePan()")
        }
    }
   
    
    // Creates new note if not touching existing note, otherwise makes that note current
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //stop scrolling on touch down
        (parentViewController as InstrumentViewController).disableScroll()
        
        let touch: AnyObject = touches.allObjects[0]
        var loc: CGPoint
        var img_loc: CGPoint
        
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
        img_loc = touch.locationInView(grid_image)
        loc = touch.locationInView(self.view)
        createNote(loc, img_loc: img_loc)
    }
    

    
    // Stop playing the note if it wasn't a drag from a sustain
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if (current_note == -1) {
            return
        }
        //if no_delete_flag is true, we are dragging a sustain note, so we don't want to delete it
        if no_delete_flag == true {
            no_delete_flag = false
        } else {
            deleteNote(current_note)
        }
        
        //enable scroll again on touch up
        (parentViewController as InstrumentViewController).enableScroll()
    }
    
    // Deletes note with the given index
    func deleteNote(index: Int) {
        if current_note == -1 {
            println("Internal error: trying to delete note with index -1")
            return
        }
        PdBase.sendList([index, 0], toReceiver: "pitch")
        PdBase.sendList([index, 0], toReceiver: "amp")
        circles[index].removeFromSuperview()
        note_count--
        current_note = -1 //no more current touch
        no_delete_flag = false
    }

    
    // Creates a new note based on the location of the touch
    func createNote(loc: CGPoint, img_loc: CGPoint) {
        if note_count == MAX_NOTES {
            return
        }
        
        //Create current note
        current_note = note_count
        note_count++
        
        PdBase.sendList([current_note, calculatePitch(loc.x)], toReceiver: "pitch")
        PdBase.sendList([current_note, calculateAmplification(loc.y)], toReceiver: "amp")
        
        // Create a new CircleView for current touch location
        var new_circle = CircleView(frame: CGRectMake(img_loc.x - 0.5 * CIRCLE_DIAMETER, img_loc.y - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: current_note, view_controller: self)
        circles[current_note] = new_circle
        grid_image.addSubview(new_circle)
    }
    
    func gridOff(){
        removeGridLines()
    }
    
    func gridOn(){
        drawGridLines()
    }
    
    private func removeGridLines(){
        for lineView : GridLineView in lines
        {
            lineView.removeFromSuperview()
        }
        lines = []
    }
    private func drawGridLines(){
        removeGridLines()
        let hs_width : CGFloat = GRID_WIDTH //width of one half step
        let oct_width = hs_width * 12
        for var oct : CGFloat = 0; oct < 4; oct++ { //octave
            for var sd = 0; sd < 7; sd++ { //scale degree
                let line_width: CGFloat = 3
                let line_height: CGFloat = 552
                var keylist = key_map[key]!
                var accidental = keylist[sd]
                var note_name = note_names[(sd)*3 + accidental]
                var offset : CGFloat = CGFloat(note_positions[note_name]!)
                var line_loc : CGFloat = CGFloat(GRID_WIDTH - line_width) + CGFloat(oct*oct_width + offset*hs_width)
                var line = GridLineView(frame: CGRectMake(line_loc, grid_image.frame.origin.y, line_width, line_height), view_controller: self)
                grid_image.addSubview(line)
                lines.append(line)
            }
        }
    }
    //Updates the note with index current_note to new pitch/volume based on loc
    private func updateNote(loc: CGPoint, img_loc: CGPoint) {
        if current_note == -1 {
            println("Internal error: trying to update -1")
            return
        }
        let clipped_x = loc.x >= w ? w : loc.x < 0 ? 0 : loc.x
        let clipped_y = loc.y >= h ? h : loc.y < 0 ? 0 : loc.y
        let pitch = calculatePitch(clipped_x)
        PdBase.sendList([current_note, calculatePitch(clipped_x)], toReceiver: "pitch")
        PdBase.sendList([current_note, calculateAmplification(clipped_y)], toReceiver: "amp")
        let circle: CircleView = circles[current_note]
        var pt = CGPoint(x: clipped_x, y: clipped_y)
        pt = grid_image.convertPoint(pt, fromView: self.view)
        circle.center.x = pt.x
        circle.center.y = pt.y
    }
    
}

