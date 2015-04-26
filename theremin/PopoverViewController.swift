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
    
    var parent: InstrumentViewController!
    
    override func viewDidLoad() {
        
    }
    
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
            parent.grid.y_axis_string = self.options[indexPath.row]
            parent.y_effect.setTitle(self.options[indexPath.row], forState: UIControlState.Normal)
        }
        self.dismissViewController()
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}