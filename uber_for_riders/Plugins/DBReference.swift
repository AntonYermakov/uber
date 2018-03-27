//
//  DBReference.swift
//  uber_for_riders
//
//  Created by Yermakov Anton on 20.03.2018.
//  Copyright © 2018 Yermakov Anton. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    static let sharedInstance = DBProvider()
    
    var dbRef: DatabaseReference{
        return Database.database().reference()
    }
    
    var ridersRef: DatabaseReference{
        return dbRef.child(Constants.RIDERS)
    }
    
    var requestRef: DatabaseReference{
        return dbRef.child(Constants.UBER_REQUEST)
    }
    
    var requstAcceptedRef: DatabaseReference{
        return dbRef.child(Constants.UBER_ACCEPTED)
    }

    
    func saveUser(withID: String, email: String, password: String){
        
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isRider: true]
        
        ridersRef.child(withID).child(Constants.DATA).setValue(data)
    }
}

