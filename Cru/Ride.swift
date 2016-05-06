//
//  Ride.swift
//  Cru
//
//  Created by Quan Tran on 1/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation


struct RideKeys {
    static let id = "_id"
    static let direction = "direction"
    static let driverName = "driverName"
    static let driverNumber = "driverNumber"
    static let event = "event"
    static let gcm_id = "gcm_id"
    static let gender = "gender" //int
    static let radius = "radius" //int
    static let seats = "seats" //int
    static let v = "__v"
    static let time = "time" //some format that ends in Z
    static let location = "location" //dict
    static let passengers = "passengers" //list
}

struct LocationKeys {
    static let loc = "location"
    static let postcode = "postcode"
    static let street1 = "street1"
    static let suburb = "suburb"
    static let state = "state"
    static let country = "country"
}

class Ride: Comparable, Equatable, TimeDetail {
    var id: String = ""
    var direction: String = ""
    var seats: Int = -1
    var radius: Int = -1
    var gcmId: String = ""
    var driverNumber: String = ""
    var driverName: String = ""
    var eventId: String = ""
    var time: String = ""
    var passengers = [String]()
    var day = -1
    var month = ""
    var monthNum = -1
    var hour = -1
    var minute = -1
    var year = -1
    var date : NSDate?
    var postcode: String = ""
    var state: String = ""
    var suburb: String = ""
    var street: String = ""
    var country: String = ""
    var gender: Int = 0
    

    init?(dict: NSDictionary){

        if (dict.objectForKey(LocationKeys.loc) != nil){
            let loc = dict.objectForKey(LocationKeys.loc) as! NSDictionary
            
            if (loc[LocationKeys.postcode] != nil){
                postcode = loc[LocationKeys.postcode] as! String
            }
            if (loc[LocationKeys.state] != nil){
                state = loc[LocationKeys.state] as! String
            }
            if (loc[LocationKeys.suburb] != nil){
                suburb = loc[LocationKeys.suburb] as! String
            }
            if (loc[LocationKeys.street1] != nil){
                street = loc[LocationKeys.street1] as! String
            }
            if loc[LocationKeys.country] != nil {
                country = loc[LocationKeys.country] as! String
            }
        }
        if (dict.objectForKey(RideKeys.id) != nil){
            id = dict.objectForKey(RideKeys.id) as! String
        }
        if (dict.objectForKey(RideKeys.direction) != nil){
            direction = dict.objectForKey(RideKeys.direction) as! String
        }
        if (dict.objectForKey(RideKeys.seats) != nil){
            seats = dict.objectForKey(RideKeys.seats) as! Int
        }
        if (dict.objectForKey(RideKeys.radius) != nil){
            radius = dict.objectForKey(RideKeys.radius) as! Int
        }
        if (dict.objectForKey(RideKeys.gcm_id) != nil){
            gcmId = dict.objectForKey(RideKeys.gcm_id) as! String
        }
        if (dict.objectForKey(RideKeys.driverNumber) != nil){
            driverNumber = dict.objectForKey(RideKeys.driverNumber) as! String
        }
        if (dict.objectForKey(RideKeys.driverName) != nil){
            driverName = dict.objectForKey(RideKeys.driverName) as! String
        }
        if (dict.objectForKey(RideKeys.event) != nil){
            eventId = dict.objectForKey(RideKeys.event) as! String
        }
        if (dict.objectForKey(RideKeys.time) != nil){
            time = dict.objectForKey(RideKeys.time) as! String
            self.date = GlobalUtils.dateFromString(time)
            
            let components = GlobalUtils.dateComponentsFromDate(GlobalUtils.dateFromString(time))!
            self.day = components.day
            let monthNumber = components.month
            self.hour = components.hour
            self.minute = components.minute
            self.year = components.year
            self.time = getTime()//Ride.createTime(self.hour, minute: self.minute)
            
            //get month symbol from number
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            let months = dateFormatter.shortMonthSymbols
            self.month = months[monthNumber - 1].uppercaseString
            self.monthNum = monthNumber
        }
        if (dict.objectForKey(RideKeys.passengers) != nil){
            passengers = dict.objectForKey(RideKeys.passengers) as! [String]
        }

    }
    
