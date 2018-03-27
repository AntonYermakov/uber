//
//  SignInVc.swift
//  uber_for_riders
//
//  Created by Yermakov Anton on 19.03.2018.
//  Copyright © 2018 Yermakov Anton. All rights reserved.
//

import UIKit

class SignInVc: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let RIDERS_VC = "RidersVC"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func logInButton(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.sharedInstance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertErrorMessage(title: "Problem with authentification", message: message!)
                } else {
                    UberHandler.sharedInstance.rider = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                   self.performSegue(withIdentifier: self.RIDERS_VC, sender: nil)
                }
            })
        } else {
            alertErrorMessage(title: "Email and pasword are required", message: "Pleace enter email and password")
        }
    }
    
    private func alertErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        if emailTextField.text != nil && passwordTextField.text != nil {
            AuthProvider.sharedInstance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertErrorMessage(title: "Problem with creating a new user", message: message!)
                } else {
                    UberHandler.sharedInstance.rider = self.emailTextField.text!
                    self.performSegue(withIdentifier: self.RIDERS_VC, sender: nil)
                }
            })
        } else {
            alertErrorMessage(title: "Email and pasword are required", message: "Pleace enter email and password")
        }
    }
    
    


} // class
