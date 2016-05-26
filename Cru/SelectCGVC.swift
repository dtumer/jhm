//
//  SelectCGVC.swift
//  Cru
//
//  Created by Max Crane on 5/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//
import MRProgress
import UIKit

class SelectCGVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var cgs = [CommunityGroupCell]()
    private var answers = [[String:String]]()
    
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose a Community Group"
        loadCommunityGroups()
    }
    
    private func loadCommunityGroups() {
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        
        //load all community groups until the submit answers endpoint is added
        CruClients.getServerClient().getData(DBCollection.CommunityGroup, insert: insertGroup,
            completionHandler: finishInserting)
    }
    
    private func finishInserting(success: Bool) {
        table.reloadData()
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }
    
    private func insertGroup(dict: NSDictionary) {
        let cell = self.table.dequeueReusableCellWithIdentifier("cell")!
        let groupCell = cell as! CommunityGroupCell
        groupCell.setGroup(CommunityGroup(dict: dict))
        groupCell.setSignupCallback(jumpBackToGetInvolved)
        cgs.append(groupCell)
        table.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func setAnswers(answers: [[String:String]]) {
        self.answers = answers
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cgs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cgs[indexPath.row]
    }
    
    func jumpBackToGetInvolved() {
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKindOfClass(GetInvolvedViewController) {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
}
