//
//  Extensions.swift
//  Utinerary
//
//  Created by rickzon hagos on 29/8/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

typealias alertActionBlock = (action : AlertAction) -> Void
enum AlertAction {
    case Ok
    case Cancel
}

extension UIView {
    
    // MARK:
    // MARK: MBProgressHUD
    // MARK:
    
    /**
    Show Progress Indicator on the current View
    */
    func showProgressIndicatorWithLoadingMessage(message : String = "Loading..."){
        if let myVC = (self.nextResponder() as? BaseViewController){
            if myVC.myProgressIndicator == nil {
                let hud : MBProgressHUD = MBProgressHUD.showHUDAddedTo(self, animated: true)
                hud.dimBackground = true
                hud.delegate = myVC
                hud.labelText = message
                
                myVC.myProgressIndicator = hud
            }
        }
    }
    
    /**
    Hide Progress Indicator on the current View
    */
    func hideProgressIndicator(){
        if let myVC = (self.nextResponder() as? BaseViewController){
            MBProgressHUD.hideHUDForView(self, animated: true)
        }
    }
    
}


extension UIViewController {
    func showAlertMessageWithAlertAction(action : alertActionBlock?, delegate : UIAlertViewDelegate?, message : String?, title : String = " ", withCancelButton : Bool, okButtonTitle : String = "Ok", alertTag: AlertTagType, cancelTitle : String = "Cancel") -> Void{
        if objc_getClass("UIAlertController") != nil {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertOk : UIAlertAction = UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.Default, handler:{
                (alert : UIAlertAction!) -> Void in
                if let myHandler = action {
                    myHandler(action : AlertAction.Ok)
                }
                
            })
            alert.addAction(alertOk)
            
            
            if withCancelButton {
                let alertCancel : UIAlertAction = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.Cancel, handler: {
                    (alert : UIAlertAction!) -> Void in
                    if let myHandler = action {
                        myHandler(action : AlertAction.Cancel)
                    }
                })
                alert.addAction(alertCancel)
            }
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            let alert : UIAlertView = UIAlertView(title: title, message: message!, delegate: delegate, cancelButtonTitle: ((withCancelButton) ? cancelTitle : nil) , otherButtonTitles: okButtonTitle)
            alert.tag = alertTag.rawValue
            alert.show()
        }
    }
}