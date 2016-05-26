//
//  EventsTableViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 4/28/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController, SWRevealViewControllerDelegate {
    
    var events = [Event]()
    let curDate = NSDate()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LOAD EVENTS")
        
        if self.revealViewController() != nil{
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().delegate = self
        }
        CruClients.getServerClient().getData(.Event, insert: insertEvent, completionHandler: finishInserting)
        
        //Set the nav title & font
        navigationItem.title = "Events"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    //insert helper function for inserting event data
    private func insertEvent(dict: NSDictionary) {
        let event = Event(dict: dict)!
        
        if(event.startNSDate.compare(NSDate()) != .OrderedAscending){
            self.events.insert(event, atIndex: 0)
        }
        
    }
    
    //helper function for finishing off inserting event data
    private func finishInserting(success: Bool) {
        self.events.sortInPlace({$0.startNSDate.compare($1.startNSDate) == .OrderedAscending})
        self.tableView!.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.event = event
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let event = events[indexPath.row]
        
        if event.imageUrl == "" {
            return 150.0
        }
        else {
            return 305.0       
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventDetails" {
            let eventDetailViewController = segue.destinationViewController as! EventDetailsViewController
            let selectedEventCell = sender as! EventTableViewCell
            let indexPath = self.tableView!.indexPathForCell(selectedEventCell)!
            let selectedEvent = events[indexPath.row]
            
            eventDetailViewController.event = selectedEvent
        }
    }
    
    //reveal controller function for disabling the current view
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        if position == FrontViewPosition.Left {
            self.tableView.scrollEnabled = true
            
            for view in self.tableView.subviews {
                view.userInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.Right {
            self.tableView.scrollEnabled = false
            
            for view in self.tableView.subviews {
                view.userInteractionEnabled = false
            }
        }
    }
}