    func getTimeInServerFormat()->String{
        
        var dayString = ""
        var hourString = ""
        var minuteString = ""
        var monthString = ""
        
        if(monthNum < 10){
            monthString = "0" + String(monthNum)
        }
        else{
            monthString = String(monthNum)
        }
        
        if(day < 10){
            dayString = "0" + String(day)
        }
        else{
            dayString = String(day)
        }
        
        if(hour < 10){
            hourString = "0"  + String(hour)
        }
        else{
            hourString = String(hour)
        }
        
        if(minute < 10){
            minuteString = "0"  + String(minute)
        }
        else{
            minuteString = String(minute)
        }
        
        return String(year) + "-" + String(monthString) + "-" + String(dayString) + "T" + hourString + ":" + String(minuteString) + ":00.000Z"
    }
    
    func getCompleteAddress()->String{
        var address: String = ""
        
        if(street != ""){
            address += street
        }
        if(postcode != ""){
            address += ", " + postcode
        }
        if(suburb != ""){
            address += ", " + suburb
        }
        if(state != ""){
            address += ", " + state
        }
        
        return address
    }
    
    func getTime()->String{
        let dFormat = "h:mm a"
        return GlobalUtils.stringFromDate(self.date!, format: dFormat)
    }
    
    func getDate()->String{
        let dFormat = "MMMM d, yyyy"
        return GlobalUtils.stringFromDate(self.date!, format: dFormat)
    }
        
    func hasSeats()->Bool{
        return (self.seats - passengers.count)  != 0
    }
    
    func seatsLeft()->String{
        return String(self.seats - self.passengers.count)
    }
    
    func seatsLeft()->Int{
        return self.seats - self.passengers.count
    }
    
    func getRideAsDict()->[String:AnyObject]{
        var map: [String:AnyObject] = [RideKeys.id : self.id,
            RideKeys.direction: self.direction, RideKeys.driverName: self.driverName,
            RideKeys.driverNumber: self.driverNumber, RideKeys.radius: self.radius,
            RideKeys.seats: self.seats, RideKeys.time: self.time,
            RideKeys.location: self.getLocationAsDict(), RideKeys.passengers: self.passengers]
        map.updateValue(self.direction, forKey: RideKeys.direction)
        map[RideKeys.direction] = self.direction
        //map[RideKeys.driverName] = self.driverName
        //map[RideKeys.driverNumber] = self.driverNumber
        //map[RideKeys.radius] = self.radius
        //map[RideKeys.seats] = self.seats
        //map[RideKeys.time] = self.time
        //map[RideKeys.location] = self.getLocationAsDict()
        //map[RideKeys.passengers] = self.passengers
        
        //map[RideKeys.id] = self.id
        //map[RideKeys.event] = self.eventId
        //map[RideKeys.gcm_id] = self.gcmId
        //map[RideKeys.gender] = self.gender
        //map[RideKeys.v] = 0

        return map
    }
    
    func getLocationAsDict()->[String:AnyObject]{
        var map = [String:AnyObject]()
        var locMap = [String:String]()
        
        locMap[LocationKeys.postcode] = self.postcode
        locMap[LocationKeys.state] = self.state
        locMap[LocationKeys.street1] = self.street
        locMap[LocationKeys.country] = self.country
        locMap[LocationKeys.suburb] = self.suburb
        
        map[LocationKeys.loc] = locMap
        
        return map
    }
}

func  <(lRide: Ride, rRide: Ride) -> Bool{
    if(lRide.year < rRide.year){
        return true
    }
    else if(lRide.year > rRide.year){
        return false
    }
    if(lRide.monthNum < rRide.monthNum){
        return true
    }
    else if(lRide.monthNum > rRide.monthNum){
        return false
    }
    
    if(lRide.day < rRide.day){
        return true
    }
    else if(lRide.day > rRide.day){
        return false
    }
    return false
}
func  ==(lRide: Ride, rRide: Ride) -> Bool{
    return lRide.id == rRide.id
}