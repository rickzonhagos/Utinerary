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
    
    
    var dateFormaterToString : NSDateFormatter!
    
    var dateOnly : NSDateFormatter!
    var timeOnly : NSDateFormatter!
    var dayOnly : NSDateFormatter!
    private override init(){
        super.init()
        
        self.dateFormaterToString = NSDateFormatter()
       // dateFormaterToString?.dateFormat = "EEE, MMM d, yyyy h:mm:aa"
        dateFormaterToString.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormaterToString.timeStyle = NSDateFormatterStyle.ShortStyle
        
        
        self.dateOnly = NSDateFormatter()
        dateOnly.dateFormat = "LLL d, yyyy"
        
        self.timeOnly = NSDateFormatter()
        timeOnly.timeStyle = NSDateFormatterStyle.ShortStyle
        
        self.dayOnly = NSDateFormatter()
        dayOnly.dateFormat = "EEE"
        
    }
    
    
    // MARK: Date Formatter
    func reformatDateToString(date : NSDate!)->String? {
        return dateFormaterToString!.stringFromDate(date)
    }
    
    func splitDate(date : NSDate!)->(date : NSString! , time : NSString! , day : NSString!)!{
        
        let shortDate : String = dateOnly.stringFromDate(date)
        
        let time : String = timeOnly.stringFromDate(date)
        
        let day : String = dayOnly.stringFromDate(date)
        
        return (date : shortDate , time : time , day : day)
    }
    
    func reformatDateString(date : String!)->NSDate{
        
        return dateFormaterToString.dateFromString(date)!
    }
}
