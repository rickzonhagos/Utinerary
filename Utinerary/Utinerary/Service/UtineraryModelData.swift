//
//  UtineraryModelData.swift
//  Utinerary
//
//  Created by Cirrena on 8/25/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class UtineraryModelData: NSObject {
    private var dictionaryData : NSDictionary?
    
    
    var isSuccess : Bool {
        get {
            let success : Bool = dictionaryData?.objectForKey("status") as! Bool
            
            return success
        }
    }
    
    var message : String {
        get {
            let msg : String = dictionaryData?.objectForKey("msg") as! String
            
            return msg
        }
    }
    
    var returnParams : NSDictionary?
    
    func parse(myDictData : NSDictionary?) {
        dictionaryData = myDictData
        
    }
    
}
