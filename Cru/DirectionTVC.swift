//
//  DirectionTVC.swift
//  Cru
//
//  Created by Max Crane on 5/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

struct Directions{
    static let to = "to event"
    static let from = "from event"
    static let both = "round-trip"
}


class DirectionTVC: UITableViewController {
    let options = [Directions.to, Directions.from, Directions.both]
    var handler: ((String)->())?
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel!.text = options[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "FreightSans Pro", size: 18)
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        handler!((cell!.textLabel?.text)!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}