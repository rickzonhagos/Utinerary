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
    
    
    var dateFormater : NSDateFormatter?
    private override init(){
        super.init()
        
        self.dateFormater = NSDateFormatter()
        dateFormater?.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormater?.timeStyle = NSDateFormatterStyle.NoStyle
     
    }
    
    
    // MARK: Date Formatter
    func reformatDate(date : NSDate!)->String? {
        return dateFormater!.stringFromDate(date)
    }
}
