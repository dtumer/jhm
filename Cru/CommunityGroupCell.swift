//
//  CommunityGroupCell.swift
//  Cru
//
//  Created by Peter Godkin on 5/25/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroupCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var descript: UITextView!
    
    @IBOutlet weak var meetingTime: UILabel!
    private var group: CommunityGroup!
    
    func setGroup(group: CommunityGroup) {
        self.group = group
        name.text = group.name
        descript.text = group.description
        meetingTime.text = group.meetingTime
    }

    @IBAction func signUpPressed(sender: AnyObject) {
        print("TODO: not yet implemented")
    }
}
