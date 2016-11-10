//
//  ViewController.swift
//  Memorable Places
//
//  Created by joey frenette on 2016-11-09.
//  Copyright © 2016 joey frenette. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var map: MKMapView!
    
    var mgr = CLLocationManager()
    
    let lat: CLLocationDegrees = 38.8976763
    let long: CLLocationDegrees = -77.0387185
    let delta: CLLocationDegrees = 0.003
    let deg: CLLocationDegrees = 0.005
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        if activePlace == -1 {
            //get user's current location if no current location present (ie: when user hits '+' button)
            mgr.delegate = self
            mgr.desiredAccuracy = kCLLocationAccuracyBest
            mgr.requestAlwaysAuthorization()
            mgr.startUpdatingLocation()
            
        } else {
            //
            if activePlace < places.count {
                //unwrapping 'place' values
                if let name = places[activePlace]["name"] {
                    if let ltd = places[activePlace]["lat"] {
                        if let lon = places[activePlace]["lon"] {
                            if let tempLat = Double(ltd) {
                                if let tempLon = Double(lon) {
                                    
                                    //showing place on the map view
                                    let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: deg)
                                    let coord = CLLocationCoordinate2D(latitude: tempLat, longitude: tempLon)
                                    let region = MKCoordinateRegion(center: coord, span: span)
                                    map.setRegion(region, animated: true)
                                    
                                    //dropping pin on the saved place
                                    let currentAnnotation = MKPointAnnotation()
                                    currentAnnotation.coordinate = coord
                                    currentAnnotation.title = name
                                    map.addAnnotation(currentAnnotation)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //add long press gesture recognizer
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longpressed(gestureRecognizer:)))
        map.addGestureRecognizer(longpress)
    }
    
    //set the region to be user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    
    //get co-ordinates of touched point, get the geocode location, and save it as a new entry in 'places' and drop a pin in the touched location
    func longpressed(gestureRecognizer: UILongPressGestureRecognizer) {
        
        //once gesture begins
        if gestureRecognizer.state == UIGestureRecognizerState.began {
        
            //Get the co-ordinates of the touched point on the map
            let touch = gestureRecognizer.location(in: map)
            let touchCoord = map.convert(touch, toCoordinateFrom: map)
            
            //Convert co-ordinates to CLLocation
            let location = CLLocation(latitude: touchCoord.latitude, longitude: touchCoord.longitude)
            
            var title = ""
            //Get address information about the location
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
                (placemarks, error) in
                
                if error != nil {
                    print(error)
                } else {
                    if let placemark = placemarks?[0] {
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + " "
                        }
                        
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare! + " "
                        }
                    }
                }
                
                //if no address in the title, then just make the title when the pin was added
                if title == "" {
                    title = "Added \(NSDate())"
                }
                
                //Add new place entry to the places array
                var newPlace = [String:String]()
                newPlace["name"] = title
                newPlace["lat"] = String(touchCoord.latitude)
                newPlace["lon"] = String(touchCoord.longitude)
                
                places.append(newPlace)
                
                //update places model
                UserDefaults.standard.set(places, forKey: "places")
                
                //pin that will be dropped with the address
                let newPin = MKPointAnnotation()
                newPin.coordinate = touchCoord
                newPin.title = title
                self.map.addAnnotation(newPin)
            })
        }
    }
    
}

