//
//  AuthProvider.swift
//  uber_for_riders
//
//  Created by Yermakov Anton on 20.03.2018.
//  Copyright © 2018 Yermakov Anton. All rights reserved.
//

import Foundation
import Firebase

typealias LoginHandler = (_ msg: String?) -> Void

struct LoginErrorHandler{
    
    static let INVALID_EMAIL = "Invalid Email address, Pleace provide a real email"
    static let WRONG_PASSWORD = "Wrong password, place enter the correct password"
    static let PROBLEM_CONNECTING = "Problem connecting to database"
    static let USER_NOT_FOUND = "User not found, place register"
    static let EMAIL_ALREADY_IN_USE = "Email already in use, place use anothe email"
    static let WEAK_PASSWORD = "Place use at least 6 characters"
}

class AuthProvider {
    
    static let sharedInstance = AuthProvider()
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?){
        
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil)
            }
            
        }
    }
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            } else {
                if user?.uid != nil {
                    
                    DBProvider.sharedInstance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        }
    }
    
    func signOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            } catch {
                return false
            }
        }
        return true
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?){
        
        if let errCode = AuthErrorCode(rawValue: err.code) {
            
            switch errCode {
            case .wrongPassword:
                loginHandler?(LoginErrorHandler.WRONG_PASSWORD)
                break
            case .invalidEmail:
                loginHandler?(LoginErrorHandler.INVALID_EMAIL)
                break
            case .userNotFound:
                loginHandler?(LoginErrorHandler.USER_NOT_FOUND)
                break
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorHandler.EMAIL_ALREADY_IN_USE)
                break
            case .weakPassword:
                loginHandler?(LoginErrorHandler.WEAK_PASSWORD)
                break
            default:
                loginHandler?(LoginErrorHandler.PROBLEM_CONNECTING)
                break
            }
        }
    }
    
} // class
