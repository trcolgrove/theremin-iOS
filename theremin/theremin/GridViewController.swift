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
    let CIRCLE_DIAMETER: CGFloat = 50
    let MAX_NOTES = 5
    let default_velocity: Int = 40
    var circles: [CircleView] = []
    
    // Invariant: If the bool at index i is true if index i is currently being used, otherwise false
    var note_index_used: [Bool] = [false, false, false, false, false]
    
    // Invariant: If the bool at index i is true if note i is a sustain and currently being dragged,
    //            so we shouldn't delete it on touchesEnded
    var no_delete_flag: [Bool] = [false, false, false, false, false]
    
    // Keeps track of number of notes currently sounding
    var note_count = 0
    
    var lines: [GridLineView] = []
    var recorder : recordingProtocol?
    let halfstep_width: CGFloat = 72.5
    
    var note_dict : Dictionary<String, Int> = [:]
    

    var recording : [recData.sample]?
    var filter_index: Int = -1
    
    var w: CGFloat = 0
    var h: CGFloat = 0
    
    // used to move sustain notes on the screen
    
    
    // grid position
    @IBOutlet weak var grid_image: UIImageView!
    

    
    override func viewDidLoad() {
        //init 5 circles off screen
        initCircles()
    }
    
    //initialize all 5 CircleView objects off screen, with indices
    private func initCircles() {
        for i in 0...4 {
            circles.append(CircleView(frame: CGRectMake(-50000 - 0.5 * CIRCLE_DIAMETER, -50000 - 0.5 * CIRCLE_DIAMETER, CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: i, view_controller: self, isPlayback:false))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        w = self.view.frame.size.width
        h = self.view.frame.size.height
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
    
    // returns midi pitch note for given x coordinate in grid_image coordinates
    private func calculatePitch(x: CGFloat) -> CGFloat{
        return bottom_note + (x/halfstep_width)
    }
    
    private func getNextNoteIndex() -> Int {
        for i in 0...4 {
            if (note_index_used[i] == false) {
                note_index_used[i] = true
                return i
            }
        }
        return -1
    }
    
    override func deleteAllNotes(sender: AnyObject) {
        for i in 0...4 {
            if (note_index_used[i]) {
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
        if (no_delete_flag[index]) {
            no_delete_flag[index] = false
            return
        }
        if (!note_index_used[index]) {
            return
        }
        note_index_used[index] = false
        
        PdBase.sendList([index, 0], toReceiver: "pitch")
        PdBase.sendList([index, 0], toReceiver: "amp")
        
        circles[index].removeFromSuperview()
        note_count--
        recorder?.recordNote( CGPoint(x: 0,y: 0), command: recData.command.OFF, note_index: index)
    }

    // Creates a new note based on the location of the touch
    func createNote(loc: CGPoint, isPlayback: Bool) -> Int {
        if note_count == MAX_NOTES {
            return -1
        }
        
        //Create current note
        var new_index = getNextNoteIndex()
        note_count++
        
        PdBase.sendList([new_index, calculatePitch(loc.x)], toReceiver: "pitch")
        PdBase.sendList([new_index, calculateAmplification(loc.y)], toReceiver: "amp")
        
        // Create a new CircleView for current touch location
        var new_circle = CircleView(frame: CGRectMake(loc.x - (CIRCLE_DIAMETER * 0.5), loc.y - (CIRCLE_DIAMETER * 0.5), CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: new_index, view_controller: self, isPlayback: isPlayback)
        circles[new_index] = new_circle
        grid_image.addSubview(new_circle)
        
        recorder?.recordNote(loc, command: recData.command.ON, note_index: new_index)
        
        return new_index
    }
    
    //Updates the note with index to new pitch/volume based on loc
    private func updateNote(index: Int, loc: CGPoint) {
        if index == -1 {
            return
        }

        //convert to grid controller view to find main "bounds" of view
        var gv_pt = self.view.convertPoint(CGPoint(x: loc.x, y: loc.y), fromView: grid_image)
        
        //clipping bounds if not playback note
        if (!circles[index].is_playback) {
            gv_pt.x = gv_pt.x >= w ? w : gv_pt.x < 0 ? 0 : gv_pt.x
            gv_pt.y = gv_pt.y >= h ? h : gv_pt.y < 0 ? 0 : gv_pt.y
        }
        let gi_pt = grid_image.convertPoint(gv_pt, fromView: self.view)
        let pitch = calculatePitch(gi_pt.x)
        PdBase.sendList([index, calculatePitch(gi_pt.x)], toReceiver: "pitch")
        PdBase.sendList([index, calculateAmplification(gi_pt.y)], toReceiver: "amp")
        let circle: CircleView = circles[index]
        circle.center.x = gi_pt.x
        circle.center.y = gi_pt.y
        recorder?.recordNote(loc, command: recData.command.HOLD, note_index: index)
    }
    
    func pointerToString(objRef: AnyObject) -> String {
        let ptr: COpaquePointer =
        Unmanaged<AnyObject>.passUnretained(objRef).toOpaque()
        return "\(ptr)"
    }

/***************** Touch stuff ******************/

    
    // Creates new note if not touching existing note, otherwise makes that note current
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //stop scrolling on touch down
        (parentViewController as InstrumentViewController).disableScroll()
        
        //create notes
        for touch in touches {
            var loc: CGPoint
            var is_sustain: Bool = false
            //if in a sustain, don't make a new note, instead just update the one we are touching now
            for c in circles {
                loc = touch.locationInView(c)
                if c.pointInside(loc, withEvent: nil) {
                    note_dict[pointerToString(touch)] = c.index
                    is_sustain = true
                    //don't delete circle on touchup if first tap
                    no_delete_flag[c.index] = true
                    
                    break
                }
            }
            if (is_sustain) {
                continue
            }
            //if not in a sustain, then go ahead and create new note
            loc = touch.locationInView(grid_image)
            let index = createNote(loc, isPlayback: false)
            if (index != -1) {
                note_dict[pointerToString(touch)] = index
            }
        }
    }
    
   
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let touch_loc = touch.locationInView(grid_image)
            if let index = note_dict[pointerToString(touch)] {
                updateNote(index, loc: touch_loc)
            }
        }
    }
    

    
    // Stop playing the note if it wasn't a drag from a sustain
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            if (touch.tapCount >= 2) {
                if let index = note_dict[pointerToString(touch)]{
                    let c = circles[index]
                    var double_tap_rec = UITapGestureRecognizer(target: circles[c.index], action: "handleDoubleTap:")
                    double_tap_rec.numberOfTapsRequired = 2
                    c.addGestureRecognizer(double_tap_rec)
                    
                }
                // The view responds to the tap
                //don't delete
            } else {
                if let index = note_dict[pointerToString(touch)]{
                    deleteNote(index)
                }
            }
        }
        //enable scroll again on touch up
        if (event.allTouches()?.count == touches.count) {
            (parentViewController as InstrumentViewController).enableScroll()
        }
    }
    
    override func touchesCancelled(touches: NSSet, withEvent: UIEvent) {
        for touch in touches {
            if let index = note_dict[pointerToString(touch)] {
                deleteNote(index)
            }
        }
    }

    
    /*remove the grid lines from the gridview*/
    func removeGridLines(){
        for lineView : GridLineView in lines
        {
            lineView.removeFromSuperview()
        }
        lines = []
    }
    
    //draws grid lines on the diatonic notes of the scale
    func drawGridLines(){
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
        var index = userInfo["index"] as Int
        let pt = CGPoint(x: userInfo["x"] as CGFloat,y: userInfo["y"] as CGFloat)
        updateNote(index, loc: pt)
    }
    
    /* private wrapper for createNote, updates current note index for the purpose of recording */
    func createNoteWithIndex(timer: NSTimer){
        var userInfo = timer.userInfo as NSDictionary
        let pt = CGPoint(x: userInfo["x"] as CGFloat,y: userInfo["y"] as CGFloat)
        createNote(pt, isPlayback: true)
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



