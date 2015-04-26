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
    func loop()  -> [recData.sample]

}

class GridViewController: InstrumentViewController, UIScrollViewDelegate {
    
    let CIRCLE_DIAMETER: CGFloat = 50
    let MAX_QUANTIZE_LEVEL: CGFloat = 10
    let MAX_NOTES = 10
    let default_velocity: Int = 40
    let velocity = 100
    
    var circles: [CircleView] = []
    var inPlayback = false;
    // Invariant: If the bool at index i is true if index i is currently being used, otherwise false
    var note_index_used: [Bool] = []
   
    var loop_timer : NSTimer?
    // Invariant: If the bool at index i is true if note i is a sustain and currently being dragged,
    //            so we shouldn't delete it on touchesEnded
    var no_delete_flag: [Bool] = []
    // Keeps track of number of notes currently sounding
    var note_count = 0
    
    var lines : [GridLineView] = []
    var recorder : recordingProtocol?
    let halfstep_width: CGFloat = 72.5
    var quantize_level: CGFloat = 0
    var quantize_width: CGFloat = 0
    
    var recordingIndex = 0;
    
    var note_dict : Dictionary<String, Int> = [:]
    var filter_index: Int = -1
    
    var pause_state : [CGPoint] = []
    var rec_length : Int = 0
    var timers : [NSTimer] = []
    var recording : [recData.sample]?
    var pause_time : NSTimeInterval = 0
    
    
    
    var w: CGFloat = 0
    var h: CGFloat = 0
    
    // used to move sustain notes on the screen
    
    
    // grid position
    @IBOutlet weak var grid_image: UIImageView!
    

    required init(coder aDecoder: NSCoder) {
        for i in 0..<MAX_NOTES {
            note_index_used.append(false);
            no_delete_flag.append(false);
        }
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        //init 5 circles off screen
        initCircles()
    }
    
    //initialize all 5 CircleView objects off screen, with indices
    private func initCircles() {
        for i in 0..<MAX_NOTES {
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
            let range_controller = segue.destinationViewController as! RangeViewContainerController
            range_controller.instrument = self
        }
    }

    /* setRange
     * moves grid image to the left based on note view controller offset
     */
    override func setRange(note_offset: CGFloat) {
        grid_image.frame = CGRectMake(grid_image.frame.origin.x - note_offset, grid_image.frame.origin.y, grid_image.frame.width, grid_image.frame.height)
        for i in 0..<MAX_NOTES{
            if(note_index_used[i]){
                updateNote(i, loc: CGPoint(x: circles[i].center.x + note_offset, y: circles[i].center.y) , isPlayback: false)
            }
        }
    }
    
    override func updateKey(key: String, notes: [String]) {
        self.key = key
        if(lines != []){
            drawGridLines()
        }
    }
    
    override func updateQuantizeLevel(level: Float){
        quantize_level = CGFloat(level)
        quantize_width = (quantize_level / MAX_QUANTIZE_LEVEL) * halfstep_width/2
        if (lines != []) {
            drawGridLines()
        }
    }
    
    // returns amplification level for current y value
    private func calculateAmplification(y: CGFloat) -> CGFloat{
        return 0.5 * (h - y) / h
    }
    
    private func getDiatonicNoteAboveX(x: CGFloat) -> CGFloat {
        var closest_x_above: CGFloat = 1000000
        let oct_width = halfstep_width * 12
        for var oct : CGFloat = 3; oct >= 0; oct-- { //octave
            for var sd = 6; sd >= 0; sd-- { //scale degree
                let notes_in_key = key_map[key]!
                let note_name = notes_in_key[sd]
                let offset = CGFloat(note_positions[note_name]!)
                let note_x = halfstep_width + CGFloat(oct*oct_width + offset*halfstep_width)
                
                if (note_x > x && note_x < closest_x_above) {
                    closest_x_above = note_x
                }
            }
        }
        return closest_x_above
    }
    
