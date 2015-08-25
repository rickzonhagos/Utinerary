//
//  Utils.swift
//  Utinerary
//
//  Created by rickzon hagos on 23/8/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import MapKit


class Utils: NSObject {
    static let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
    static let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
    
    
    
    
    
}


class MapAnotation : NSObject , MKAnnotation{
    var title : String?
    
    var coordinate : CLLocationCoordinate2D
    var subTitle : String?
    
    init(title : String! , coordinate : CLLocationCoordinate2D!, subTitle : String!){
        self.title = title
        self.coordinate = coordinate
        self.subTitle = subTitle
    }
}
