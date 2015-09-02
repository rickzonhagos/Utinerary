//
//  LocationManager.swift
//  Utinerary
//
//  Created by rickzon hagos on 24/8/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit
import MapKit

typealias GeoCodeCompletionHandler =  (address :  String?, success : Bool)->Void


protocol LocationManagerDelete {
    func didGetUserLocation(location : [AnyObject]!)
    func didFailToGetLocationWithError(message : String!)
}

class LocationManager: NSObject {
    static let sharedInstance = LocationManager()

    
    private var locationManager : CLLocationManager!
    private  var geoCode : CLGeocoder!
    
    
    var myDelegate : LocationManagerDelete?
    
    
    private override init(){
        super.init()
        
        initLocationManager()
        initGeoCoder()
        
    }
    
    // MARK: Location Manager
    private func initLocationManager(){
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        if (UIDevice.currentDevice().systemVersion as? NSString)?.floatValue >= 8.0 {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func startRetrieveLocation(){
        locationManager.startUpdatingLocation()
    }
    
    // MARK : Geo Code
    private func initGeoCoder(){
        self.geoCode = CLGeocoder()
        
    }
    
    
    func startGeoCodeWithLocation(location : CLLocation , completionHandler : GeoCodeCompletionHandler){
        geoCode.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                completionHandler(address: nil, success: false)
            }
            
            if let pm = placemarks as? [CLPlacemark] where pm.count > 0 {
                
                let placeMark = pm[0]
                let location = placeMark.location
                
                var fullAdress : String = String()
                
                
                if let name = placeMark.name{
                    fullAdress = name
                }
                if let locality = placeMark.locality{
                    fullAdress = fullAdress + " "+locality
                }
                if let subLocality = placeMark.subLocality{
                    fullAdress = fullAdress + " "+subLocality
                }
                if let postalCode = placeMark.postalCode{
                    fullAdress = fullAdress + " "+postalCode
                }
                
                completionHandler(address: fullAdress, success: true)
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
        if error.domain == kCLErrorDomain {
            var message : String?
            switch(error.code){
                case CLError.Denied.hashValue:
                    if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                        message = Constant.CoreLocationMessage.AuthorizationPrivacySettingsDenied
                    }else{
                        message = Constant.CoreLocationMessage.LocationServiceIsTurnedOff
                    }
            
                case CLError.LocationUnknown.hashValue:
                    message = Constant.CoreLocationMessage.UnknownLocation
                default:
                    message = Constant.CoreLocationMessage.UnknownLocation
            }
            
            if let delegate = myDelegate {
                delegate.didFailToGetLocationWithError(message)
            }
        }
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let delegate = myDelegate {
            delegate.didGetUserLocation(locations)
            self.locationManager.stopUpdatingLocation()
        }
        
    }
}
