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
    
    var key_names = ["CMajor", "DMajor", "GMajor", "EMajor", "FMajor", "AMajor", "C#Major"]
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Change key to \(self.key_names[indexPath.row])")
        parent.updateKey(self.key_names[indexPath.row])
    }
    
}