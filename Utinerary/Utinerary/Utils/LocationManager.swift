//
//  LocationManager.swift
//  Utinerary
//
//  Created by rickzon hagos on 24/8/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import MapKit

typealias GeoCodeCompletionHandler =  (placemarks :  [CLPlacemark]?, success : Bool)->Void


class LocationManager: NSObject {
    static let sharedInstance = LocationManager()

    
    private var locationManager : CLLocationManager!
    private  var geoCode : CLGeocoder!
    
    
    
    
    
    private override init(){
        super.init()
        
        initLocationManager()
        initGeoCoder()
        
    }
    
    // MARK: Location Manager
    private func initLocationManager(){
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    // MARK : Geo Code
    private func initGeoCoder(){
        self.geoCode = CLGeocoder()
        
    }
    
    
    func startGeoCodeWithLocation(location : CLLocation , completionHandler : GeoCodeCompletionHandler){
        geoCode.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                completionHandler(placemarks: nil, success: false)
            }
            
            if let pm = placemarks as? [CLPlacemark] where pm.count > 0 {

                completionHandler(placemarks: pm, success: true)
            }
        })
    }
    
    // MARK: Location Search
    func startLocationSearchWithSearchString(search: String!, region : MKCoordinateRegion!, completionBlock : LocationSearchCompletionBlock){
        let request : MKLocalSearchRequest = MKLocalSearchRequest()
        request.naturalLanguageQuery = search
        request.region = region
        
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let localSearch : MKLocalSearch = MKLocalSearch(request: request)
        localSearch.startWithCompletionHandler {
            (response, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if (error != nil) {
                return
            }
            
            if let item = response.mapItems {
                println("\(response.mapItems)")
                completionBlock(mapItems: response.mapItems as? [MKMapItem])
            }
        }
    }
    
    
    class func createMapAnotationWithTitle(title : String? , coordinate : CLLocationCoordinate2D! , subTitle : String?)->MKAnnotation{
        let anotation : MKAnnotation  = MapAnotation(title: title, coordinate: coordinate, subTitle : subTitle)
        
        return anotation
    }
    
}

extension LocationManager : CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            
            
        }
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
}
