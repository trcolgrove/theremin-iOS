//
//  GridViewController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

protocol recordingProtocol{
    func recordNote(pt: CGPoint, command: recData.command, note_index: Int)
    func doneRecording() -> [recData.sample]
}

class GridViewController: InstrumentViewController, UIScrollViewDelegate {
    let default_velocity: Int = 40
    var leftmost_note: CGFloat = 59.0
    let CIRCLE_DIAMETER: CGFloat = 50
    let MAX_NOTES = 5
    var circles: [CircleView] = []
    var circle_used: [Bool] = []
    var note_count = 0
    var lines: [GridLineView] = []
    var recorder : recordingProtocol?
    let halfstep_width: CGFloat = 72.5
    
    var recording : [recData.sample]?
    
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
            circle_used.append(false)
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
        leftmost_note = leftmost_note + (note_offset/halfstep_width )
    }
    
    override func updateKey(key: String, notes: [String]) {
        self.key = key
        if(lines != []){
            drawGridLines()
        }
    }
    
    // returns amplification level for current y value
    private func calculateAmplification(y: CGFloat) -> CGFloat{
        
        return 0.5 * (h - y) / h
    }
    
    private func calculatePitch(x: CGFloat) -> CGFloat{
        //println(x)
        return bottom_note + (x/halfstep_width)
    }
    
    private func getNextNoteIndex() -> Int {
        for i in 0...4 {
            if (circle_used[i] == false) {
                circle_used[i] = true
                return i
            }
        }
        return -1
    }
    
    override func deleteAllNotes(sender: AnyObject) {
        for i in 0...4 {
            if (circle_used[i]) {
                deleteNote(i)
            }
        }
    }
    
    // Deletes note with the given index
    func deleteNote(index: Int) {
        if index == -1 {
            println("Internal error: trying to delete note with index -1")
            return
        }
        PdBase.sendList([index, 0], toReceiver: "pitch")
        PdBase.sendList([index, 0], toReceiver: "amp")
        circles[index].removeFromSuperview()
        circle_used[index] = false
        note_count--
        current_note = -1 //no more current touch
        no_delete_flag = false
        recorder?.recordNote( CGPoint(x: 0,y: 0), command: recData.command.OFF, note_index: index)
    }

    
    // Creates a new note based on the location of the touch
    func createNote(loc: CGPoint) {
        if note_count == MAX_NOTES {
            no_delete_flag = true
            return
        }
        
        //Create current note
        current_note = getNextNoteIndex()
        note_count++
        
        PdBase.sendList([current_note, calculatePitch(loc.x)], toReceiver: "pitch")
        PdBase.sendList([current_note, calculateAmplification(loc.y)], toReceiver: "amp")
        
        // Create a new CircleView for current touch location
        var new_circle = CircleView(frame: CGRectMake(loc.x - (CIRCLE_DIAMETER * 0.5), loc.y - (CIRCLE_DIAMETER * 0.5), CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: current_note, view_controller: self)
         circles[current_note] = new_circle
         grid_image.addSubview(new_circle)
        
        recorder?.recordNote(loc, command: recData.command.ON, note_index: current_note)
    }
    
    //turn the grid on
    func gridOn(){
        drawGridLines()
    }
    
    //turn the grid off
    func gridOff(){
        removeGridLines()
    }
    
    /*remove the grid lines from the gridview*/
    private func removeGridLines(){
        for lineView : GridLineView in lines
        {
            lineView.removeFromSuperview()
        }
        lines = []
    }
    
    //draws grid lines on the diatonic notes of the scale
    private func drawGridLines(){
        removeGridLines()
        let oct_width = halfstep_width * 12
        for var oct : CGFloat = 0; oct < 4; oct++ { //octave
            for var sd = 0; sd < 7; sd++ { //scale degree
                let line_width: CGFloat = 3
                let line_height: CGFloat = 552
                let notes_in_key = key_map[key]!
                let note_name = notes_in_key[sd]
                let offset = CGFloat(note_positions[note_name]!)
                var line_loc : CGFloat = CGFloat(halfstep_width - line_width) + CGFloat(oct*oct_width + offset*halfstep_width)
                var line = GridLineView(frame: CGRectMake(line_loc, grid_image.frame.origin.y, line_width, line_height), view_controller: self)
                grid_image.addSubview(line)
                lines.append(line)
            }
        }
    }
    //Updates the note with index current_note to new pitch/volume based on loc
    private func updateNote(loc: CGPoint) {
        if current_note == -1 {
            println("Internal error: trying to update -1")
            return
        }
        var gv_pt = CGPoint(x: loc.x, y: loc.y)
        println(loc)
        gv_pt = grid_view.convertPoint(gv_pt, fromView: grid_image) //convert to grid controller view to find main "bounds" of view
        
        //clipping bounds
        gv_pt.x = gv_pt.x >= w ? w : gv_pt.x < 0 ? 0 : gv_pt.x
        gv_pt.y = gv_pt.y >= h ? h : gv_pt.y < 0 ? 0 : gv_pt.y
        let gi_pt = grid_image.convertPoint(gv_pt, fromView: grid_view)
        let pitch = calculatePitch(gi_pt.x)
        PdBase.sendList([current_note, calculatePitch(gi_pt.x)], toReceiver: "pitch")
        PdBase.sendList([current_note, calculateAmplification(gi_pt.y)], toReceiver: "amp")
        let circle: CircleView = circles[current_note]
        circle.center.x = gi_pt.x
        circle.center.y = gi_pt.y
        recorder?.recordNote(loc, command: recData.command.HOLD, note_index: current_note)
    }
    

/***************** Touch stuff ******************/

    
    // Make sustain
    func handleDoubleTap(sender: UITapGestureRecognizer){
        if (current_note == -1) {
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
        println("panning")
        var loc: CGPoint
        var img_loc: CGPoint
        switch sender.state {
        case UIGestureRecognizerState.Began:
            loc = sender.locationInView(grid_image)
            updateNote(loc)
        case UIGestureRecognizerState.Changed:
            loc = sender.locationInView(grid_image)
            println(loc.x)
            updateNote(loc)
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
        //(parentViewController as InstrumentViewController).disableScroll()
        
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
        loc = touch.locationInView(grid_image)
        createNote(loc)
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
    
/***************** Recording Functions ******************/
/* These functions interact with a recordingProtocol in */
/* order to create, and playback a detailed array of    */
/* samples. Samples are represented by a "sample" type  */
/* the definition of which can be found in the recData  */
/* class.                                                */

    
    /* public function, initiates the recorder object, beginning recording */
    func beginRecording(){
        recorder = record()
    }
    
    
    /* stops recording and gets the array of samples representing the current recording */
    func stopRecording(){
        recording = recorder?.doneRecording()
        println(recording)
        recorder = nil
    }
    
    /* private wrapper for updateNote, updates current note index for the purpose of recording*/
    func updateNoteWithIndex(timer: NSTimer){
        var userInfo = timer.userInfo as NSDictionary
        current_note = userInfo["index"] as Int
        let pt = CGPoint(x: userInfo["x"] as CGFloat,y: userInfo["y"] as CGFloat)
        updateNote(pt)
    }
    
    /* private wrapper for createNote, updates current note index for the purpose of recording */
    func createNoteWithIndex(timer: NSTimer){
        var userInfo = timer.userInfo as NSDictionary
        current_note = userInfo["index"] as Int
        let pt = CGPoint(x: userInfo["x"] as CGFloat,y: userInfo["y"] as CGFloat)
        createNote(pt)
    }
    
    /* private wrapper for deleteNote, updates current note index for the purpose of recording */
    func deleteNoteWithIndex(timer: NSTimer){
        var userInfo = timer.userInfo as NSDictionary
        let to_delete = userInfo["index"] as Int
        deleteNote(to_delete)
    }

    /* public function, plays back the current array of recorded samples */
    func playRecording(){
        for s in self.recording!{
            let params = ["index" : s.note_index, "x" : s.note_loc.x, "y" : s.note_loc.y]
            var timer = NSTimer()
            if(s.cmd == recData.command.ON){
                timer = NSTimer.scheduledTimerWithTimeInterval(s.elapsed_time, target: self, selector : Selector("createNoteWithIndex:"), userInfo: params, repeats: false)
            }
            else if(s.cmd == recData.command.OFF){
                timer = NSTimer.scheduledTimerWithTimeInterval(s.elapsed_time, target: self, selector : Selector("deleteNoteWithIndex:"), userInfo: params, repeats: false)
            }
            else if(s.cmd == recData.command.HOLD){
                timer = NSTimer.scheduledTimerWithTimeInterval(s.elapsed_time, target: self, selector : Selector("updateNoteWithIndex:"), userInfo: params, repeats: false)
            }
            else if(s.cmd == recData.command.SUS){
                
            }
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes) // use this so the NSTimer can execute concurrently with UIChanges
        }
    }

}



