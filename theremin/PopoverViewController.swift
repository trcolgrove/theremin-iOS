//
//  PopoverViewController.swift
//  theremin
//
//  Created by McCall Bliss on 4/8/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class PopoverViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var options: [String]!
    
    var popoverType: String?
    var segue: String?
    
    var parent: AnyObject!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
            let cellIdentifier = "Cell"
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:
                indexPath) as! UITableViewCell
            cell.textLabel!.text = self.options[indexPath.row]
            return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if popoverType == "yeffect" {
            if let parent_vc = parent as? InstrumentViewController {
                let y_effect = self.options[indexPath.row]
                parent_vc.grid.y_axis_string = y_effect
                parent_vc.updateKnobs(y_effect)
                parent_vc.y_effect.setTitle(y_effect, forState: UIControlState.Normal)
            }
        } else if popoverType == "wave" {
            if let parent_vc = parent as? SynthViewController {
                
                let wave_form = self.options[indexPath.row]
                let pd_wave_name = parent_vc.getWaveName(indexPath.row)
                
                if (segue == "wave_osc1") {
                    println(pd_wave_name)
                    PdBase.sendList(["osc1", "set", pd_wave_name], toReceiver: "all")
                    parent_vc.wave_button_1.setTitle(wave_form, forState: UIControlState.Normal)
                } else if (segue == "wave_osc2") {
                    PdBase.sendList(["osc2", "set", pd_wave_name], toReceiver: "all")
                    parent_vc.wave_button_2.setTitle(wave_form, forState: UIControlState.Normal)
                } else if (segue == "wave_osc3") {
                    PdBase.sendList(["osc3", "set", pd_wave_name], toReceiver: "all")
                    println(pd_wave_name)
                    parent_vc.wave_button_3.setTitle(wave_form, forState: UIControlState.Normal)
                }
            }
        }
        self.dismissViewController()
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}