//
//  UserLocation.swift
//  Utinerary
//
//  Created by Cirrena on 8/26/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import MapKit

class UserLocation: NSObject , NSCoding {
    var location : CLLocation?
    var stringAddress : String?
    var placeMark : CLPlacemark?
    
    override init() {
        
    }
    convenience init(address : String = "Unknown Location" , currentLocation : CLLocation , placeMark : CLPlacemark?) {
        self.init()
        
        self.stringAddress = address
        self.location = currentLocation
        self.placeMark = placeMark
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.location, forKey: "location")
        aCoder.encodeObject(self.stringAddress, forKey: "stringAddress")
        aCoder.encodeObject(self.placeMark, forKey: "placeMark")
    }
    convenience required init(coder aDecoder: NSCoder) {
        self.init()
        self.location = aDecoder.decodeObjectForKey("location") as? CLLocation
        self.stringAddress = aDecoder.decodeObjectForKey("stringAddress") as? String
        self.placeMark = aDecoder.decodeObjectForKey("placeMark") as? CLPlacemark
    }
}

extension NSObject {
    func archive()->NSData{
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}
extension NSData{
    
    func unArchived()->AnyObject?{
        return NSKeyedUnarchiver.unarchiveObjectWithData(self)
    }
}