//
//  ViewController.swift
//  Danger
//
//  Created by James Trever on 30/01/2016.
//  Copyright © 2016 James Trever. All rights reserved.
//



import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var findMe: MKUserTrackingBarButtonItem!
    var addIncident: UIBarButtonItem!
    var searchBar: UISearchBar!
    var currentLocation: CLLocation!
    var currentCounty: String!
    var firstLaunch = true
    var lastChecked: NSDate!
    var incidentAlert: Incident?

    // Zoom radius
    let regionRadius: CLLocationDistance = 1000
    
    // Location Manager
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
        
        //Set up searchbar
        self.searchBar = UISearchBar()
        self.searchBar.delegate = self
        self.searchBar.sizeToFit()
        self.searchBar.placeholder = "Incident in Other Cities"
        
        //Set up navbar
        self.navigationItem.titleView = self.searchBar
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        //Add find me button
        self.findMe = MKUserTrackingBarButtonItem.init(mapView: self.mapView)
        self.navigationItem.leftBarButtonItem = self.findMe
        
        //Add plus button
        self.addIncident = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action:"lauchIncidentPopup:")
        self.navigationItem.rightBarButtonItem = self.addIncident
        
        //Make it so we manage the location manager
        self.locationManager.delegate = self
        
        self.lastChecked = NSDate()
        
        
        
 
        
