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
    @IBOutlet weak var detailsTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
      
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontName, size: 20)!], forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        details.append(EditableItem(itemName: "Event:", itemValue: event!.name, itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: "Departure Time:", itemValue: ride.getTime(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: "Departure Date:", itemValue: ride.getDate(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: "Departure Address:", itemValue: ride.getCompleteAddress(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: "Direction:", itemValue: ride.getDirection(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: "Seats:", itemValue: String(ride.seats), itemEditable: false, itemIsText: true))
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FreightSans Pro", size: 15)!], forState: .Normal)
        
        //self.contentViewHeight.constant = CGFloat(600)
        //adjustPageConstraints()
        
        //self.passengerTable.delegate = self
        
        //passengerTable.scrollEnabled = false;
        //rideName.text = event!.name
        CruClients.getRideUtils().getPassengersByIds(ride.passengers, inserter: insertPassenger, afterFunc: {success in
            //TODO: should be handling failure here
        })
        //departureTime.text = ride.getTime()
        //departureDate.text = ride.getDate()
        
        //departureLoc.dataDetectorTypes = UIDataDetectorTypes.None
        //departureLoc.dataDetectorTypes = UIDataDetectorTypes.Address
        
        //departureLoc.text = nil
        //departureLoc.text = ride.getCompleteAddress()
        
        //passengerTable.backgroundColor = UIColor.clearColor()
        
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "goToEditPage")
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    
    func goToEditPage(){
        self.performSegueWithIdentifier("editSegue", sender: self)
    }
    
    func insertPassenger(newPassenger: NSDictionary){
        let newPassenger = Passenger(dict: newPassenger)
        passengers.append(newPassenger)
        //self.passengerTable.reloadData()
        //adjustPageConstraints()
        
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
            
            if (details[indexPath.row].itemName == "Departure Address:"){
                //departureLabel = cell.value
                
                //cell.textViewValue.editable = false
                cell.textViewValue.dataDetectorTypes = .Address
                //cell.textViewValue.selectable = true
                //cell.textViewValue.userInteractionEnabled = false
                cell.textViewValue.text = details[indexPath.row].itemValue
                
                addressView = cell.textViewValue
                cell.value.hidden = true
            }else{
                cell.textViewValue.hidden = true
            }
            
            //cell.contentValue.text = details[indexPath.row].itemValue
            //cell.contentTextField.text = details[indexPath.row].itemValue
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
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.7)
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
