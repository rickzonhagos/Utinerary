//
//  ItineraryManagedObjectModel+CoreDataProperties.swift
//  Utinerary
//
//  Created by Cirrena on 04/11/2015.
//  Copyright © 2015 Sherwin De Jesus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ItineraryManagedObjectModel {

    @NSManaged var dateAndTime: NSDate?
    @NSManaged var destination: NSData?
    @NSManaged var notifID: String?
    @NSManaged var origin: NSData?

}
