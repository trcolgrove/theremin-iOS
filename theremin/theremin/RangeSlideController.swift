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
    func setRange(num_semitones: CGFloat)
}

class RangeSlideController: InstrumentViewController {
    var touch_origin: CGFloat = 0
    var pan_view: UIView = UIView()
    var container_delegate: RangeSlideParentDelegate!
    let slider_range : Int = 48
    let bottom_note : Int = 36
    
    
    @IBOutlet var scrollView: UIScrollView!
    
    var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
    }
    
    override func setRange(num_semitones:CGFloat)
    {
        container_delegate.setRange(num_semitones)
    }

    override func viewDidLoad() {
        //super.viewDidLoad()
        println("RangeSlideContoller is loaded \(self.view.frame.size) \(self.view.frame.size)")
        drawSlider(UIImage(named: "note_slider.png")!)
    }
    
    
    //implement later
    /*
    @IBAction func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        
    }
    */
    func drawSlider(image: UIImage){
        let image = UIImage(named: "note_slider.png")!
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: image.size.width, height: scrollView.frame.size.height))
        scrollView.addSubview(imageView)
        scrollView.contentSize = CGSizeMake(image.size.width,scrollView.frame.size.height)
        
        for var i = 0; i < 100; i++ {
            var label_loc = imageView.frame.origin.x + CGFloat(i*150)
            println(imageView.frame.size.height)
            var label = UILabel(frame: CGRectMake(0, 0, label_loc, imageView.frame.height))
            label.font = UIFont(name: "Helvetica-bold", size: 32.00)
            label.textColor = UIColor(white: 1, alpha: 1)
            label.center = CGPointMake(label_loc, imageView.frame.origin.y + 44)
            var keylist = key_map[key]!
            var offset = keylist[i%7]
            var note_name = note_names[(i%7)*3 + offset]
            label.text = note_name
            imageView.addSubview(label)
        }
        
        
    }

    
    //takes key as a string and updates labels
    func updateNoteLabels(new_key:String)
    {
        key = new_key
        drawSlider(UIImage(named: "note_slider.png")!)
    }
    
    
    /*changes the range of the instrument when called*/
    
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        //boundschecking here
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y)
       
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        self.setRange((translation.x/1024.0)*12)
    
    }
}