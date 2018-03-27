//
//  RidersVC.swift
//  uber_for_riders
//
//  Created by Yermakov Anton on 20.03.2018.
//  Copyright © 2018 Yermakov Anton. All rights reserved.
//

import UIKit
import MapKit

class RidersVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
   
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var callUberOutlet: UIButton!
    
    
    private var canCallUber = true
    private var riderCancelRequest = false
    private var driverLocation: CLLocationCoordinate2D?
    private var timer = Timer()
    

    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
        UberHandler.sharedInstance.observeMessageForRiders()
        UberHandler.sharedInstance.delegate = self
    }
    
    
    private func initializeLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            myMap.setRegion(region, animated: true)
            
            //     myMap.removeAnnotation(myMap.annotations as! MKAnnotation)
            
            if driverLocation != nil {
                if !canCallUber{
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Drivar location!"
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Drivers location"
            myMap.addAnnotation(annotation)
            
            
        }
    }


    @IBAction func callUber(_ sender: UIButton) {
        if userLocation != nil {
            if canCallUber {
                UberHandler.sharedInstance.requestUber(latitude: Double(userLocation!.latitude), longtitude: Double(userLocation!.longitude))
                
                timer = Timer(timeInterval: 10, target: self, selector: #selector(self.updateRidersLocation), userInfo: nil, repeats: true)
                
            } else {
                riderCancelRequest = true
                UberHandler.sharedInstance.cancelUber()
                timer.invalidate()
            }
        }
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func canCallUber(delegateCall: Bool) {
        if delegateCall{
            callUberOutlet.setTitle("Cancel Uber", for: .normal)
            canCallUber = false
        } else {
            callUberOutlet.setTitle("Call uber", for: .normal)
            canCallUber = true
        }
    }
    
    
    
    func driverRequestAccepted(requestAccepted: Bool, driverName: String) {
        if !riderCancelRequest{
            if requestAccepted{
                alert(title: "Uber accepted", message: "\(driverName) have accepted your order")
            } else {
                UberHandler.sharedInstance.cancelUber()
                timer.invalidate()
                alert(title: "Uber canceled", message: "Driver cancel your order")
            }
        }
        riderCancelRequest = false
    }
    
    private func alert(title: String, message: String){
        
        let aler = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        aler.addAction(action)

        present(aler, animated: true, completion: nil)
    }
    
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        if AuthProvider.sharedInstance.signOut(){
            
            if !canCallUber{
                UberHandler.sharedInstance.cancelUber()
                timer.invalidate()
            }
            
            dismiss(animated: true, completion: nil)
        } else {
            // problem with loging out
        }
    }
    
    @objc func updateRidersLocation(){
        UberHandler.sharedInstance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
}
