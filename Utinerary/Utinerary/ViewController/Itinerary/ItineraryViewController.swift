//
//  ItineraryViewController.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class ItineraryViewController: BaseViewController {

    @IBOutlet private weak var myTableView: UITableView!
   
    private var originLocation : UserLocation?
    private var destinationLocation : UserLocation?
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Nav Button
    
    @IBAction func buttonEvent(sender : AnyObject?){
        
        if let button = sender as? UIBarButtonItem {
            if button.tag == 3000{
                //book to Uber
            }else {
               
                if button.tag == 1000 {
                    //save
                    if let cell = self.getCellByRow(2) , datePicker = cell.viewWithTag(3000) as? UIDatePicker{
                        
                        let itinerary = Itinerary()
                        itinerary.origin = originLocation
                        itinerary.destination = destinationLocation
                        itinerary.dateAndTime = datePicker.date
                        
                        self.appDelegate?.insertItinerary(itinerary)
                    }
                }else {
                    //delete 
                    
                }
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
}
extension ItineraryViewController : MapViewControllerDelegate{
    func didFinishWithUserLocation(user: UserLocation! , locationType : LocationType){
        if let cell = self.getCellByRow(locationType.rawValue),
            label = cell.viewWithTag(1) as? UILabel {
           label.text = user.stringAddress
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
            return 70
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
            cell = tableView.dequeueReusableCellWithIdentifier("OriginCellViewIdentifier") as? UITableViewCell
        }else if row == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("DestinationViewCellIdentifier") as? UITableViewCell
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("DateAndTimeViewCellIdentifier") as? UITableViewCell
        }
        
        return cell!
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