    private func getDiatonicNoteBelowX(x: CGFloat) -> CGFloat {
        
        var closest_x_below: CGFloat = 0.0
        let oct_width = halfstep_width * 12
        for var oct : CGFloat = 0; oct < 4; oct++ { //octave
            for var sd = 0; sd < 7; sd++ { //scale degree
                let notes_in_key = key_map[key]!
                let note_name = notes_in_key[sd]
                let offset = CGFloat(note_positions[note_name]!)
                let note_x = halfstep_width + CGFloat(oct*oct_width + offset*halfstep_width)
                
                if (note_x < x && note_x > closest_x_below) {
                    closest_x_below = note_x
                }
            }
        }
        return closest_x_below
    }
    
    // returns midi pitch note for given x coordinate in grid_image coordinates
    private func calculatePitch(x: CGFloat) -> CGFloat{
        if quantize_level > 0 {
            let exact_pitch = bottom_note + x/halfstep_width
            let x_note_above: CGFloat = getDiatonicNoteAboveX(x)
            let x_note_below: CGFloat = getDiatonicNoteBelowX(x)
            
            if (x - x_note_below <= quantize_width) {
                return bottom_note + x_note_below/halfstep_width
            }
            
            if (x_note_above - x <= quantize_width) {
                return bottom_note + x_note_above/halfstep_width
            }
            
            // Calculate pitch based on distance between quantized zones
            let bend_distance = (x_note_above - quantize_width) - (x_note_below + quantize_width)
            let bend_note_count = (x_note_above - x_note_below) / halfstep_width
            return bottom_note + x_note_below/halfstep_width + ((x - (x_note_below + quantize_width)) / bend_distance) * bend_note_count
        } else {
            return bottom_note + x/halfstep_width
        }
    }
    
    private func getNextNoteIndex() -> Int {
        for i in 0..<MAX_NOTES {
            if (note_index_used[i] == false) {
                note_index_used[i] = true
                return i
            }
        }
        return -1
    }
    
    func deleteAllNotes() {
        for i in 0..<MAX_NOTES {
            if (note_index_used[i]) {
                deleteNote(i, isPlayback:true)
            }
        }
    }
    
    // Deletes note with the given index
    func deleteNote(index: Int, isPlayback: Bool) {
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
        
        PdBase.sendList([index, 60, 0], toReceiver: "note")
        PdBase.sendList([index, "volume", 0], toReceiver: "note")
        
        circles[index].removeFromSuperview()
        note_count--
        
        if(!isPlayback){
        recorder?.recordNote( CGPoint(x: 0,y: 0), command: recData.command.OFF, note_index: index)
        }
    }

    // Creates a new note based on the location of the touch
    func createNote(loc: CGPoint, isPlayback: Bool) -> Int {
        if note_count == MAX_NOTES {
            return -1
        }
        
        //Create current note
        var new_index = getNextNoteIndex()
        note_count++
        
        PdBase.sendList([new_index, calculatePitch(loc.x), velocity], toReceiver: "note")
        PdBase.sendList([new_index, "volume", calculateAmplification(loc.y)], toReceiver: "note")
        
        // Create a new CircleView for current touch location
        var new_circle = CircleView(frame: CGRectMake(loc.x - (CIRCLE_DIAMETER * 0.5), loc.y - (CIRCLE_DIAMETER * 0.5), CIRCLE_DIAMETER, CIRCLE_DIAMETER), i: new_index, view_controller: self, isPlayback: isPlayback)
        circles[new_index] = new_circle
        grid_image.addSubview(new_circle)
        
        if(!isPlayback){
        recorder?.recordNote(loc, command: recData.command.ON, note_index: new_index)
        }
        return new_index
    }
    
