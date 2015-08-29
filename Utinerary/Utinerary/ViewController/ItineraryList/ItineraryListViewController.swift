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
    
    private var itineraryList : [[AnyObject]]?
    
    // MARK:
    // MARK: Life Cycle
    // MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchListAndReloadData()
        
    }
    
    func fetchListAndReloadData(){
    
        self.itineraryList =  self.appDelegate!.fetchItineraryList()
    
        listView.reloadData()
    }
    
    func goToIteneraryPageWithRow(row : Int , sender : AnyObject? ){
        if let viewController = self.getViewController("ItineraryViewController") as? ItineraryViewController  {
            var  type : ItineraryActionType?
            if let button : UIBarButtonItem = sender as? UIBarButtonItem {
                //button event add
                type = ItineraryActionType.CreateItinerary
            }else{
                //cell tapped
                type = ItineraryActionType.ViewItinerary
                
                
                let item = self.getItemByIndex(row)
                
                
                viewController.itineraryItem = (item.item, item.managedObject)
            }
            
            viewController.itineraryAction = type
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func goItineraryAction(sender : AnyObject?){
        self.goToIteneraryPageWithRow(0,sender : sender)
        
    }
    //
    func getItemByIndex(row : Int)->(item : Itinerary , managedObject : NSManagedObject){

        return (item : self.itineraryList![row][0] as! Itinerary , managedObject : self.itineraryList![row][1] as! NSManagedObject)
    }
    
}


extension ItineraryListViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0;
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let myCell = cell as? ItineraryTableViewCell {
            let row : Int = indexPath.row
            let item = getItemByIndex(row)
            myCell.setLabelValueForDateAndTime(item.item.dateAndTime, destination: item.item.destination?.stringAddress)
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

        self.goToIteneraryPageWithRow(row, sender: nil)
      
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = itineraryList {
            return items.count
        }
        return 0;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
}