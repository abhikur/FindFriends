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
            if let area = placemark?.first?.subLocality, let city = placemark?.first?.locality, let state = placemark?.first?.administrativeArea, let country = placemark?.first?.country {
                self.notifyUser(text: "\(area), \(city) \(state), \(country)")
            }
            self.showUserInMap(location: locations.last!)
        }
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
    
}

