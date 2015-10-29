//
//  NotificationViewController.swift
//  Utinerary
//
//  Created by rickzon hagos on 29/8/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

import MapKit

enum LocationNotificationAction:String{
    case BookToUber = "BOOK_TO_UBER"
    case View = "View"
}



class NotificationViewController: BaseViewController {
    var notifID : String?
    
   // @IBOutlet weak var origin: UILabel!
   // @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var uberButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var dateDayView: UIView!
    @IBOutlet weak var originDestinationView: UIView!

    
    
    var actionType : String?
    
    var currentItinerary : Itinerary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Utinerary Reminder"
        
        formatView()
        getNotificationDetail()
        
    
    }

    func formatView(){
        notificationView.layer.cornerRadius = 10
        notificationView.layer.masksToBounds = true
        notificationView.backgroundColor = Config.Theme.tableCellBackground
        
        dateDayView.layer.cornerRadius = dateDayView.frame.size.width/2
        dateDayView.layer.masksToBounds = true
        
        let border = CALayer()
        border.backgroundColor = UIColor.grayColor().CGColor
        border.frame = CGRect(x: 0, y: 0, width: originDestinationView.frame.width, height: 0.5)
        
        originDestinationView.layer.addSublayer(border)
        
        doneButton.layer.cornerRadius = 5
        doneButton.layer.masksToBounds = true
        uberButton.layer.cornerRadius = 5
        uberButton.layer.masksToBounds = true
        
    }

    
    @IBAction func barButtonActions(sender : UIButton?){
        if let button = sender {
            let tag : Int  = button.tag
            if tag == 1000 {
                self.dismissViewControllerAnimated(true, completion: nil)
            }else if tag == 2000{
                if let itinerary = currentItinerary {
                    Utils.bookToUber(itinerary , sender : self)
                }
            }
        }
        
    }
    
    func getNotificationDetail(){
        self.view.showProgressIndicatorWithLoadingMessage()
        self.appDelegate!.fetchItineraryItemBy(notifID, completionHandler: {
            [unowned self](success : Bool, item : Itinerary?) -> Void in
            self.view.hideProgressIndicator()
            
            if let itinerary = item{
                
                let fromStr = itinerary.origin?.stringAddress
                let toStr = itinerary.destination?.stringAddress
                let dateAndTime = itinerary.dateAndTime
                
                self.currentItinerary = itinerary
                
                let titleAttributes = [NSFontAttributeName : Config.Theme.routeTitle!, NSForegroundColorAttributeName : Config.Theme.hightlightTextColor]
                let valueAttributes = [NSFontAttributeName : Config.Theme.routeValue!, NSForegroundColorAttributeName : Config.Theme.textSubColor]
                
                let mutableAttributedString = NSMutableAttributedString()
                
                mutableAttributedString.appendAttributedString(NSAttributedString(string: "ORIGIN : ", attributes: titleAttributes as [String : AnyObject]))
           
                mutableAttributedString.appendAttributedString(NSAttributedString(string: fromStr!, attributes: valueAttributes as [String : AnyObject]))
                
                mutableAttributedString.appendAttributedString(NSAttributedString(string: "\n\n You're scheduled to travel to : ", attributes: titleAttributes as [String : AnyObject]))
                
                mutableAttributedString.appendAttributedString(NSAttributedString(string: toStr!, attributes: valueAttributes as [String : AnyObject]))
                
                self.routeLabel.attributedText = mutableAttributedString
                
                
                let sharedInstance = UtinerarySharedInstance.sharedInstance
                let (date , time ,dayName , shortDate , monthShort ) = sharedInstance.splitDate(dateAndTime)
                //self.dateLabel.text = dateShort
                //dayLabel.text = day
                self.timeLabel.text = "\(dayName) \(time)"
                self.dayLabel.text = "\(monthShort)"
                self.dateLabel.text = "\(shortDate)"
                

                if let action = self.actionType where action == LocationNotificationAction.BookToUber.rawValue{
                    Utils.bookToUber(itinerary ,sender : self)
                }
            }
        })
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}