    //Updates the note with index to new pitch/volume based on loc
    private func updateNote(index: Int, loc: CGPoint, isPlayback: Bool) {
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
        PdBase.sendList([index, calculatePitch(gi_pt.x), velocity], toReceiver: "note")
        PdBase.sendList([index, "volume", calculateAmplification(gi_pt.y)], toReceiver: "note")
        let circle: CircleView = circles[index]
        circle.center.x = gi_pt.x
        circle.center.y = gi_pt.y
        
        if(!isPlayback){
        recorder?.recordNote(loc, command: recData.command.HOLD, note_index: index)
        }
    }
    
    // thx stackoverflow: http://stackoverflow.com/questions/24188405/get-object-pointers-memory-address-as-a-string
    func pointerToString(objRef: AnyObject) -> String {
        let ptr: COpaquePointer =
        Unmanaged<AnyObject>.passUnretained(objRef).toOpaque()
        return "\(ptr)"
    }

/***************** Touch stuff ******************/

    
    // Creates new note if not touching existing note, otherwise makes that note current
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //stop scrolling on touch down
        (parentViewController as! InstrumentViewController).disableScroll()
        
        //create notes
        for t in touches {
            let touch = t as! UITouch
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
    
   
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch
            let touch_loc = touch.locationInView(grid_image)
            if let index = note_dict[pointerToString(touch)] {
                updateNote(index, loc: touch_loc, isPlayback: false)
            }
        }
    }
    

    
    // Stop playing the note if it wasn't a drag from a sustain
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch
            /*if (touch.tapCount >= 2) {
                if let index = note_dict[pointerToString(touch)]{
                    let c = circles[index]
                    //var double_tap_rec = UITapGestureRecognizer(target: circles[c.index], action: "handleDoubleTap:")
                    //double_tap_rec.numberOfTapsRequired = 2
                    //c.addGestureRecognizer(double_tap_rec)
                    
                }
            */
                // The view responds to the tap
                //don't delete
          //  } else {
                if let index = note_dict[pointerToString(touch)]{
                    deleteNote(index, isPlayback: false)
           //     }
            }
        }
        //enable scroll again on touch up
        if (event.allTouches()?.count == touches.count) {
            (parentViewController as! InstrumentViewController).enableScroll()
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent: UIEvent) {
        // Multitouching gestures got in the way
        if touches.count == 4 || touches.count == 5 {
            let alert: UIAlertController = UIAlertController(title: "Oops!", message: "Looks like you have multitasking gestures enabled, and it just interfered with your playing. You can fix this problem by disabling them at Settings > General > Multitasking Gestures", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        for touch in touches {
            if let index = note_dict[pointerToString(touch)] {
                deleteNote(index, isPlayback: false)
            }
        }
    }

    
    /*remove the grid lines from the gridview*/
    override func removeGridLines(){
        for lineView : GridLineView in lines
        {
            lineView.removeFromSuperview()
        }
        lines = []
    }
    
    //draws grid lines on the diatonic notes of the scale
    override func drawGridLines(){
        removeGridLines()
        let oct_width = halfstep_width * 12
        for var oct : CGFloat = 0; oct < 4; oct++ { //octave
            for var sd = 0; sd < 7; sd++ { //scale degree
                let line_width: CGFloat = 3 + (quantize_width * 2)
                let line_height: CGFloat = 552
                let notes_in_key = key_map[key]!
                let note_name = notes_in_key[sd]
                let offset = CGFloat(note_positions[note_name]!)
                var line_loc : CGFloat = CGFloat(halfstep_width - line_width) + CGFloat(oct*oct_width + offset*halfstep_width) + quantize_width + 1.5
                var line = GridLineView(frame: CGRectMake(line_loc, grid_image.frame.origin.y, line_width, line_height), view_controller: self)
                grid_image.addSubview(line)
                lines.append(line)
            }
        }
    }
    
    
    // MARK - Recording functions
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
    
    func loopRecording(){
        var loopTime = -((recorder! as! record).beginTime.timeIntervalSinceNow)
        recording = recorder?.loop()
        println(loopTime)
        loop_timer = NSTimer.scheduledTimerWithTimeInterval(loopTime, target: self, selector : Selector("updateLoop"), userInfo: nil,  repeats: true)
        NSRunLoop.currentRunLoop().addTimer(loop_timer!, forMode: NSRunLoopCommonModes)
        playRecording()
    }
    
    func updateLoop(){
        recording = recorder?.loop()
        stopPlayback()
        playRecording()
    }
    
    /* stops recording and gets the array of samples representing the current recording */
    func stopRecording(){
        recording = recorder?.doneRecording()
        loop_timer?.invalidate()
        recorder = nil
    }
    
    /* private wrapper for updateNote, updates current note index for the purpose of recording*/
    func updateNoteWithIndex(timer: NSTimer){
        var userInfo = timer.userInfo as! NSDictionary
        var index = userInfo["index"] as! Int
        let pt = CGPoint(x: userInfo["x"] as! CGFloat,y: userInfo["y"] as! CGFloat)
        updateNote(index, loc: pt, isPlayback: true)
        recordingIndex++
        if(recordingIndex == rec_length){
            recordingIndex = 0
            inPlayback = false
            pause_time = 0
            (parentViewController as! InstrumentViewController).resetPlayButton()
        }
    }
    
    /* private wrapper for createNote, updates current note index for the purpose of recording */
    func createNoteWithIndex(timer: NSTimer){
        var userInfo = timer.userInfo as! NSDictionary
        let pt = CGPoint(x: userInfo["x"] as! CGFloat,y: userInfo["y"] as! CGFloat)
        createNote(pt, isPlayback: true)
        recordingIndex++
        if(recordingIndex == rec_length){
            recordingIndex = 0
            inPlayback = false
            pause_time = 0
            (parentViewController as! InstrumentViewController).resetPlayButton()
        }
    }
    
    /* private wrapper for deleteNote, updates current note index for the purpose of recording */
    func deleteNoteWithIndex(timer: NSTimer){
        var userInfo = timer.userInfo as! NSDictionary
        let to_delete = userInfo["index"] as! Int
        deleteNote(to_delete, isPlayback: true)
        recordingIndex++
        if(recordingIndex == rec_length){
            recordingIndex = 0
            inPlayback = false
            pause_time = 0
            (parentViewController as! InstrumentViewController).resetPlayButton()
        }
    }

    
    func pausePlayback(){
        for timer in timers {
            timer.invalidate()
        }
        for i in 0..<MAX_NOTES{
            if note_index_used[i] == true {
                var loc = circles[i].center
                pause_state.append(loc)
            }
        }
        timers = []
        self.deleteAllNotes()
        inPlayback = false
        pause_time = recording![recordingIndex].elapsed_time
    }
    
    func stopPlayback(){
        for timer in timers {
            timer.invalidate()
        }
        self.deleteAllNotes()
        recordingIndex = 0
    }
    
     func resetPlayButton(observer: CFRunLoopObserver!, activity: CFRunLoopActivity) -> (Void) {
        (parentViewController as! InstrumentViewController).resetPlayButton()
        return
    }
    
    
    /* public function, plays back the current array of recorded samples */
    func playRecording(){
        deleteAllNotes()
        inPlayback = true
        for loc in pause_state {
            createNote(loc, isPlayback : true)
        }
        pause_state = []
        rec_length = recording!.count
        for var i = recordingIndex; i < rec_length; i++ {
            var s = recording![i];
            let params = ["index" : s.note_index, "x" : s.note_loc.x, "y" : s.note_loc.y]
            var timer = NSTimer()
            var fireAfter = s.elapsed_time - pause_time
            if(s.cmd == recData.command.ON){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("createNoteWithIndex:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            else if(s.cmd == recData.command.OFF){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("deleteNoteWithIndex:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            else if(s.cmd == recData.command.HOLD){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("updateNoteWithIndex:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            else if(s.cmd == recData.command.SUS){
                
            }
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes) // use this so the NSTimer can execute concurrently with UIChanges
            
            
        }
        
    }
}



