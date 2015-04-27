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
                parent_vc.grid.y_axis_string = self.options[indexPath.row]
                parent_vc.y_effect.setTitle(self.options[indexPath.row], forState: UIControlState.Normal)
                self.dismissViewController()
            }
        } else if popoverType == "wave" {
            if let parent_vc = parent as? SynthViewController {
                
                // send pd the new waveform
                
                if (segue == "wave_osc1") {
                    parent_vc.wave_button_1.setTitle(self.options[indexPath.row], forState: UIControlState.Normal)
                    println("osc 1")
                } else if (segue == "wave_osc2") {
                    parent_vc.wave_button_2.setTitle(self.options[indexPath.row], forState: UIControlState.Normal)
                } else if (segue == "wave_osc3") {
                    parent_vc.wave_button_3.setTitle(self.options[indexPath.row], forState: UIControlState.Normal)
                }
                self.dismissViewController()
            }
        }
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}