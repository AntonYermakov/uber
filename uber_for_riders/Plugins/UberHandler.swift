//
//  UberHandler.swift
//  uber_for_riders
//
//  Created by Yermakov Anton on 20.03.2018.
//  Copyright © 2018 Yermakov Anton. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class{
    func canCallUber(delegateCall: Bool)
    func driverRequestAccepted(requestAccepted: Bool, driverName: String)
    func updateDriverLocation(lat: Double, long: Double)
}

class UberHandler {
    
    static let sharedInstance = UberHandler()
    weak var delegate : UberController?
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    func requestUber(latitude: Double, longtitude: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: rider,
                                             Constants.LATITUDE: latitude,
                                             Constants.LONGTITUDE: longtitude]
        
        DBProvider.sharedInstance.requestRef.childByAutoId().setValue(data)
        
    }
    
    func observeMessageForRiders(){
        
        // Chiled added observing
        DBProvider.sharedInstance.requestRef.observe(.childAdded) { (snapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider_id = snapshot.key
                        self.delegate?.canCallUber(delegateCall: true)
                          print(self.rider_id)
                    }
                }
            }
        }
        
        // Child remove observing
        DBProvider.sharedInstance.requestRef.observe(.childRemoved) { (snapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                       self.delegate?.canCallUber(delegateCall: false)
                        print(self.rider_id)
                    }
                }
            }
        }
        
        DBProvider.sharedInstance.requstAcceptedRef.observe(.childAdded) { (snapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if self.driver == "" {
                        self.driver = name
                        self.delegate?.driverRequestAccepted(requestAccepted: true, driverName: name)
                    }
                }
            }
        }
        
        DBProvider.sharedInstance.requstAcceptedRef.observe(.childRemoved) { (snapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver{
                        self.driver = ""
                        self.delegate?.driverRequestAccepted(requestAccepted: false, driverName: name)
                    }
                }
            }
        }
        
        // Drivar change location
        
        DBProvider.sharedInstance.requstAcceptedRef.observe(.childChanged) { (snapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver{
                        if let lat = data[Constants.LATITUDE] as? Double, let long = data[Constants.LONGTITUDE] as? Double {
                              self.delegate?.updateDriverLocation(lat: lat, long: long)
                        }
                    }
                }
            }
        }
    }
    
    
    
    func cancelUber(){
        DBProvider.sharedInstance.requestRef.child(rider_id).removeValue()
    }
    
    func updateRiderLocation(lat: Double, long: Double){
        DBProvider.sharedInstance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGTITUDE: long])
    }
} // class








