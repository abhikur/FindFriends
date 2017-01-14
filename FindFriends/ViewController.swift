//
//  ViewController.swift
//  FindFriends
//
//  Created by Abhishek on 08/01/2017.
//  Copyright © 2017 Abhishet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
//AIzaSyD11MFaLoMOokxkED8yKY_IcEreBPpfh9E api key for google maps

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var gotLocation: Bool = false
    var region: CLCircularRegion!
    var userLocation: CLLocationCoordinate2D!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!)
        region = CLCircularRegion(center: userLocation, radius: 50, identifier: "")
        let geoCoder = CLGeocoder()
        let loc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        geoCoder.reverseGeocodeLocation(loc) { (placemark, error) in
            self.notifyUser(text: self.getUserLocationName(placemark: (placemark?.first)!))
            self.showUserInMap(location: locations.last!)
            self.addUserLocationAnnotation(location: locations.last!, locationName: self.getUserLocationName(placemark: (placemark?.first)!))
        }
    }
    
    func getUserLocationName(placemark: CLPlacemark) -> String {
        var locationName = ""
        if let area = placemark.subLocality, let city = placemark.locality, let state = placemark.administrativeArea, let country = placemark.country {
            locationName.append("\(area), \(city) \(state), \(country)")
        }
        return locationName
    }

    func showUserInMap(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func notifyUser(text: String) {
        let notification = UILocalNotification()
        notification.alertTitle = "location detected!"
        notification.alertBody = "You are at \(text)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = Date(timeIntervalSinceNow: 1)
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func addUserLocationAnnotation(location: CLLocation, locationName: String) {
        let userAnnotation = UserLocationAnnotation(title: "Location", locationName: locationName, coordinate: location.coordinate)
        mapView.addAnnotation(userAnnotation)
    }
    
}


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotation: MKPinAnnotationView?
        let anno = annotation as? UserLocationAnnotation
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        annotationView?.annotation = anno
        pinAnnotation = annotationView
        return pinAnnotation
    }
}
