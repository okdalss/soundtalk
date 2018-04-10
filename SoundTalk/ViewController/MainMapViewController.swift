//
//  MainMapViewController.swift
//  SoundTalk
//
//  Created by 신진욱 on 05/04/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import MapKit

class MainMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var worldMap: MKMapView!
    
    let locationManager = CLLocationManager()
    var pointAnnotation:UserPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        worldMap.delegate = self
        worldMap.mapType = MKMapType.standard
        worldMap.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: 35.689949, longitude: 139.697576)
//        let center = location
//        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
//        worldMap.setRegion(region, animated: true)
        
        pointAnnotation = UserPointAnnotation()
        pointAnnotation.pinCustomImageName = "Pokemon Pin"
        pointAnnotation.coordinate = location
        pointAnnotation.title = "POKéSTOP"
        pointAnnotation.subtitle = "Pick up some Poké Balls"
        
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        worldMap.addAnnotation(pinAnnotationView.annotation!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        else {
            let reuseIdentifier = "pin"
            var annotationView = worldMap.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            let userPointAnnotation = annotation as! UserPointAnnotation
            userPointAnnotation.pinCustomImageName = "iimmaaggee"
            if let imgName = userPointAnnotation.pinCustomImageName {
                annotationView?.image = UIImage(named: imgName)?.resizeWithWidth(width: 40)
            }
            
            return annotationView
        }
    }
}

class UserPointAnnotation: MKPointAnnotation {
    var pinCustomImageName: String!
}
