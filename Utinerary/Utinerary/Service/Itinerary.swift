//
//  Itinerary.swift
//  Utinerary
//
//  Created by Cirrena on 8/27/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class Itinerary: NSObject , NSCoding {
    var origin : UserLocation?
    var destination : UserLocation?
    var dateAndTime : NSDate?
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.origin, forKey: "origin")
        aCoder.encodeObject(self.destination, forKey: "destination")
        aCoder.encodeObject(self.dateAndTime, forKey: "dateAndTime")
    }
    override init() {
        
    }
     required init?(coder aDecoder: NSCoder) {
        self.origin = aDecoder.decodeObjectForKey("origin") as? UserLocation
        self.destination = aDecoder.decodeObjectForKey("destination") as? UserLocation
        self.dateAndTime = aDecoder.decodeObjectForKey("dateAndTime") as? NSDate

    }
    
}
