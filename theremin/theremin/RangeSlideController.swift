//
//  RangeSlideController.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/5/15.
//  Implemented by Thomas Colgrove
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

protocol RangeSlideParentDelegate{
    func setRange(num_semitones: Int)
}

class RangeSlideController: InstrumentViewController {


    var leftmost_note: Int = 60
    //var key: String = ""
    var touch_origin: CGFloat = 0
    var pan_view: UIView = UIView()
    var container_delegate: RangeSlideParentDelegate? = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
        
    }
    
    func setRange(num_semitones:Int)
    {
        leftmost_note += num_semitones;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        println("Note View Controller is loaded");
    }
    

    //implement later
    /*
    @IBAction func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        
    }
    */
    
    
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        //boundschecking here
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
        self.setRange(Int(translation.x));
    }
    
}