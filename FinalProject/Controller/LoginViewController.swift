//
//  ViewController.swift
//  FinalProject
//
//  Created by Junhao Huang on 4/14/18.
//  Copyright © 2018 Junhao Huang. All rights reserved.
//

import UIKit
import Auth0
import Lock

let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

class LoginViewController: UIViewController {
    
    var profileName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        presentLogin()
        
    }
    
    func presentLogin() {
        Lock
            .classic()
            .withOptions {
                $0.oidcConformant = true
                $0.scope = "openid profile offline_access"
                $0.passwordManager.enabled = false
            }
            
            .withStyle {
                $0.title = ""
                $0.primaryColor = UIColor(red: 0.1686, green: 0.6549, blue: 0.9373, alpha: 1.0)
                $0.logo = LazyImage(name: "icons8-login-as-user-100.png")
            }
            
            .onAuth { credentials in
                credentialsManager.store(credentials: credentials)
                print("Obtained credentials: \(credentials)")
            }
            
            .onError {
                print("Failed with \($0)")
            }
            
            .onCancel {
                print("User cancelled")
            }
            .present(from: self)
    }
    
    @IBAction func weather(_ sender: UIButton) {
        performSegue(withIdentifier: "toWeather", sender: self)
    }
    
    @IBAction func chatRoom(_ sender: UIButton) {
        performSegue(withIdentifier: "toChatRoom", sender: self)
    }
    
    @IBAction func image(_ sender: UIButton) {
        performSegue(withIdentifier: "toImageML", sender: self)
    }
    
    @IBAction func AR(_ sender: UIButton) {
        performSegue(withIdentifier: "toAR", sender: self)
    }
    
    @IBAction func restaurant(_ sender: Any) {
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        presentLogin()
    }
    
}

