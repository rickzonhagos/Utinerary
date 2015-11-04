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
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Utinerary", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    // MARK : Core Data
    func insertItinerary(user : Itinerary!, notifID : String!, completionHandler : completionBlock){
        if let  itineraryEntity : NSManagedObject  =  NSEntityDescription.insertNewObjectForEntityForName("Itinerary", inManagedObjectContext: self.managedObjectContext){
                
                itineraryEntity.setValue(user.dateAndTime, forKey: "dateAndTime")
                itineraryEntity.setValue(user.destination?.archive(), forKey: "destination")
                itineraryEntity.setValue(user.origin?.archive(), forKey: "origin")
                itineraryEntity.setValue(notifID, forKey: "notifID")
                do{
                    try self.managedObjectContext.save()
                    self.scheduleNotificationWithFireDate(user.dateAndTime, notifID: notifID, destinationAddress : (user.destination?.stringAddress)!)
                    completionHandler(success: true)
                }catch let error as NSError{
                    print("Could not save \(error), \(error.userInfo)")
                    completionHandler(success: false);
                }
        }
    }
    
    
    func fetchItineraryList()->[String : AnyObject]?{
        if let context : NSManagedObjectContext =  self.managedObjectContext,
            fetchRequest = NSFetchRequest(entityName: "Itinerary") as NSFetchRequest?{
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAndTime", ascending: false)]
                
                do {
                    let fetchResult = try context.executeFetchRequest(fetchRequest) as? [ItineraryManagedObjectModel]
                    var items  = [String : [ItineraryManagedObjectModel]]()
                    
                    var passedItems = [ItineraryManagedObjectModel]()
                    var upComingItems = [ItineraryManagedObjectModel]()
                    if let results = fetchResult where results.count > 0 {
                        for  item in results {
                            if (item.dateAndTime!.timeIntervalSinceNow < 0.0){
                                //passed
                                passedItems.append(item)
                            }else{
                                //
                                upComingItems.append(item)
                            }
                        }
                        if upComingItems.count > 0 {
                            
                            items["INCOMING"] = upComingItems.sort({ $0.dateAndTime!.compare($1.dateAndTime!) == NSComparisonResult.OrderedAscending})
                        }
                        
                        if passedItems.count > 0{
                            items["PASSED"] = passedItems
                        }
                    }
                    return items
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                    return nil
                }
        }
        return nil
    }
    
    
   
    func updateItinerary(managedObject : NSManagedObject! ,  completionHandler : completionBlock){
        if let context  : NSManagedObjectContext = self.managedObjectContext {
           
            do{
                try context.save()
                if let notifID = managedObject.valueForKey("notifID") as? String{
                    cancelNotificationWith(notifID)
                    managedObject.valueForKey("destination")
                    
                    
                    
                    
                    if let date = managedObject.valueForKey("dateAndTime") as? NSDate ,
                        destinationObject = managedObject.valueForKey("destination") as? NSData,
                    unArchievedData : AnyObject = destinationObject.unArchived(),
                    destination = unArchievedData as? UserLocation {
                        
                        self.scheduleNotificationWithFireDate(date, notifID: notifID, destinationAddress : destination.stringAddress)
                    }
                    
                }
                completionHandler(success: true)
            }catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
                completionHandler(success: false)
            }
        }
    }
    
    func fetchItineraryItemBy(notifID : String! , completionHandler : fetchCompletionBlock){
        if let context : NSManagedObjectContext =  self.managedObjectContext,
            fetchRequest = NSFetchRequest(entityName: "Itinerary") as NSFetchRequest?{
                
                
                let predicate = NSPredicate(format: "notifID == %@",notifID)
                fetchRequest.predicate = predicate
                
                do{
                    let fetchResult = try context.executeFetchRequest(fetchRequest)
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
                            
                            
                            if let dateAndTime = result.valueForKey("dateAndTime") as? NSDate {
                                item.dateAndTime = dateAndTime
                            }
                            
                            completionHandler(success: true, item: item)
                        }
                    }
                }catch let error as NSError{
                    print("Could not save \(error), \(error.userInfo)")
                    completionHandler(success: false, item: nil)
                }
        }
        completionHandler(success: false, item: nil)
    }
    
    func deleteItineraryItem(object : NSManagedObject! , completionHandler : completionBlock){
        if let context  : NSManagedObjectContext = self.managedObjectContext {
            
            let notifID = object.valueForKey("notifID") as? String
            
            context.deleteObject(object)
            
            do{
                try context.save()
                
                if let id = notifID {
                    cancelNotificationWith(id)
                }
                
                completionHandler(success: true)
            }catch let error as NSError{
                completionHandler(success: false)
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    let categoryID : String = "CATEGORY"
   
    
    // MARK: Notification
    @available(iOS 8.0, *)
    func registerNotification() {
       
            let bookToUber = UIMutableUserNotificationAction()
            bookToUber.identifier = LocationNotificationAction.BookToUber.rawValue
            bookToUber.title = "Get an Uber ride"
            bookToUber.activationMode = UIUserNotificationActivationMode.Foreground
            bookToUber.destructive = true
            
            /*
            let view = UIMutableUserNotificationAction()
            view.identifier = LocationNotificationAction.View.rawValue
            view.title = "View"
            view.activationMode = UIUserNotificationActivationMode.Foreground
            view.destructive = true
            */
            
            let category = UIMutableUserNotificationCategory()
            category.identifier = categoryID
            
            // A. Set actions for the default context
            category.setActions([bookToUber], forContext: UIUserNotificationActionContext.Default)
            
            // B. Set actions for the minimal context
            category.setActions([bookToUber],
                forContext: UIUserNotificationActionContext.Minimal)
            
        
            let settings = UIUserNotificationSettings(forTypes: [.Alert,.Sound], categories: (NSSet(array: [category])) as? Set<UIUserNotificationCategory>)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
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
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func scheduleNotificationWithFireDate(fireDate : NSDate!, notifID : String!, destinationAddress : String?) {
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // Schedule the notification ********************************************
        let notification = UILocalNotification()
        var message : String!
        if let destinationAddress = destinationAddress {
            message =  "You’re scheduled to travel to \(destinationAddress)"
        }else{
            message =  "You’re scheduled to travel"
        }
        
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = fireDate
        
       notification.category = categoryID
        
        notification.userInfo = ["notifID":notifID]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)

    }
    
    func cancelNotificationWith(notifID : String!){
        let app:UIApplication = UIApplication.sharedApplication()
        for oneEvent in app.scheduledLocalNotifications! {
            let userInfoCurrent = oneEvent.userInfo! as! [String:AnyObject]
            let uid = userInfoCurrent["notifID"]! as! String
            if uid == notifID {
                //Cancelling local notification
                app.cancelLocalNotification(oneEvent)
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

