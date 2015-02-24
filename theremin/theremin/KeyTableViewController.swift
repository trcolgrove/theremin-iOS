//
//  KeyTableViewController.swift
//  theremin
//
//  Created by McCall Bliss on 2/16/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class KeyTableViewController: InstrumentViewController, UITableViewDataSource, UITableViewDelegate {
    
    // choices for key change
    var key_names = ["CMajor", "CMinor", "C#Minor", "DbMajor", "DMajor", "DMinor", "D#Minor", "EbMajor", "EbMinor", "EMajor", "EMinor", "FMajor", "FMinor", "F#Major", "F#Minor", "GbMajor", "GMajor", "GMinor", "G#Minor", "AbMajor",  "AMajor", "AMinor", "BbMajor", "BbMinor", "BMajor", "BMinor"]
    
    var parent:InstrumentViewController!
    
    override func viewDidLoad() {
        println("KeyViewController did load")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return key_names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
                                                                           UITableViewCell {
        let cellIdentifier = "Cell"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:
        indexPath) as UITableViewCell
        
        // Configure the cell...
        cell.textLabel!.text = self.key_names[indexPath.row]
        return cell
    }
    
    // updates the key of the instrument from table selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parent.updateKey(self.key_names[indexPath.row], notes: [])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}