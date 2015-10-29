///
//  ItineraryViewController.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import CoreData

enum ItineraryActionType {
    case CreateItinerary
    case ViewItinerary
}

typealias  completionBlock  = (success : Bool)->Void
typealias  fetchCompletionBlock  = (success : Bool , item : Itinerary?)->Void

class ItineraryViewController: BaseViewController {

    @IBOutlet private weak var myTableView: UITableView!
   
    private var originLocation : UserLocation?
    private var destinationLocation : UserLocation?
    
    var itineraryAction : ItineraryActionType?
    var itineraryItem : (item : Itinerary! , managedObject : NSManagedObject!)?
    

    @IBOutlet private weak var deleteItineraryButton: UIBarButtonItem!
    
    private var deleteButtonHasBeenHidden : Bool = false
    
    @IBOutlet weak var myToolBar: UIToolbar!
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Config.appTitle
        self.navigationController?.navigationBar.topItem?.title = ""
    
        //navigationItem.leftBarButtonItem?.title = "";
        
        if let datePicker = self.getDatePicker(){
            datePicker.timeZone = NSTimeZone(name: "Asia/Manila")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if itineraryAction == ItineraryActionType.ViewItinerary {
            if let item = itineraryItem!.item  {
                let stringAdress : [String] = [(item.origin?.stringAddress)!, (item.destination?.stringAddress)! ]
                for (index , element) in stringAdress.enumerate() {
                    if let cell = getCellByRow(index) ,label =  cell.viewWithTag(1) as? UILabel{
                        label.text = element
                    }
                }
                
                self.originLocation = itineraryItem!.item.origin
                self.destinationLocation = itineraryItem!.item.destination
                
                if let datePicker = self.getDatePicker(){
                    datePicker.setDate(itineraryItem!.item.dateAndTime!, animated: true)
                }
            }
        }else {
            if !deleteButtonHasBeenHidden {
                if var items : [UIBarButtonItem] = myToolBar.items  where items.count > 0{
                    items.removeAtIndex(0)
                    self.myToolBar.setItems(items, animated: true)
                    self.deleteButtonHasBeenHidden = true
                }
            }
        }
        
    }
    
    func getDatePicker()->UIDatePicker?{
        if let cell = self.getCellByRow(2) , datePicker = cell.viewWithTag(3000) as? UIDatePicker{
            
            return datePicker
            
        }
        return nil
    }
 
    // MARK: Nav Button
    func validateLocationFields()->(isSuccess : Bool , message : String?){
        var message : String?
        var success : Bool = true
        if originLocation == nil && destinationLocation == nil{
            message = "Please enter your desired Destination and Origin Address"
            success = false
        }else if originLocation == nil{
            message = "Please enter your Origin Address"
            success = false
        }else if destinationLocation == nil {
            message = "Please enter your Destination Address"
            success = false
        }
        return (isSuccess : success , message : message)
    }
    @IBAction func buttonEvent(sender : AnyObject?){
        
        if let button = sender as? UIBarButtonItem {
            if button.tag == 3000{
                //book to Uber
                let result = self.validateLocationFields()
                
                if !result.isSuccess {
                    self.showAlertMessageWithAlertAction(nil, delegate: nil, message: result.message, title: " ", withCancelButton: false, okButtonTitle: "Ok", alertTag: AlertTagType.Nothing, cancelTitle: "Cancel" , dimissBlock : nil)
                    return
                }
                
                let itinerary = Itinerary()
                itinerary.origin = originLocation
                itinerary.destination = destinationLocation
                Utils.bookToUber(itinerary, sender : self)
                
                
            }else {
               
                if button.tag == 1000 {
                    if let cell = self.getCellByRow(2) , datePicker = cell.viewWithTag(3000) as? UIDatePicker{
                        if let item = itineraryItem , managedObject = item.managedObject {
                            //update
                            managedObject.setValue(datePicker.date, forKey: "dateAndTime")
                            managedObject.setValue(destinationLocation!.archive(), forKey: "destination")
                            managedObject.setValue(originLocation!.archive(), forKey: "origin")
                            
                            
                            updateItem(managedObject)
                        }else {
                            //save
                            
                            let result = self.validateLocationFields()
                            
                            if !result.isSuccess {
                                self.showAlertMessageWithAlertAction(nil, delegate: nil, message: result.message, title: " ", withCancelButton: false, okButtonTitle: "Ok", alertTag: AlertTagType.Nothing, cancelTitle: "Cancel", dimissBlock : nil)
                                return
                            }

                            let itinerary = Itinerary()
                            itinerary.origin = originLocation
                            itinerary.destination = destinationLocation
                            
                            let stringedDate = utinerarySharedInstance.reformatDateToString(datePicker.date)
                            let reformattedDate = utinerarySharedInstance.reformatDateString(stringedDate)
                            itinerary.dateAndTime = reformattedDate
                            
                            self.addItem(itinerary)
                        }
                    }
                }else {
                    //delete 
                    self.showAlertMessageWithAlertAction({
                         [unowned self](action) -> Void in
                        if action == AlertAction.Ok {
                            self.deleteItem()
                        }
                    }, delegate: self, message: "Are you sure you want to delete this item", title: "Delete Confirmation", withCancelButton: true, okButtonTitle: "Proceed", alertTag: AlertTagType.DeleteAlert, cancelTitle: "Cancel", dimissBlock : nil)
                }
                
            }
        }
    }
    
    
    // MARK: Core Data Add / Edit / Delete
    
