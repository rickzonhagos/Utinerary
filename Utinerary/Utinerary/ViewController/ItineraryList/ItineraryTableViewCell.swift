//
//  ItineraryTableViewCell.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

@IBDesignable class ItineraryTableViewCell: UITableViewCell {

    @IBOutlet private weak var dateAndTimeLbl: UILabel!
    @IBOutlet private weak var destinationLbl: UILabel!
    
    @IBOutlet weak var holder: UIView!
    
    @IBInspectable var isRoundedCorder: Bool = false {
        didSet {
            /*
            let layer = self.holder.layer
            layer.cornerRadius = 5.0
            layer.borderColor = UIColor.clearColor().CGColor
            layer.borderWidth = 1.0
            layer.masksToBounds = true
*/ 
        }
    }
    
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
        
        let (date , time ,day ) = sharedInstance.splitDate(dateAndTime)
        
        dateAndTimeLbl.text = "\(date) \(time)"
        destinationLbl.text = destination
    }
}
