//
//  ChatViewController.swift
//  FinalProject
//
//  Created by Junhao Huang on 4/18/18.
//  Copyright © 2018 Junhao Huang. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var messageArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        messageTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        configureTableView()
        monitorMessages()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! MessageTableViewCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.username.text = messageArray[indexPath.row].sender
        cell.userImage.image = UIImage(named: "sunny.png")
        
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
            self.heightConstraint.constant = 327
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
        
        let messageDict = ["Sender": "jh@junhaohuang.com",
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
