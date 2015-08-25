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
    
    @IBAction func close(sender : AnyObject?){
        self.dismissViewControllerAnimated(true,completion: nil)
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
            let mapView  =   storyBoard.instantiateViewControllerWithIdentifier("MapViewController") as? MapViewController
            
            self.navigationController?.pushViewController(mapView!, animated: true)
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
