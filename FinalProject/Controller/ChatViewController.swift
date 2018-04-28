//
//  ChatViewController.swift
//  FinalProject
//
//  Created by Junhao Huang on 4/18/18.
//  Copyright © 2018 Junhao Huang. All rights reserved.
//

import UIKit
import Firebase
import Lock
import Auth0

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var profileName = ""
    var messageArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfile()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        messageTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        configureTableView()
        monitorMessages()
        
    }
    
    func getProfile() {
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
                        self.profileName = profile.name ?? "Junhao Huang"
                    case .failure(let error):
                        print(error)
                    }
                }
        
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! MessageTableViewCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.username.text = messageArray[indexPath.row].sender
        cell.userImage.image = UIImage(named: "icons8-male-user-48.png")
        
        if cell.username.text == "jh@junhaohuang.com" {
            cell.messageBackground.backgroundColor = UIColor(red:0.71, green:0.92, blue:0.91, alpha:1.0)
            
        } else {
            cell.userImage.image = UIImage(named: "icons8-circled-user-female-skin-type-1-2-48.png")
            cell.messageBackground.backgroundColor = UIColor(red:0.86, green:0.79, blue:0.89, alpha:1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 368 // 69 + 333 - 34
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 69
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func send(_ sender: UIButton) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        
        let messageDB = Database.database().reference().child("Messages")
        
        let messageDict = ["Sender": profileName,
                           "MessageBody": messageTextField.text!]
        
        messageDB.childByAutoId().setValue(messageDict) {
            (error, reference) in
            
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                print("Messages saved!")
            }
            
            self.messageTextField.isEnabled = true
            self.messageTextField.text = ""
        }
        
    }
    
    func monitorMessages() {
        let messageDB = Database.database().reference().child("Messages")

        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!

            let newMessage = Message()
            newMessage.messageBody = text
            newMessage.sender = sender
            self.messageArray.append(newMessage)

            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    

}
