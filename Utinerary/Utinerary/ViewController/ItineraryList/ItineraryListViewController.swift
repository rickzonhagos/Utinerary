//
//  ItineraryListViewController.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import CoreData
class ItineraryListViewController: BaseViewController {

    @IBOutlet weak var listView: UITableView!
    
    private var itineraryList : [String : AnyObject]?
    
    // MARK:
    // MARK: Life Cycle
    // MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.listView.backgroundColor = UIColor.blackColor()
    
        self.title = Config.appTitle
        
        let barShadow: NSShadow = NSShadow()
        barShadow.shadowColor = UIColor.grayColor()
        barShadow.shadowOffset = CGSize(width: 1, height: 2)

        if let navFont = Config.Theme.textNavBar {
            let navBarAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: navFont,
                NSShadowAttributeName: barShadow
            ]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchListAndReloadData()
        
    }
    
    func fetchListAndReloadData(){
    
        self.itineraryList =  self.appDelegate!.fetchItineraryList()
        //self.appDelegate!.fetchItineraryList()
        listView.reloadData()
    }
    
    func goToIteneraryPageWithRow(section : Int , row : Int , sender : AnyObject? ){
        if let viewController = self.getViewController("ItineraryViewController") as? ItineraryViewController  {
            var  type : ItineraryActionType?
            if let _ : UIBarButtonItem = sender as? UIBarButtonItem {
                //button event add
                type = ItineraryActionType.CreateItinerary
            }else{
                //cell tapped
                type = ItineraryActionType.ViewItinerary
                
                
                let item = self.getItemByIndex(section, row: row)
                
                
                viewController.itineraryItem = (item.item, item.managedObject)
            }
            
            viewController.itineraryAction = type
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func goItineraryAction(sender : AnyObject?){
        self.goToIteneraryPageWithRow(0, row : 0,sender : sender)
        
    }
    
    func getItemByIndex(section : Int ,row : Int)->(item : Itinerary , managedObject : ItineraryManagedObjectModel){
        let (_ , array) = getItemsPer(section)!
        
        
        let managedObjectItem = array[row]
        
        
        let item = Itinerary()
        if let data = managedObjectItem.destination ,
            unArchievedData : AnyObject = data.unArchived() ,
            destination = unArchievedData as? UserLocation {
                item.destination = destination
                
        }
        
        if let data = managedObjectItem.origin,
            unArchievedData : AnyObject  = data.unArchived(),
            origin = unArchievedData as? UserLocation {
                item.origin = origin
        }
        
        if let dateAndTime = managedObjectItem.dateAndTime {
            item.dateAndTime = dateAndTime
            
        }
        
        return (item : item , managedObject :  managedObjectItem)
    }
    

    func getItemsPer(section : Int)->(title : String , array : [ItineraryManagedObjectModel])?{
        if let myDict = self.itineraryList{
            let key : String = Array(myDict.keys)[section]
            var title : String!
            if (key == "PASSED"){
                title = "Past itineraries"
            }else{
                title = "Upcoming itineraries"
            }
            
            return (title : title , array : (myDict[key] as? [ItineraryManagedObjectModel])!)
        }
        return nil
    }
}


extension ItineraryListViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0;
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let myCell = cell as? ItineraryTableViewCell {
            let row : Int = indexPath.row
            let section : Int = indexPath.section
            let item = getItemByIndex(section, row: row)

            myCell.setLabelValueForDateAndTime(item.item.dateAndTime, origin: item.item.origin?.stringAddress, destination: item.item.destination?.stringAddress)
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
        view.backgroundColor = UIColor.darkTextColor()
        
        let label = UILabel()
        
        let (title , _) = self.getItemsPer(section)!
        label.text  = title
        label.textColor = UIColor.grayColor()
        label.font = UIFont.boldSystemFontOfSize(14)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [String] = ["H:|-10-[label]-0-|","V:|-0-[label]-0-|"]
        let views = ["label": label,"view": view]
        
        for constraint in constraints {
            let layoutConstraints = NSLayoutConstraint.constraintsWithVisualFormat(constraint, options: NSLayoutFormatOptions(), metrics: nil, views: views)
            view.addConstraints(layoutConstraints)
        }
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            
            
            let (_ , itemManagedObject) = self.getItemByIndex(indexPath.section, row: indexPath.row)
            self.appDelegate?.deleteItineraryItem(itemManagedObject , completionHandler: {
                [unowned self](success) -> Void in
                self.view.hideProgressIndicator()
                
                self.showAlertMessageWithAlertAction(nil,
                    delegate: self,
                    message: "Itinerary removed",
                    title: "",
                    withCancelButton: false,
                    okButtonTitle: "",
                    alertTag: AlertTagType.DeletedItemAlert,
                    cancelTitle: "",
                    dimissBlock : {
                        [unowned self]()->Void in
                        self.fetchListAndReloadData()
                    } ,
                    fadeDismiss: true)
                })
           
        }
    }
}
extension ItineraryListViewController : UITableViewDataSource{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell : ItineraryTableViewCell = tableView.dequeueReusableCellWithIdentifier("ItineraryCellIdentifier") as! ItineraryTableViewCell
        return cell
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row : Int = indexPath.row
        let section : Int = indexPath.section;
        
        self.goToIteneraryPageWithRow(section , row : row, sender: nil)
      
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = itineraryList {
            let (_ , array) = self.getItemsPer(section)!
            return array.count
        }   
        return 0;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.itineraryList!.count;
    }
}