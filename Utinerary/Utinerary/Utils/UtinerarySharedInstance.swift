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
    var dayName : NSDateFormatter!
    
    var monthShort : NSDateFormatter!
    var dateShort : NSDateFormatter!
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
        
        self.dayName = NSDateFormatter()
        dayName.dateFormat = "EEEE"
        
        
        self.monthShort = NSDateFormatter()
        monthShort.dateFormat = "MMM"
        
        
        self.dateShort = NSDateFormatter()
        dateShort.dateFormat = "dd"
        
    }
    
    
    // MARK: Date Formatter
    func reformatDateToString(date : NSDate!)->String? {
        return dateFormaterToString!.stringFromDate(date)
    }
    
    func splitDate(date : NSDate!)->(date : NSString! , time : NSString! , dayName : NSString!,shortDate : NSString! , monthShort : NSString!)!{
        
        let shortDate : String = dateOnly.stringFromDate(date)
        
        let time : String = timeOnly.stringFromDate(date)
        
        let resultDayName : String = dayName.stringFromDate(date)
        
        let resultShortMonth : String = monthShort.stringFromDate(date)
        let resultShortDate : String = dateShort.stringFromDate(date)
        
        return (date : shortDate , time : time , dayName : resultDayName, shortDate : resultShortDate , monthShort : resultShortMonth )
    }
    
    func reformatDateString(date : String!)->NSDate{
        
        return dateFormaterToString.dateFromString(date)!
    }
}
