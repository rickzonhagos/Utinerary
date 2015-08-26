//
//  UserLocation.swift
//  Utinerary
//
//  Created by Cirrena on 8/26/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import MapKit

class UserLocation: NSObject {
    var location : CLLocation?
    var stringAddress : String?
    
    override init() {
        
    }
    
    convenience init(address : String = "Unknown Location" , currentLocation : CLLocation) {
        self.init()
        
        self.stringAddress = address
        self.location = currentLocation
        
    }
}
