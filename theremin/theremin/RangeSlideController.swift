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
    //var key: String = ""
    var touch_origin: CGFloat = 0
    var pan_view: UIView = UIView()
    var container_delegate: RangeSlideParentDelegate!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
        
    }
    
    override func setRange(num_semitones:Int)
    {
        container_delegate.setRange(num_semitones)
    }

    override func viewDidLoad() {
        //super.viewDidLoad()
        println("RangeSlideContoller is loaded");
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
        if(translation.x < 0){
        self.setRange(1)
        }
        else{
        self.setRange (-1)
        }
    }
    
}