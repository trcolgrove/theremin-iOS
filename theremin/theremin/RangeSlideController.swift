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
    
    let halfstep_width = 145 //width in pixels of one half step
    let oct_width = 145*12 //width in pixels of one octave
    
    let image = UIImage(named: "note_slider.png")!
    
    var container_delegate: RangeSlideParentDelegate! //Delegate for the range slide controller
    
    var prev_offset : CGFloat = 0 //stores a previous offset of the slider, to calculate the offset change on drag
    
    var note_labels : [UILabel] = []
    @IBOutlet var scrollView: UIScrollView! //View for the slider
    
    var imageView: UIImageView! //main image view for the slider
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        key = "CMajor"
    }
    
    /*function used on button press to shift the range of the theremin by 1 octave
      string "direction" indicates the direction of the shift*/
    func shiftOctave(direction: String) {
        let octave_width: CGFloat = (12*72.5)
        var offset = scrollView.contentOffset
        if (direction == "left") {
            if (scrollView.contentOffset.x <= octave_width) {
                offset.x = 0
            } else {
                offset.x -= octave_width
            }
        } else if (direction == "right"){
            // offset remains as old offset, so have to check with (octave_width * 2)
            if (scrollView.contentOffset.x >= (imageView.frame.width - (octave_width * 2))) {
                offset.x = ((imageView.frame.width) - octave_width)
            } else {
                offset.x += octave_width
            }
        } else{
            println("error: unsupported direction");
        }
        self.scrollView.setContentOffset(offset, animated: true)
    }
    
    /*changes the range of the instrument controlled by slider by num_pixels*/
    override func setRange(num_pixels: CGFloat)
    {
        container_delegate.setRange(num_pixels)
    }

    /*draws the slider after loading the view*/
    override func viewDidLoad() {
        drawSlider()
    }
    
    /*draws the main slider object*/
    func drawSlider(){
        var label_offset = 0
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: image.size.width, height: scrollView.frame.size.height))
        scrollView.addSubview(imageView)
        scrollView.contentSize = CGSizeMake(image.size.width,scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.delegate = self
        drawSliderLabels();
    }
    
    /*draws Slider note labels based on the current 'key' value*/
    func drawSliderLabels(){
        for var oct = 0; oct < num_oct; oct++ { //octave
            for var sd = 0; sd < 7; sd++ { //scale degree
                var keylist = key_map[key]!
                var accidental = keylist[sd]
                var note_name = note_names[(sd)*3 + accidental]
                var offset = note_positions[note_name]!
                var label_loc = imageView.frame.origin.x + 120 + CGFloat(oct*oct_width + offset*halfstep_width)
                var label = UILabel(frame: CGRectMake(0, 0, label_loc, imageView.frame.height))
                label.font = UIFont(name: "Helvetica-bold", size: 32.00)
                label.textColor = UIColor(white: 1, alpha: 1)
                label.center = CGPointMake(label_loc, imageView.frame.origin.y + 44)
                label.text = (note_name + String(oct+3))
                imageView.addSubview(label)
                note_labels.append(label)
            }
        }
    }
    /*Arguments: new_key, the name of the new key*/
    /*Contract: sets the value of 'key' to the argument "new_key",
    and redraws labels in the new key*/
    func updateNoteLabels(new_key:String)
    {
        key = new_key
        
        //remove all current labels before redrawing
        for label in note_labels{
            label.removeFromSuperview()
        }
        
        drawSliderLabels()
    }
    
    /*changes the range of the instrument when called*/
    @IBAction func scrollViewDidScroll(scrollview: UIScrollView) {
        setRange(scrollview.contentOffset.x - prev_offset)
        prev_offset = scrollview.contentOffset.x
    }
}