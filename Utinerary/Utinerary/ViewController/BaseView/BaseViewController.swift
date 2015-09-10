//
//  BaseViewController.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

import MapKit

enum AlertTagType : Int{
    case DeleteAlert = 0
    case DeletedItemAlert = 1
    case AddedItemAlert = 2
    case UpdatedItemAlert = 3
    case Nothing = 4
}


class BaseViewController: UIViewController {

    let appDelegate  = UIApplication.sharedApplication().delegate as? AppDelegate
    
    
    
    var myProgressIndicator : MBProgressHUD?
    
    let utinerarySharedInstance = UtinerarySharedInstance.sharedInstance
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit{
        
    }

    func getViewController(name : String!)->AnyObject?{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController : AnyObject = storyBoard.instantiateViewControllerWithIdentifier(name)
        return viewController
    }
    
    
    // MARK: Geo Code 
    func startGeoCodeWithLocationManager(manager : LocationManager! , location : CLLocation!,
        completionHandler : GeoCodeCompletionHandler){
        
            if let currentLocation = location{
                self.view.showProgressIndicatorWithLoadingMessage()
                manager!.startGeoCodeWithLocation(currentLocation, completionHandler:completionHandler)
            }
            
    }
}
extension BaseViewController : MBProgressHUDDelegate {
    func hudWasHidden(hud: MBProgressHUD!) {
        if myProgressIndicator != nil {
            myProgressIndicator!.removeFromSuperview()
            myProgressIndicator = nil
        }
    }
}
extension BaseViewController : UIAlertViewDelegate{
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
       
    }
}
