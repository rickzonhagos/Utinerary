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
    
    
   
    class func randomStringWithLength (len : Int = 8) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    
    class func bookToUber(itinerary : Itinerary!, sender : BaseViewController?){
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "uber://")!) {
            var stringLocation = "action=setPickup"
            if let origin : CLLocationCoordinate2D =  itinerary.origin?.location?.coordinate {
                stringLocation = stringLocation + "&pickup[latitude]=\(origin.latitude)&pickup[longitude]=\(origin.longitude)"
            }
            if let destination : CLLocationCoordinate2D =  itinerary.destination?.location?.coordinate {
                stringLocation = stringLocation + "&dropoff[latitude]=\(destination.latitude)&dropoff[longitude]=\(destination.longitude)"
            }
            
            let myURL = NSURL(string : "uber://?\(stringLocation)")
            UIApplication.sharedApplication().openURL(myURL!)
        }else{
            if let viewController = sender {
                viewController.showAlertMessageWithAlertAction(nil, delegate: nil, message: "Please install Uber", title: " ", withCancelButton: false, okButtonTitle: "Ok", alertTag: AlertTagType.Nothing, cancelTitle: "Cancel")
            }
            
        }
    }
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
