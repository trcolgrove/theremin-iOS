//
//  RangeViewContainer.swift
//  theremin
//
//  Created by Thomas Colgrove on 2/16/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

protocol RangeViewDelegate{
    
}

class RangeViewContainerController: InstrumentViewController{
    
    var leftmost_note: Int = 60
    //var key: String = ""
    var touch_origin: CGFloat = 0
    
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
        
        println("\(self.view.bounds)")
        println("Grid View Controller is loaded");
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
