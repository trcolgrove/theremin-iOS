//
//  RecordViewController.swift
//  theremin
//
//  Created by Daniel Defossez on 4/6/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class RecordViewController : UIViewController {
    
    @IBOutlet var record_image: UIImageView!
    @IBOutlet weak var play_image: UIImageView!

    var currently_recording: Bool = false
    var inPlayback : Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func recordButtonPressed(sender: UIView) {
        if (currently_recording) {
            currently_recording = false
            record_image.image = UIImage(named: "record-button.png")
        } else {
            currently_recording = true
            record_image.image = UIImage(named: "record-in-progress.png")
        }
        (parentViewController as InstrumentViewController).recordButtonPressed(sender)
    }
    
    @IBAction func stopButtonPressed(sender: UIView) {
        record_image.image = UIImage(named: "record-button.png")
        currently_recording = false
        (parentViewController as InstrumentViewController).stopButtonPressed(sender)
    }
    
    @IBAction func playButtonPressed(sender: UIView) {
        if(inPlayback){
            play_image.image = UIImage(named: "play-button-free-record.png")
            inPlayback = false
        }
        else{
            play_image.image = UIImage(named: "pause-button.png")
            inPlayback = true
        }
        
        (parentViewController as InstrumentViewController).playButtonPressed(sender)
    }
    
}