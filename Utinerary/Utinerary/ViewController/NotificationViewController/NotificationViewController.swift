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
    
    @IBOutlet weak var origin: UILabel!
    @IBOutlet weak var destination: UILabel!
    
    
    var actionType : String?
    
    var currentItinerary : Itinerary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initNavItems()
        
        getNotificationDetail()
        
    
    }
    
    func initNavItems(){
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "barButtonActions:")
        self.navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Book To Uber", style: UIBarButtonItemStyle.Bordered, target: self, action: "barButtonActions:")
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
                self.origin.text =  itinerary.origin?.stringAddress
                self.destination.text = itinerary.destination?.stringAddress
                self.currentItinerary = itinerary
                
                //TextColor
                self.origin.textColor = Config.Theme.textSubColor
                self.destination.textColor = Config.Theme.textSubColor
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
