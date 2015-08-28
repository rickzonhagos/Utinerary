//
//  ItineraryListViewController.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class ItineraryListViewController: BaseViewController {

    @IBOutlet weak var listView: UITableView!
    
    private var itineraryList : [Itinerary]?
    
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
    // MARK:
    // MARK: Add Itinerary
    // MARK:
    
}


extension ItineraryListViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0;
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let myCell = cell as? ItineraryTableViewCell {
            let row : Int = indexPath.row
            let item = itineraryList![row]
            myCell.setLabelValueForDateAndTime(item.dateAndTime, destination: item.destination?.stringAddress)
        }
    }
}
extension ItineraryListViewController : UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell : ItineraryTableViewCell = tableView.dequeueReusableCellWithIdentifier("ItineraryCellIdentifier") as! ItineraryTableViewCell
        
        
        return cell
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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