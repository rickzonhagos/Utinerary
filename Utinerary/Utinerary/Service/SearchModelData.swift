//
//  SearchModelData.swift
//  Utinerary
//
//  Created by Cirrena on 8/25/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class SearchModelData: UtineraryModelData {
    
    private var searchItems : [SearchItem]?
    
    override func parse(myDictData: NSDictionary?) {
        
        
        //let predictions = myDictData["predictions"] as? [NSObject : ANY]
        
        if let predictions = myDictData?.objectForKey("predictions") as? NSArray{
            searchItems = [SearchItem]()
            
            for items in predictions{
                if let place = items as? NSDictionary {
                    let result = SearchItem(result : place)
                    searchItems?.append(result)
                }
            }
        }
    }
    
    func getSearchItems()->[SearchItem]?{
        return searchItems
    }
}
