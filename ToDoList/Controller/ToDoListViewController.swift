//
//  ViewController.swift
//  ToDoList
//
//  Created by Christopher Vera on 1/4/19.
//  Copyright © 2019 FSCApps. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [ListModel]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ListModel.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        loadItems()
        
    }
    
    //MARK: Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListItem", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }

    //MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: Add Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new To-Do Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen when we hit add
            
            let newItem = ListModel()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: Model Manipulation Method
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([ListModel].self, from: data)
            } catch {
                print("Error decoding: \(error)")
            }
        }
    }
    
    
    
}