//        getCounty()
//        lauchIncidentPopup(self)
    }
    
    func addBoundry(coordinate: CLLocationCoordinate2D, radius: Int, level: String){
        let circle = MKCircle(centerCoordinate: coordinate, radius: Double(radius))
        circle.title = level
        
        mapView.addOverlay(circle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let incidentVC = segue.destinationViewController as? IncidentDetailVC
        incidentVC?.county = self.currentCounty
        incidentVC?.coord = self.currentLocation
        
    }
    
    
    func lauchIncidentPopup(sender: AnyObject) {
        performSegueWithIdentifier("IncidentSegue", sender: sender)
    }
    
    @IBAction func unwindFromIncidentPopup(segue: UIStoryboardSegue) {
        self.getCounty()
    }
    
    
    func getIncidents(city: String) {
        print(city)
        self.incidentAlert = nil
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        Alamofire.request(.GET, "http://188.166.154.26/incidents", parameters: ["region": city], headers: headers)
            .responseJSON { response in
                if (response.result.isSuccess == true) {
                    self.removeAnnotations()
                    let json = JSON(data: response.data!)
                    for (_,subJson):(String, JSON) in json {
                        print(subJson)
                        let coord = CLLocationCoordinate2D(latitude: subJson["lat"].double!, longitude: subJson["lon"].double!)
                        let radius = subJson["radius"].int!
                        let level = subJson["level"].string!
                        let lastUpdated = subJson["updated_at"].string!
                        let region = subJson["region"].string!
                        let report_count = subJson["report_count"].int!
                        let message = subJson["message"].string!
                        
                        let inc = Incident(locationName: region, coordinate: coord, radius: radius, report_count: report_count, level: level, message: message)
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//                        if let parsedDateTimeString = dateFormatter.dateFromString(lastUpdated) {
//                            print(dateFormatter.stringFromDate(parsedDateTimeString))
//                        } else {
//                            print("Could not parse date")
//                        }
                        if (self.lastChecked.compare(dateFormatter.dateFromString(lastUpdated)!) == NSComparisonResult.OrderedAscending) {
                            if (level == "emergency") {
                                self.incidentAlert = inc
                            }
                        }
                        
                        self.mapView.addAnnotation(inc)
                        self.addBoundry(coord, radius: radius, level: level)
                        
                    }
                }
                else {
                    let alertController = UIAlertController(title: nil, message: "Unable to connect to server", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
                if let incidentToNotify = self.incidentAlert {
                    let alertController = UIAlertController(
                        title: "DANGER",
                        message: "Incident currently happing in your area, would you like to view now",
                        preferredStyle: .Alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    let openAction = UIAlertAction(title: "View", style: .Default) { (action) in
                        let coordinateRegion = MKCoordinateRegionMakeWithDistance(incidentToNotify.coordinate, Double(incidentToNotify.radius!) * 1.0, Double(incidentToNotify.radius!) * 1.0)
                        self.mapView.setRegion(coordinateRegion, animated: true)
                    }
                    alertController.addAction(openAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                self.lastChecked = NSDate()
        }
        
    }


}


/////////////////////////////////
//MARK: CLLocationManagerDelegate
/////////////////////////////////
extension MapVC: CLLocationManagerDelegate {
    
    //location manager to authorize user location for Maps app
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //When location updates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.currentLocation = locations.first!
        centerMapOnLocation(locations.first!)
        
    }
    
    //When auth status changes
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            self.mapView.showsUserLocation = true
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.startUpdatingLocation()
            getCounty()

        }
    }
    
    func getCounty() {
        if self.locationManager.location != nil {
            self.currentLocation = self.locationManager.location
        }
        let geocoder = CLGeocoder()
        var city: String?
        geocoder.reverseGeocodeLocation(self.currentLocation) { (placemarks, error) -> Void in
            if ((error == nil)) {
                let placemark = placemarks?.first
                let placemarkDictionary = placemark?.addressDictionary
                city = placemarkDictionary?["City"] as? String ?? ""
                self.currentCounty = city!
                if (self.firstLaunch == true){
                    self.firstLaunch = false
                    self.lauchIncidentPopup(self)
                }
                else {
                    self.getIncidents(city!)
                }
            }
            else {
                print("Geocode failed with error ", error);
                print("\nCurrent Location Not Detected\n");
                city = ""
                let alertController = UIAlertController(
                    title: "Unable to get current location",
                    message: "Failed to get current location so will not be able to get or post recent incidents",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Try Again", style: .Default) { (action) in
                    self.getCounty()
                }
                alertController.addAction(openAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
}

///////////////////////
//MARK: MapViewDelegate
///////////////////////
extension MapVC: MKMapViewDelegate {
    
    // Like cell for row at index path for annotations/pins bubbles
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Incident {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -8, y: 5)
                //view.rightCalloutAccessoryView = UIButton(type:.DetailDisclosure) as UIView
                
            }
            view.pinTintColor = (annotation.level == "warning" ? UIColor.yellowColor() : UIColor.redColor())
            
            return view
        }
        return nil

    }
    
    
    
    //When you tap the info button in the annotation
//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let location = view.annotation as! Artwork
//        
//        //        for lauching in apple maps
//        //        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        //        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
//        
//        let request = MKDirectionsRequest()
//        request.source = MKMapItem.mapItemForCurrentLocation()
//        request.destination = location.mapItem()
//        request.transportType = MKDirectionsTransportType.Automobile
//        request.requestsAlternateRoutes = false
//        
//        
//        let directions = MKDirections(request: request)
//        directions.calculateDirectionsWithCompletionHandler({(response: MKDirectionsResponse?, error: NSError?) in
//            
//            if error != nil {
//                // Handle error
//            } else {
//                self.showRoute(response!)
//            }
//            
//        })
//        
//        
//    }
    
    //When find me button pressed
    func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        // If they pressed find me and don't have it activated or blocked
        if CLLocationManager.locationServicesEnabled() == false {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
            let alertController = UIAlertController(
                title: "Location Services Disable",
                message: "In order to use your current location to find places around you, please open the Settings -> Privacy -> Location Services and set it to On. Please also make sure this app is set to \"While Using\"",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }else if CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
            let alertController = UIAlertController(
                title: "Location Services Disabled for this App",
                message: "In order to use your current location to find places around you, please open the Settings -> Privacy -> Location Services and set this app to \"While Using\"",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        if (mode == MKUserTrackingMode.Follow){
            removeAnnotations()
            getCounty()
        }
        
    }
    
    
    //Draw directions
//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        
//        renderer.strokeColor = UIColor.blueColor()
//        renderer.lineWidth = 4.0
//        return renderer
//    }
    
    
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes {
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }
    
    func removeAnnotations(){
        if self.mapView.annotations.count != 0{
            for annotation in self.mapView.annotations {
                self.mapView.removeAnnotation(annotation)
            }
        }
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.searchBar.resignFirstResponder()
        self.mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
        
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //    Map Follows the user
    //    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
    //        let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
    //        let location = CLLocationCoordinate2D.init(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
    //        let region = MKCoordinateRegion.init(center: location, span: span)
    //        mapView.setRegion(region, animated: true)
    //    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        if (overlay.title! == "warning") {
            circleView.strokeColor = UIColor.yellowColor()
            circleView.fillColor = UIColor.yellowColor().colorWithAlphaComponent(0.3)
        }
        else {
            circleView.strokeColor = UIColor.redColor()
            circleView.fillColor = UIColor.redColor().colorWithAlphaComponent(0.3)
        }
        circleView.lineWidth = 1.0
        return circleView
    }
    
}


extension MapVC: UISearchBarDelegate {
    
    //Search bar search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.removeAnnotations()
        
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text!) { (placemarks, error) -> Void in
            if ((error == nil)) {
                let placemark = placemarks?.first
                let region = placemark?.region as! CLCircularRegion
                if let city = placemark!.addressDictionary!["City"] as? String {
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(placemark!.location!.coordinate, region.radius, region.radius)
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    self.getIncidents(city)
                }
                
            }
            else {
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }

        }
        
    }
}

