//
//  RangeViewContainer.swift
//  theremin
//
//  Created by Thomas Colgrove on 2/16/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

protocol RangeViewInstrument{
    func setRange(num_semitones:Int)
}

class RangeViewContainerController: InstrumentViewController, RangeSlideParentDelegate{
    
    var leftmost_note: Int = 60
    var touch_origin: CGFloat = 0
    var instrument: RangeViewInstrument? = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
    }
    

    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonPressed(sender: UIButton) {
    }
    func setRange(num_semitones: Int)
    {
        leftmost_note += num_semitones;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("\(self.view.bounds)")
        println("Grid View Controller is loaded");
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if segue.identifier == "setDelegate"{
            let range_control = segue.destinationViewController as RangeSlideController
            range_control.container_delegate = self
            println("ContainerDelegationSet")
        }
    }
    //implement later
    /*
    @IBAction func handleSwipe(recognizer: UISwipeGestureRecognizer) {
    
    }
    */
    
    @IBAction func handle_buttonpress(){
        self.setRange(8)
    }
    
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        //boundschecking here
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
        self.setRange(Int(translation.x));
    }
    
}
