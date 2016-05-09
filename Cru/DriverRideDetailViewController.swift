//
//  DriverRideDetailViewController.swift
//  Cru
//
//  Created by Max Crane on 2/4/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress

class DriverRideDetailViewController: UIViewController, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var details = [EditableItem]()
    var event: Event!
    var ride: Ride!{
        didSet {
            
        }
    }
    var passengers = [Passenger]()
    let cellHeight = CGFloat(60)
    var rideVC: RidesViewController?
    var addressView: UITextView?
    var timeLabel: UILabel?
    var dateLabel: UILabel?
    var directionLabel: UILabel?
    var seatsOffered: UILabel?
    var seatsLeft: UILabel?
    var itemMap = [String: EditableItem]()
    @IBOutlet weak var detailsTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
      
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontName, size: 20)!], forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDetails()
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FreightSans Pro", size: 15)!], forState: .Normal)
        detailsTable.separatorStyle = .None
        
        
  
        CruClients.getRideUtils().getPassengersByIds(ride.passengers, inserter: insertPassenger, afterFunc: {success in
            //TODO: should be handling failure here
        })
        
        
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "goToEditPage")
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    
    
    func populateDetails(){
        var newItem = EditableItem(itemName: Labels.eventLabel, itemValue: event!.name, itemEditable: false, itemIsText: true)
        itemMap.updateValue(newItem, forKey: Labels.eventLabel)
        details.append(newItem)
        newItem = EditableItem(itemName: Labels.departureTimeLabel, itemValue: ride.getTime(), itemEditable: false, itemIsText: true)
        itemMap.updateValue(newItem, forKey: Labels.departureTimeLabel)
        details.append(EditableItem(itemName: Labels.departureTimeLabel, itemValue: ride.getTime(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.departureDateLabel, itemValue: ride.getDate(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.addressLabel, itemValue: ride.getCompleteAddress(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.directionLabel, itemValue: ride.getDirection(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.seatsLabel, itemValue: String(ride.seats), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.seatsLeftLabel, itemValue: String(ride.seatsLeft()), itemEditable: false, itemIsText: true))
    }
    
    func updateData(){
        timeLabel?.text = ride.getTime()
        dateLabel?.text = ride.getDate()
        addressView?.text = ride.getCompleteAddress()
        seatsOffered?.text = String(ride.seats)
        seatsLeft?.text = String(ride.seatsLeft())
    }
    
    
    func goToEditPage(){
        self.performSegueWithIdentifier("editSegue", sender: self)
    }
    
    func insertPassenger(newPassenger: NSDictionary){
        let newPassenger = Passenger(dict: newPassenger)
        passengers.append(newPassenger)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableView functions for the passenger list
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        
        if (tableView.isEqual(detailsTable)){
            return details.count
        }
        
        
        return 0
    }
    //Set up the cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var chosenCell: UITableViewCell?
        
        
        if(tableView.isEqual(detailsTable)){
            let cellIdentifier = "detailCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DetailCell
            cell.title.text = details[indexPath.row].itemName
            cell.value.text = details[indexPath.row].itemValue
            
            if (details[indexPath.row].itemName == Labels.addressLabel){
                cell.textViewValue.dataDetectorTypes = .Address
                cell.textViewValue.text = details[indexPath.row].itemValue
                addressView = cell.textViewValue
                cell.value.hidden = true
            }else{
                cell.textViewValue.hidden = true
            }
            
            if(details[indexPath.row].itemName == Labels.departureTimeLabel){
                timeLabel = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.departureDateLabel){
                dateLabel = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.seatsLeftLabel){
                seatsLeft = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.seatsLabel){
                seatsOffered = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.directionLabel){
                directionLabel = cell.value
            }
            
            chosenCell = cell
        }
        
        return chosenCell!
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        
        if(tableView.isEqual(detailsTable)){
            return CGFloat(80.0)
        }
        
        return CGFloat(44.0)
    }
    
    // Reload the data every time we come back to this view controller
    override func viewDidAppear(animated: Bool) {
        //passengerTable.reloadData()
        self.navigationItem.title = "Ride Details"
    }
    
    // MARK: - Navigation
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
        
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        Cancler.confirmCancel(self, handler: cancelConfirmed)
    }
    
    func cancelConfirmed(action: UIAlertAction){
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        CruClients.getRideUtils().leaveRideDriver(ride.id, handler: handleCancelResult)
    }
    
    func handleCancelResult(success: Bool){
        if(success){
            Cancler.showCancelSuccess(self, handler: { action in
                if let navController = self.navigationController {
                    navController.popViewControllerAnimated(true)
                    self.rideVC?.refresh(self)
                }
                
            })
        }
        else{
            Cancler.showCancelFailure(self)
        }
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editSegue"{
            if let destVC = segue.destinationViewController as? EditRideViewController{
                print("this hapepned")
                destVC.ride = ride
                destVC.event = event
                destVC.ridesVC = self.rideVC
                destVC.rideDetailVC = self
            }
            
        }
        else if(segue.identifier == "passengerSegue"){
            let popoverVC = segue.destinationViewController
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.77)
            popoverVC.popoverPresentationController!.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), (addressView?.frame.origin.y)! - 50.0,0,0)

            let controller = popoverVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
            
            if let vc = popoverVC as? PassengersViewController{
                vc.passengers = self.passengers
            }
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
