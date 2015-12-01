//
//  Campus.swift
//  Cru
//
//  Created by Max Crane on 11/29/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Campus: NSObject, NSCoding {
    let name: String!
    var feedEnabled: Bool!
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        feedEnabled = aDecoder.decodeObjectForKey("feedEnabled") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(feedEnabled, forKey: "feedEnabled")
    }

    init(name: String, feedEnabled: Bool){
        self.name = name
        self.feedEnabled = feedEnabled
    }
    
    init(name: String){
        self.name = name
        self.feedEnabled = false
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object as? Campus{
            return obj.name == self.name
        }
        else{
            return false
        }
    }
}