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

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentLogin()
        
    }
    
    func presentLogin() {
        let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        
        Lock
            .classic()
            .withOptions {
                $0.oidcConformant = true
                $0.scope = "openid profile offline_access"
                $0.passwordManager.enabled = false
            }
            
            .withStyle {
                $0.title = "Welcome!"
                $0.primaryColor = UIColor(red: 0.1686, green: 0.6549, blue: 0.9373, alpha: 1.0)
            }
            
            .onAuth { credentials in
                credentialsManager.store(credentials: credentials)
                
                credentialsManager.credentials { (error, credentials) in
                    guard error == nil, let credentials = credentials else {
                        return print("Error: \(String(describing: error))")
                    }
                    
                    guard let accessToken = credentials.accessToken else { return }
                    
                    Auth0
                        .authentication()
                        .userInfo(withAccessToken: accessToken)
                        .start { result in
                            switch result {
                            case .success(let profile):
                                print("User Profile: \(profile)")
                            //self.profile = profile
                            case .failure(let error):
                                print(error)
                            }
                    }
                    
                }
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
   
}

