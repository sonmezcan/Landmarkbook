//
//  LaunchVC.swift
//  LandmarkBook
//
//  Created by can on 7.10.2024.
//

import UIKit
import CoreData
import SwipeCellKit

class LaunchVC: SwipeTableVC {

    
    var places = [Place]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Place>  = Place.fetchRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        tableView.rowHeight = 100
    }

    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Place", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Place", style: .default) { action in
            //what will happen once the add button is pressed
            
           
            let newPlace = Place(context: self.context)
            newPlace.name = textField.text!
            
            
            self.places.append(newPlace)
            
            self.saveCategories()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
    
    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = places[indexPath.row].name ?? "no places added yet"

        return cell
    }
    
    // MARK: - Data manipulation
    func saveCategories () {
        
        do{
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    func loadPlaces(with request: NSFetchRequest<Place> = Place.fetchRequest(), _ predicate: NSPredicate? = nil) {
        if let additionalPredicate = predicate {
            request.predicate = additionalPredicate
        }
        
        do {
            places = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(places[indexPath.row])
        places.remove(at: indexPath.row)
    }

   
}

// MARK: - Searchbar Methods

extension LaunchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text ?? "give a text")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadPlaces(with: request,predicate)
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadPlaces()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
}
