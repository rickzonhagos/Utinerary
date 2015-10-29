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
    @IBOutlet weak var randomView: UIView!
    //@IBOutlet weak var itineraryDetails: UITextView!
    
    @IBOutlet weak var holder: UIView!
    
    private var randomColor : UIColor {
        get{
            let randomRed:CGFloat = CGFloat(drand48())
            let randomGreen:CGFloat = CGFloat(drand48())
            let randomBlue:CGFloat = CGFloat(drand48())
            return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        }
    }
    
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
        //let randomColor = RandomColor()
        // var theColor = randomColor.randomColor()
        randomView.backgroundColor = randomColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  
    func setLabelValueForDateAndTime(dateAndTime : NSDate!, origin: String!, destination: String!){
        
        let sharedInstance = UtinerarySharedInstance.sharedInstance
        
        let (date , time ,_ , _ , _ ) = sharedInstance.splitDate(dateAndTime)
        
        dateAndTimeLbl.text = "\(date) \(time)"
        
        let subTitleAttributes = [NSFontAttributeName : Config.Theme.textSubBold!, NSForegroundColorAttributeName : Config.Theme.hightlightTextColor]
        let subTitleDetails = [NSFontAttributeName : Config.Theme.textSub!, NSForegroundColorAttributeName : Config.Theme.textSubColor]
        
        let mutableAttributedString = NSMutableAttributedString()
        
        mutableAttributedString.appendAttributedString( NSAttributedString(string: "FROM : ", attributes: subTitleAttributes as [String : AnyObject]))
        
       
        mutableAttributedString.appendAttributedString(NSAttributedString(string: origin, attributes: subTitleDetails as [String : AnyObject]))
        
        mutableAttributedString.appendAttributedString(NSAttributedString(string: "\nTO : ", attributes: subTitleAttributes as [String : AnyObject]))
   
        mutableAttributedString.appendAttributedString(NSAttributedString(string: destination, attributes: subTitleDetails as [String : AnyObject]))
        
        
        destinationLbl.attributedText = mutableAttributedString
        dateAndTimeLbl.textColor = Config.Theme.textMainColor
        dateAndTimeLbl.font = Config.Theme.textMain
        holder.backgroundColor = Config.Theme.tableCellBackground
   
    }
}
