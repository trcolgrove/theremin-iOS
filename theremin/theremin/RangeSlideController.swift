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

class RangeSlideController: InstrumentViewController, UIScrollViewDelegate {
    
    var container_delegate: RangeSlideParentDelegate!
    let slider_range : Int = 48
    let bottom_note : Int = 3
    var prev_offset : CGFloat  = 0
    
    @IBOutlet var scrollView: UIScrollView!
    
    var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
    }
    
    func shiftOctave(direction: String) {
        let octave_width: CGFloat = (12*72.5)
        var offset = scrollView.contentOffset
        if (direction == "left") {
            if (scrollView.contentOffset.x <= octave_width) {
                offset.x = 0
            } else {
                offset.x -= octave_width
            }
        } else {
            if (scrollView.contentOffset.x >= (imageView.frame.width - octave_width)) {
                offset.x += (imageView.frame.width - octave_width)
            } else {
                offset.x += octave_width
            }
        }
        self.scrollView.setContentOffset(offset, animated: true)
    }
    
    override func setRange(num_pixels: CGFloat)
    {
        container_delegate.setRange(num_pixels)
    }

    override func viewDidLoad() {
        drawSlider(UIImage(named: "note_slider.png")!)
    }
    
    
    func drawSlider(image: UIImage){
        let image = UIImage(named: "note_slider.png")!
        let hs_width = 145 //width of one half step
        let oct_width = hs_width*12
        var label_offset = 0
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: image.size.width, height: scrollView.frame.size.height))
        scrollView.addSubview(imageView)
        scrollView.contentSize = CGSizeMake(image.size.width,scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.delegate = self
        
        for var oct = 0; oct < 4; oct++ { //octave
            for var sd = 0; sd < 7; sd++ { //scale degree
                var keylist = key_map[key]!
                var accidental = keylist[sd]
                var note_name = note_names[(sd)*3 + accidental]
                var offset = note_positions[note_name]!
                var label_loc = imageView.frame.origin.x + 120 + CGFloat(oct*oct_width + offset*hs_width)
                var label = UILabel(frame: CGRectMake(0, 0, label_loc, imageView.frame.height))
                label.font = UIFont(name: "Helvetica-bold", size: 32.00)
                label.textColor = UIColor(white: 1, alpha: 1)
                label.center = CGPointMake(label_loc, imageView.frame.origin.y + 44)
                label.text = (note_name + String(oct+1))
                imageView.addSubview(label)
            }
        }
    }
    
    //takes key as a string and updates labels
    func updateNoteLabels(new_key:String)
    {
        key = new_key
        imageView.removeFromSuperview()
        drawSlider(UIImage(named: "note_slider.png")!)
    }
    
    /*changes the range of the instrument when called*/
    @IBAction func scrollViewDidScroll(scrollview: UIScrollView) {
        setRange(scrollview.contentOffset.x - prev_offset)
        prev_offset = scrollview.contentOffset.x
    }
}