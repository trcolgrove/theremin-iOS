//
//  BottomMenuController.swift
//  theremin
//
//  Created by Thomas Colgrove on 4/23/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import UIKit

class BottomMenuController: InstrumentViewController{
    
    var main_storyboard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
    
    var instrument_view: InstrumentViewController!
    
    var settings_control: SettingsViewController!
    var synth_control: SynthViewController!
    
    var current_control: UIViewController
    
    required init(coder aDecoder: NSCoder) {
        settings_control = main_storyboard.instantiateViewControllerWithIdentifier("SettingsView") as! SettingsViewController!
        synth_control = main_storyboard.instantiateViewControllerWithIdentifier("SynthView") as! SynthViewController!
        current_control = settings_control
    
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.view.addSubview(current_control.view)
        
        settings_control.container_view = self
        synth_control.container_view = self
        
        settings_control.instrument_view = instrument_view
        synth_control.instrument_view = instrument_view
        settings_control.knob_menu.instrument_view = instrument_view
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //nothing to do here
    }

    func displaySynth(){
        
        let transitionOptions = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(self.view, duration: 1.0, options: transitionOptions, animations: {
            self.view.addSubview(self.synth_control.view)
        }, completion: { finished in
            self.current_control.view.removeFromSuperview()
            self.current_control = self.synth_control
        })
       

    }

    func displaySettings(){
        let transitionOptions = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(self.view, duration: 1.0, options: transitionOptions, animations: {
            self.view.addSubview(self.settings_control.view)
            }, completion: { finished in
                self.current_control.view.removeFromSuperview()
                self.current_control = self.settings_control
        })

    }
}