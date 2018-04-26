//
//  TypesViewController.swift
//  FinalProject
//
//  Created by Junhao Huang on 4/25/18.
//  Copyright © 2018 Junhao Huang. All rights reserved.
//

import UIKit

protocol TypesViewControllerDelegate: class {
    func typesController(_ controller: TypesViewController, didSelectTypes types: [String])
}

class TypesViewController: UITableViewController {
    
    private let possibleTypesDictionary = ["bakery": "Bakery", "bar": "Bar", "cafe": "Cafe", "grocery_or_supermarket": "Supermarket", "restaurant": "Restaurant"]
    private var sortedKeys: [String] {
        return possibleTypesDictionary.keys.sorted()
    }
    
    weak var delegate: TypesViewControllerDelegate?
    var selectedTypes: [String] = []
    
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        delegate?.typesController(self, didSelectTypes: selectedTypes)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleTypesDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        let key = sortedKeys[indexPath.row]
        let type = possibleTypesDictionary[key]
        cell.textLabel?.text = type
        cell.imageView?.image = UIImage(named: key)
        cell.accessoryType = selectedTypes.contains(key) ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = sortedKeys[indexPath.row]
        if selectedTypes.contains(key) {
            selectedTypes = selectedTypes.filter({$0 != key})
        } else {
            selectedTypes.append(key)
        }
        
        tableView.reloadData()
    }
}
