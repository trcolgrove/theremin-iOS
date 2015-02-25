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
    
    var table_type: Bool = true
    
    var keys: [String]!
    
    var parent:InstrumentViewController!
    
    override func viewDidLoad() {
        println("KeyViewController did load")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
                                                                           UITableViewCell {
        let cellIdentifier = "Cell"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:
        indexPath) as UITableViewCell
        
        // Configure the cell...
        cell.textLabel!.text = self.keys[indexPath.row]
        return cell
    }
    
    // updates the key of the instrument from table selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parent.updateKey(self.keys[indexPath.row], isNote: table_type)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}