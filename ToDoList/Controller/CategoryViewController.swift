//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by Christopher Vera on 1/10/19.
//  Copyright © 2019 FSCApps. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework
import Floaty

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    let floaty = Floaty()
    let buttonPress = UITapGestureRecognizer()

    var categoryArray: Results<Category>?
    let searchController = UISearchController(searchResultsController: nil)
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        floaty.sticky = true
        floaty.hasShadow = true
        buttonPress.addTarget(self, action: #selector(addButtonPressed(_:)))
        buttonPress.delaysTouchesEnded = false
        floaty.addGestureRecognizer(buttonPress)
        floaty.buttonColor = UIColor(hexString: "005493") ?? FlatBlue()
        floaty.plusColor = FlatWhite()
       
//         Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.placeholder = "Search Categories"
        searchController.searchBar.tintColor = FlatWhite()
        searchController.searchBar.barTintColor = FlatWhite()
        navigationItem.searchController =  searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .singleLine
        
        
        
    }


    override func viewWillAppear(_ animated: Bool) {
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = FlatWhite()
        navigationController?.view.addSubview(floaty)
        floaty.isHidden = false
        loadCategories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        floaty.isHidden = true
    }
    
    //MARK: Action to add a new item
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: "Name it whatever you want", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addCategoryAction = UIAlertAction(title: "Add it!", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.cellBackgroundColor = UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
            
        }
        
        alert.addAction(addCategoryAction)
        alert.addAction(cancelAction)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories added yet"

        cell.textLabel?.textColor = UIColor.flatBlack
        cell.detailTextLabel?.text = "\(categoryArray?[indexPath.row].items.count ?? 0) Items"
        
        return cell
    }
    
    //MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    
    //MARK: Data Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categoryArray = realm.objects(Category.self).sorted(byKeyPath: "name")
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {

            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            categoryArray = categoryArray?.filter("name CONTAINS[cd] %@", searchController.searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        } else {
            categoryArray = realm.objects(Category.self).sorted(byKeyPath: "name")
        }
        tableView.reloadData()
        
    }
    
}

extension CategoryViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}

