//
//  ViewController.swift
//  ToDoList
//
//  Created by Christopher Vera on 1/4/19.
//  Copyright © 2019 FSCApps. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import Floaty

class ToDoListViewController: SwipeTableViewController {

    var toDoItems: Results<Item>?
    let realm = try! Realm()
    let floaty = Floaty()
    let buttonPress = UITapGestureRecognizer()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ListModel.plist")
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        floaty.sticky = true
        floaty.hasShadow = true
        buttonPress.addTarget(self, action: #selector(addButtonPressed(_:)))
        floaty.addGestureRecognizer(buttonPress)
        floaty.buttonColor = UIColor(hexString: "005493") ?? FlatBlue()
        floaty.plusColor = FlatWhite()
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .singleLine
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
        
        navigationController?.view.addSubview(floaty)
        floaty.isHidden = false

       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        floaty.isHidden = true
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }

    
   
    //MARK: Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.imageView?.image = UIImage(named: "circle-outline")
            cell.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)

            cell.imageView?.image = item.done ? UIImage(named: "full-circle") : UIImage(named: "circle-outline")
            cell.textLabel?.textColor = item.done ? FlatGray() : FlatBlack()
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }

    //MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: Add Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new To-Do Item", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen when we hit add
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newToDoItem = Item()
                        newToDoItem.title = textField.text!
                        newToDoItem.dateCreated = Date()
                        currentCategory.items.append(newToDoItem)
                    }
                }
                catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: Model Manipulation Method
   
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.toDoItems?[indexPath.row] {
            
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    
   
}