    func updateItem(managedObject : NSManagedObject!){
        self.view.showProgressIndicatorWithLoadingMessage("Updating Data")
        
        if let cell = self.getCellByRow(2) , _ = cell.viewWithTag(3000) as? UIDatePicker{

            self.appDelegate?.updateItinerary(managedObject,  completionHandler: { (success) -> Void in
                self.view.hideProgressIndicator()
                self.showAlertMessageWithAlertAction({
                    [unowned self](action) -> Void in
                    if action == AlertAction.Ok {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    }, delegate: self,
                    message: "Itinerary updated",
                    title: "",
                    withCancelButton: false,
                    okButtonTitle: "",
                    alertTag: AlertTagType.UpdatedItemAlert,
                    cancelTitle: "",
                    dimissBlock :{
                        ()-> Void in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }, fadeDismiss: true)
            })
        }
        
    }
    
    func addItem(item : Itinerary!){
        self.view.showProgressIndicatorWithLoadingMessage("Saving Data")
        
        self.appDelegate?.insertItinerary(item, notifID: Utils.randomStringWithLength() as String , completionHandler: {
            [unowned self](success) -> Void in
            self.view.hideProgressIndicator()
            self.showAlertMessageWithAlertAction({
                [unowned self](action) -> Void in
                if action == AlertAction.Ok {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                },
                delegate: self,
                message: "Itinerary created",
                title: "",
                withCancelButton: false,
                okButtonTitle: "",
                alertTag: AlertTagType.AddedItemAlert,
                cancelTitle: "" ,
                dimissBlock : {
                    ()->Void in
                    
                }, fadeDismiss : true)
            
        })
    }
    func deleteItem(){
        self.view.showProgressIndicatorWithLoadingMessage("Deleting Item")
        self.appDelegate?.deleteItineraryItem(self.itineraryItem!.managedObject , completionHandler: {
            [unowned self](success) -> Void in
            self.view.hideProgressIndicator()
            
            self.showAlertMessageWithAlertAction({
                [unowned self](action) -> Void in
                    if action == AlertAction.Ok {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                },
                delegate: self,
                message: "Itinerary removed",
                title: "",
                withCancelButton: false,
                okButtonTitle: "",
                alertTag: AlertTagType.DeletedItemAlert,
                cancelTitle: "",
                dimissBlock : {
                    ()->Void in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } ,
                fadeDismiss: true)
        })
    }
    
    // MARK: Alert View Delegate
    override func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        super.alertView(alertView, clickedButtonAtIndex: buttonIndex)
        if alertView.tag == AlertTagType.DeleteAlert.rawValue {
            if buttonIndex == 1 {
                self.deleteItem()
            }
            
        }else if alertView.tag ==  AlertTagType.DeletedItemAlert.rawValue ||
            alertView.tag == AlertTagType.AddedItemAlert.rawValue ||
            alertView.tag == AlertTagType.UpdatedItemAlert.rawValue {
                self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }
}
extension ItineraryViewController : MapViewControllerDelegate{
    func didFinishWithUserLocation(user: UserLocation! , locationType : LocationType){
        if let cell = self.getCellByRow(locationType.rawValue),
            label = cell.viewWithTag(1) as? UILabel {
           label.text = user.stringAddress
            label.textColor = Config.Theme.textSubColor
            label.font = Config.Theme.cellDescFont
                if locationType == LocationType.Origin{
                    self.originLocation = user
                }else{
                    self.destinationLocation = user
                }
        }
    }
    
    func getCellByRow(row : Int)->UITableViewCell?{
        let indexPath : NSIndexPath =  NSIndexPath(forRow: row, inSection: 0)
        if let cell = myTableView.cellForRowAtIndexPath(indexPath) {
            return cell
        }
        return nil
    }
}
extension ItineraryViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row : NSInteger = indexPath.row
        
        if row == 0 || row == 1 {
            return 100
        }else{
            return 200
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row : NSInteger = indexPath.row
        
        if row == 0 || row == 1 {
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            if let mapView  =   storyBoard.instantiateViewControllerWithIdentifier("MapNavigationView") as? UINavigationController{
                if let controller = mapView.viewControllers[0] as? MapViewController where mapView.viewControllers.count == 1 {
                    controller.myDelegate  = self
                    controller.locationType = ((row == 0) ? LocationType.Origin : LocationType.Destination)
                }
                
                self.navigationController?.presentViewController(mapView, animated: true, completion: nil)
            }
        }
    }
}

extension ItineraryViewController : UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row : NSInteger = indexPath.row
        
        var cell : UITableViewCell?
        
        if row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("OriginCellViewIdentifier")
        }else if row == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("DestinationViewCellIdentifier")
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("DateAndTimeViewCellIdentifier")
        }
        
        
        cell?.viewWithTag(2)?.backgroundColor = Config.Theme.tableCellBackground
        cell?.viewWithTag(2)?.layer.cornerRadius = 10
        cell?.viewWithTag(2)?.layer.masksToBounds = true
    
        return cell!
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
