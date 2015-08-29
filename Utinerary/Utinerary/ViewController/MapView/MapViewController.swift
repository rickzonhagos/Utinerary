//
//  MapViewController.swift
//  Utinerary
//
//  Created by rickzon hagos on 22/8/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

import MapKit

typealias LocationSearchCompletionBlock  =  (mapItems : [MKMapItem]?)->(Void)
enum LocationType : Int{
    case Origin = 0
    case Destination = 1
}

protocol MapViewControllerDelegate {
    func didFinishWithUserLocation(user : UserLocation! , locationType : LocationType)
}


class MapViewController: BaseViewController{
    
    
    let cellReuseIdentifier : String = "SearchResultTableCellIdentifier"
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private  weak var mapView: MKMapView!
    
    var locationManager : LocationManager?
    
    private var searchItems : [MKMapItem]?
    
    private var userLocation : CLLocationCoordinate2D?
    
    
    private var selectedAnotation : MKAnnotation?
    var locationType : LocationType?
    
    
    
     var myDelegate : MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager = LocationManager.sharedInstance
        
        
        initMapView()
        
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        self.searchDisplayController?.searchResultsTableView.registerNib(nib, forCellReuseIdentifier: cellReuseIdentifier)
        
        
        self.view.showProgressIndicatorWithLoadingMessage(message: "Retrieving Location")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Map View
    private func initMapView(){
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longPress:"))
        longPress.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPress)
        
    }
    
    @IBAction func longPress(gestureRecognizer : UIGestureRecognizer!){
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){
            return
        }
        
    
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let coordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        
        self.startGeoCodeWithLocationManager(locationManager!, location: location) {
            [unowned self](address, success) -> Void in

            if success {
                self.createAnotationWithTitle(address, coordinate: location.coordinate, subTitle: nil, shouldZoom: true)
            }else {
                self.createAnotationWithTitle(nil, coordinate: location.coordinate, subTitle: nil, shouldZoom: true)
            }
            self.view.hideProgressIndicator()
        }
        
    }
    
    func createAnotationWithTitle(title : String? , coordinate : CLLocationCoordinate2D! , subTitle : String?, shouldZoom : Bool){
        let anotation : MKAnnotation = LocationManager.createMapAnotationWithTitle(title, coordinate: coordinate , subTitle : subTitle)
        mapView.addAnnotation(anotation)
        
        self.selectedAnotation = anotation
        
        
        mapView.selectAnnotation(anotation, animated: true)
        mapView.centerCoordinate = coordinate
        if shouldZoom{
            self.zoomToLocation(coordinate)
        }
    }
    
    func zoomToLocation(location: CLLocationCoordinate2D){
        mapView.centerCoordinate = location
    }
    
    func extractFullAddress(address : [NSObject : AnyObject]!)->String?{
        
        var subHeader : String = String()
        
        if let street = address["Street"] as? String {
            subHeader = street+" "
        }
        if let city = address["City"] as? String {
            subHeader = subHeader + " " + city
        }
        if let state = address["State"] as? String {
            subHeader = subHeader + " " + state
        }
        
        println("\(address)")
        
        return subHeader
    }
    
    // MARK: Search Bar
    func initSearchBarAndSearchController(){
        searchBar.delegate = self
        
        self.searchDisplayController?.delegate = self
    }
    
    // MARK: Button Event
    
    @IBAction private func navigationButtonEvent(sender : UIBarButtonItem){
        var location : CLLocation?
        if let anotations = selectedAnotation {
            
            let coordinate : CLLocationCoordinate2D = anotations.coordinate
            location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
 
        }else{
            if let currentLocation  = userLocation{
                location  = CLLocation(latitude: userLocation!.latitude, longitude: userLocation!.longitude)
            }
        }
        
        
        self.startGeoCodeWithLocationManager(locationManager!, location: location!) {
            [unowned self](address, success) -> Void in
            var userDesiredLocation : UserLocation?
            if success {
                userDesiredLocation  = UserLocation(address: address!, currentLocation: location!)
            }else{
                userDesiredLocation  = UserLocation(currentLocation: location!)
            }
            
            self.view.hideProgressIndicator()
            
            self.dismissViewControllerAnimated(true, completion: {
                [unowned self]() -> Void in
                self.myDelegate!.didFinishWithUserLocation(userDesiredLocation ,locationType : self.locationType!)
            })
        }
    }
}

extension MapViewController : UITableViewDelegate , UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = searchItems {
            return items.count
        }
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let row  = indexPath.row
        if let items = searchItems {
            let item : MKMapItem = items[row]
           
            let fullAddress = self.extractFullAddress(item.placemark.addressDictionary)
            if let myCell = cell as? SearchTableViewCell {
                myCell.setTitle(item.name, subHeader: fullAddress)
            }
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as? SearchTableViewCell

        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row  = indexPath.row
        if let items = searchItems {
            let item : MKMapItem = items[row]
            
            let coords = item.placemark.location.coordinate
            
            let fullAddress = self.extractFullAddress(item.placemark.addressDictionary)
            
            self.createAnotationWithTitle(item.name, coordinate: coords, subTitle: fullAddress, shouldZoom: true)
            
            self.searchDisplayController?.searchResultsTableView.hidden = true
            self.searchDisplayController?.setActive(false, animated: true)
            
        }
    }
}
extension MapViewController : UISearchDisplayDelegate{
        
}
extension MapViewController : UISearchBarDelegate{
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool{
        
        return true
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
    }
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar){
        
    }
  
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchString = searchBar.text
    
        let region = MKCoordinateRegionMakeWithDistance(userLocation!,  120701,  120701)
        
        /*
        let span = MKCoordinateSpan(latitudeDelta: 0.112872, longitudeDelta: 0.109863)
        let region = MKCoordinateRegion(center: userLocation!, span: span)
        */
        mapView.setRegion(region, animated: true)
    
        
        locationManager!.startLocationSearchWithSearchString(searchString, region: mapView.region) {
            [unowned self](mapItems) -> (Void) in
            
            self.searchItems = mapItems
            self.searchDisplayController?.searchResultsTableView.reloadData()
            
        }
        
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
        
    }
    
}
extension MapViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView!, didFailToLocateUserWithError : NSError!) {
        
    }
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        self.view.hideProgressIndicator()
        
        self.userLocation = userLocation.coordinate
        let coords = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        self.zoomToLocation(coords)
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        
    }
    
}
