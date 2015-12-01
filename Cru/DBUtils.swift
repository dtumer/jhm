//
//  DBUtils.swift
//  Cru
//
//  Created by Peter Godkin on 11/24/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class DBUtils {
    static func loadResources(collectionName : String, inserter : (NSDictionary) -> ()) {
        DBClient.displayListInfo(collectionName, completionHandler: curryDisplayResources(inserter))
    }
    
    static func curryDisplayResources(inserter : (NSDictionary) -> ()) -> (NSData?, NSURLResponse?, NSError?)-> () {
    
        return {(data : NSData?, response : NSURLResponse?, error : NSError?) in
            do {
                if (data != nil) {
                    let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    let jsonList = jsonResponse as! NSArray
                    if data != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            for sm in jsonList {
                                if let dict = sm as? [String: AnyObject]{
                                    inserter(dict)
                                }
                            }
                        })
                    }
                } else {
                    // TODO: display message for user
                    print("Failed to get stuff from database")
                }
            } catch {
                print("Something went wrong with http request...")
            }
        }
    }
    
    
    class func dateFromString(dateStr : String) -> NSDateComponents? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.dateFromString(dateStr)
        let unitFlags: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
        return NSCalendar.currentCalendar().components(unitFlags, fromDate: date!)
    }
}