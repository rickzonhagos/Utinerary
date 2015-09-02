//
//  AppDelegate.swift
//  Utinerary
//
//  Created by Cirrena on 8/18/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        Flurry.startSession(Constant.FlurryAPIKey)
        Flurry.setCrashReportingEnabled(true)
        registerNotification()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "ph.com.Utinerary" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Utinerary", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Utinerary.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    
    // MARK : Core Data
    func insertItinerary(user : Itinerary!, notifID : String!, completionHandler : completionBlock){
        if let context : NSManagedObjectContext =  self.managedObjectContext,
             itineraryEntity  =  NSEntityDescription.insertNewObjectForEntityForName("Itinerary", inManagedObjectContext: context) as? NSManagedObject{
                
                itineraryEntity.setValue(user.dateAndTime, forKey: "dateAndTime")
                itineraryEntity.setValue(user.destination?.archive(), forKey: "destination")
                itineraryEntity.setValue(user.origin?.archive(), forKey: "origin")
                itineraryEntity.setValue(notifID, forKey: "notifID")
                var error : NSError?
                if !context.save(&error){
                    println("save Error \(error?.localizedDescription)")
                    completionHandler(success: false);
                    return;
                }
                
                
                self.scheduleNotificationWithFireDate(user.dateAndTime, notifID: notifID)
                
                completionHandler(success: true)
        }
    }
    
    
    func fetchItineraryList()->[[AnyObject]]?{
        if let context : NSManagedObjectContext =  self.managedObjectContext,
            fetchRequest = NSFetchRequest(entityName: "Itinerary") as NSFetchRequest?{
            var error : NSError?
                
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAndTime", ascending: false)]
            if let fetchResult = context.executeFetchRequest(fetchRequest, error: &error) {
                var items  = [[AnyObject]]()
                
                for  result in fetchResult {
                    if result is NSManagedObject {
                        
                        let item = Itinerary()
                        if let data = result.valueForKey("destination") as? NSData ,
                            unArchievedData : AnyObject = data.unArchived() ,
                            destination = unArchievedData as? UserLocation {
                            item.destination = destination
                            
                        }
                        
                        if let data = result.valueForKey("origin") as? NSData,
                            unArchievedData : AnyObject  = data.unArchived(),
                            origin = unArchievedData as? UserLocation {
                                item.origin = origin 
                        }
                       
                        item.dateAndTime = result.valueForKey("dateAndTime") as? NSDate
                        
                        items.append([item, result])
                        
                    }
                }
                return items
            }
            return nil
        }
        return nil
    }
    
    func updateItinerary(managedObject : NSManagedObject! ,  completionHandler : completionBlock){
        if let context  : NSManagedObjectContext = self.managedObjectContext {
            var error : NSError?
            
            
            if !context.save(&error){
                println("Update Error \(error?.localizedDescription)")
                completionHandler(success: false)
              
                return
            }
            
            if let notifID = managedObject.valueForKey("notifID") as? String{
                cancelNotificationWith(notifID)
                
                if let date = managedObject.valueForKey("dateAndTime") as? NSDate {
                    self.scheduleNotificationWithFireDate(date, notifID: notifID)
                }
                
            }
            completionHandler(success: true)
        }
    }
    
    func fetchItineraryItemBy(notifID : String! , completionHandler : fetchCompletionBlock){
        if let context : NSManagedObjectContext =  self.managedObjectContext,
            fetchRequest = NSFetchRequest(entityName: "Itinerary") as NSFetchRequest?{
                var error : NSError?
                
                
                let predicate = NSPredicate(format: "notifID == %@",notifID)
                fetchRequest.predicate = predicate
                
                if let fetchResult = context.executeFetchRequest(fetchRequest, error: &error) {
                    for  result in fetchResult {
                        if result is NSManagedObject {
                            let item = Itinerary()
                            if let data = result.valueForKey("destination") as? NSData ,
                                unArchievedData : AnyObject = data.unArchived() ,
                                destination = unArchievedData as? UserLocation {
                                    item.destination = destination
                                    
                            }
                            
                            if let data = result.valueForKey("origin") as? NSData,
                                unArchievedData : AnyObject  = data.unArchived(),
                                origin = unArchievedData as? UserLocation {
                                    item.origin = origin
                            }
                            
                            item.dateAndTime = result.valueForKey("dateAndTime") as? NSDate
                            completionHandler(success: true, item: item)
                        }
                    }
                    completionHandler(success: false, item: nil)
                }
                completionHandler(success: false, item: nil)
        }
        completionHandler(success: false, item: nil)
    }
    
    func deleteItineraryItem(object : NSManagedObject! , completionHandler : completionBlock){
        if let context  : NSManagedObjectContext = self.managedObjectContext {
            
            let notifID = object.valueForKey("notifID") as? String
                
            
            
            context.deleteObject(object)
            var error : NSError?
            if !context.save(&error){
                println("Delete Error \(error?.localizedDescription)")
                completionHandler(success: false)
                
                return
                
            }
            
            if let id = notifID {
                cancelNotificationWith(id)
            }
            
    

            completionHandler(success: true)
        }
    }
    
    var categoryID:String {
        get{
            return "CATEGORY"
        }
    }
    
    // MARK: Notification
    func registerNotification() {
        if objc_getClass("UIMutableUserNotificationAction") != nil {
            let bookToUber = UIMutableUserNotificationAction()
            bookToUber.identifier = LocationNotificationAction.BookToUber.rawValue
            bookToUber.title = "Book to Uber"
            bookToUber.activationMode = UIUserNotificationActivationMode.Foreground
            bookToUber.destructive = true
            
            let view = UIMutableUserNotificationAction()
            view.identifier = LocationNotificationAction.View.rawValue
            view.title = "View"
            view.activationMode = UIUserNotificationActivationMode.Foreground
            view.destructive = true
            
            
            let category = UIMutableUserNotificationCategory()
            category.identifier = categoryID
            
            // A. Set actions for the default context
            category.setActions([bookToUber, view], forContext: UIUserNotificationActionContext.Default)
            
            // B. Set actions for the minimal context
            category.setActions([bookToUber, view],
                forContext: UIUserNotificationActionContext.Minimal)
            
            
            
            let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: types, categories: NSSet(object: category) as Set<NSObject>)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //will trigger when 
        // 1. clicked 
        // 2. received a notification when app is active

        self.navigateToNotificationPage(notification , action : nil)
    }
    
    
    func navigateToNotificationPage(notification: UILocalNotification , action : String?){
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewControllerWithIdentifier("NotificationViewController") as? NotificationViewController
        
        if let rootView = self.window?.rootViewController as? UINavigationController{
            
            
            if viewController!.isBeingPresented() {
                viewController!.dismissViewControllerAnimated(true, completion: nil)
            }
            
            rootView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            
            if let info = notification.userInfo! as? [String:AnyObject] , notifID = info["notifID"] as? String{
                viewController?.notifID = notifID
                if action != nil{
                    viewController?.actionType = action
                }
            }
            
            rootView.presentViewController(viewController!, animated: true, completion: nil)
        }
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func scheduleNotificationWithFireDate(fireDate : NSDate!, notifID : String!) {
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // Schedule the notification ********************************************
        let notification = UILocalNotification()
        notification.alertBody = "Notification ;) \(notifID)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = fireDate
        
        if (UIDevice.currentDevice().systemVersion as? NSString)?.floatValue >= 8.0 {
            notification.category = categoryID
        }
        
        notification.userInfo = ["notifID":notifID]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)

    }
    
    func cancelNotificationWith(notifID : String!){
        var app:UIApplication = UIApplication.sharedApplication()
        for oneEvent in app.scheduledLocalNotifications {
            var notification = oneEvent as! UILocalNotification
            let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
            let uid = userInfoCurrent["notifID"]! as! String
            if uid == notifID {
                //Cancelling local notification
                app.cancelLocalNotification(notification)
                break;
            }
        }
    }
    
    
    func application(application: UIApplication,
        handleActionWithIdentifier identifier: String?,
        forLocalNotification notification: UILocalNotification,
        completionHandler: () -> Void) {
            
            
            self.navigateToNotificationPage(notification, action : identifier)
            completionHandler()
    }
}

