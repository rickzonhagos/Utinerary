//
//  ItineraryTableViewCell.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class ItineraryTableViewCell: UITableViewCell {

    @IBOutlet private weak var dateAndTimeLbl: UILabel!
    @IBOutlet private weak var destinationLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLabelValueForDateAndTime(dateAndTime : NSDate!, destination: String!){
        
        let sharedInstance = UtinerarySharedInstance.sharedInstance
        
        dateAndTimeLbl.text = sharedInstance.reformatDate(dateAndTime)
        destinationLbl.text = destination
    }
}
