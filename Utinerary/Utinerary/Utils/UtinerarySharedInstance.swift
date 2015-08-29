//
//  UtinerarySharedInstance.swift
//  Utinerary
//
//  Created by Cirrena on 8/28/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class UtinerarySharedInstance: NSObject {
    static let sharedInstance = UtinerarySharedInstance()
    
    
    var dateFormaterToString : NSDateFormatter?
    private override init(){
        super.init()
        
        self.dateFormaterToString = NSDateFormatter()
       // dateFormaterToString?.dateFormat = "EEE, MMM d, yyyy h:mm:aa"
        dateFormaterToString?.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormaterToString?.timeStyle = NSDateFormatterStyle.ShortStyle
    }
    
    
    // MARK: Date Formatter
    func reformatDateToString(date : NSDate!)->String? {
        return dateFormaterToString!.stringFromDate(date)
    }
    
    func reformatDateString(date : String!)->NSDate{
        
        return dateFormaterToString!.dateFromString(date)!
    }
}
