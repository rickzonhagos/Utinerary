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

protocol MapViewControllerDelegate : class{
    func didFinishWithUserLocation(user : UserLocation! , locationType : LocationType)
}


class MapViewController: BaseViewController{
    
    
    let cellReuseIdentifier : String = "SearchResultTableCellIdentifier"
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private  weak var mapView: MKMapView!
    
    var locationManager : LocationManager = LocationManager.sharedInstance
    
    private var searchItems : [MKMapItem]?
    
    var locationType : LocationType?
    
    
    weak var myDelegate : MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.myDelegate = self
        
        initMapView()
        
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        self.searchDisplayController?.searchResultsTableView.registerNib(nib, forCellReuseIdentifier: cellReuseIdentifier)
        
        
        self.view.showProgressIndicatorWithLoadingMessage("Retrieving Location")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startRetrieveLocation()
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Map View
    private func initMapView(){
        //mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.showsUserLocation = false
        if #available(iOS 9.0, *) {
            mapView.showsCompass = true
            mapView.showsScale = true
        } else {
            // Fallback on earlier versions
        }
        
        
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
        
        
        self.startGeoCodeWithLocationManager(location) {
            [unowned self](address, success , placeMark) -> Void in

            if success {
                self.createAnotationWithTitle(address, coordinate: location.coordinate, subTitle: nil, shouldZoom: false , isSelectedAnnotation : true)
            }else {
                self.createAnotationWithTitle(nil, coordinate: location.coordinate, subTitle: nil, shouldZoom: false , isSelectedAnnotation : true)
            }
            self.view.hideProgressIndicator()
        }
        
    }
    
    func createAnotationWithTitle(title : String? , coordinate : CLLocationCoordinate2D! , subTitle : String?, shouldZoom : Bool ,isSelectedAnnotation : Bool){
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        
        let anotation : MKAnnotation = Utils.createMapAnotationWithTitle(title, coordinate: coordinate , subTitle : subTitle)
        mapView.addAnnotation(anotation)
        

        mapView.selectAnnotation(anotation, animated: true)
        mapView.centerCoordinate = coordinate
        if shouldZoom{
           //mapView.centerCoordinate
            self.zoomToLocation(coordinate)
           
        }
    }
    
    func zoomToLocation(location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpanMake(0.02, 0.02))
        let  adjustedRegion : MKCoordinateRegion = self.mapView.regionThatFits(region)
        
        mapView.centerCoordinate = location
        self.mapView.setRegion(adjustedRegion, animated: true)
  
    }
    
    func extractFullAddress(address : [NSObject : AnyObject]?)->String?{
        guard let address = address else {
            return nil
        }
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
        
        print("\(address)", terminator: "")
        
        return subHeader
    }
    
    // MARK: Search Bar
    func initSearchBarAndSearchController(){
        searchBar.delegate = self
        
        self.searchDisplayController?.delegate = self
    }
    
    // MARK: Button Event
    
    @IBAction private func navigationButtonEvent(sender : UIBarButtonItem){
        
        if sender.tag == 1000 {
            //This is Done Button
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        var location : CLLocation?
        
        if let anotations : [MKAnnotation] = mapView.selectedAnnotations where anotations.count > 0 {
            
            let coordinate : CLLocationCoordinate2D = anotations[0].coordinate
            location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
 
        }
        
        
        self.startGeoCodeWithLocationManager( location!) {
            [unowned self](address, success , placeMark) -> Void in
            var userDesiredLocation : UserLocation?
            if success {
                userDesiredLocation  = UserLocation(address: address!, currentLocation: location!, placeMark : placeMark)
            }else{
                userDesiredLocation  = UserLocation(currentLocation: location!, placeMark : placeMark)
            }
            
            self.view.hideProgressIndicator()
            
            self.dismissViewControllerAnimated(true, completion: {
                [unowned self]() -> Void in
                self.myDelegate!.didFinishWithUserLocation(userDesiredLocation ,locationType : self.locationType!)
            })
        }
    }
    
    // MARK: Geo Code
    func startGeoCodeWithLocationManager( location : CLLocation!,
        completionHandler : GeoCodeCompletionHandler){
            
            if let currentLocation = location{
                //self.view.showProgressIndicatorWithLoadingMessage()
                locationManager.startGeoCodeWithLocation(currentLocation, completionHandler:completionHandler)
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
            if let item : MKMapItem = items[row]{
                let fullAddress = self.extractFullAddress(item.placemark.addressDictionary)
            
                self.createAnotationWithTitle(item.name, coordinate: item.placemark.location?.coordinate, subTitle: fullAddress, shouldZoom: true , isSelectedAnnotation : true)
               
                self.searchDisplayController?.searchResultsTableView.hidden = true
                self.searchDisplayController?.setActive(false, animated: true)
            }
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
        
        if let anotations : [MKAnnotation] = mapView.selectedAnnotations where anotations.count > 0 {
            let region = MKCoordinateRegionMakeWithDistance(anotations[0].coordinate,  120701,  120701)
            
            
            mapView.setRegion(region, animated: true)
            self.view.showProgressIndicatorWithLoadingMessage("Searching...")
            locationManager.startLocationSearchWithSearchString(searchString, region: mapView.region) {
                [unowned self](mapItems) -> (Void) in
                
                self.searchItems = mapItems
                self.searchDisplayController?.searchResultsTableView.reloadData()
                self.view.hideProgressIndicator()
            }
        }else{
            //no User Location
            self.showAlertMessageWithAlertAction(nil, delegate: nil, message: Constant.CoreLocationMessage.UnknownLocation, title: " ", withCancelButton: false, okButtonTitle: "Ok", alertTag: AlertTagType.Nothing, cancelTitle: "Cancel" , dimissBlock : nil)
        }
        
        
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
        
    }
    
    
    
}
extension MapViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, didFailToLocateUserWithError : NSError) {
        self.view.hideProgressIndicator()
    }
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if let annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") {
            return annotationView
        }else{
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView.pinColor = MKPinAnnotationColor.Purple
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            annotationView.rightCalloutAccessoryView!.tintColor = UIColor.blackColor()
            annotationView.animatesDrop = true
            annotationView.enabled = true
            
            return annotationView
        }
        
    }
}

extension MapViewController : LocationManagerDelete{
    func didFailToGetLocationWithError(message : String!) {
        self.view.hideProgressIndicator()
        self.showAlertMessageWithAlertAction(nil, delegate: nil, message: message, title: " ", withCancelButton: false, okButtonTitle: "Ok", alertTag: AlertTagType.Nothing, cancelTitle: "Cancel", dimissBlock : nil)
    }
    func didGetUserLocation(location: [AnyObject]!) {
        
        if let _ : [AnyObject]  = location  , currentLocation = location.last as? CLLocation where location.count > 0 {
            print(currentLocation, terminator: "")
            
            self.startGeoCodeWithLocationManager(currentLocation) {
                [unowned self](address, success , placeMark) -> Void in
                if success {
                    self.createAnotationWithTitle(address, coordinate: currentLocation.coordinate, subTitle: nil, shouldZoom: true , isSelectedAnnotation : false)
                }else {
                    self.createAnotationWithTitle(nil, coordinate: currentLocation.coordinate, subTitle: nil, shouldZoom: true, isSelectedAnnotation : false)
                }
                self.view.hideProgressIndicator()
            }
        }
        self.view.hideProgressIndicator()

    }
}
