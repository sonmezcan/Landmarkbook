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
            // Create a new place
            let newPlace = Place(context: self.context)
            newPlace.name = textField.text!
            newPlace.date = Date()  // Add the current date

            
            self.savePlaces()

            
            self.loadPlaces()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Place"
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
        // Using the cell as a SwipeTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") as? SwipeTableViewCell ?? SwipeTableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        
        // Assigning delegate for SwipeCellKit functionality
        cell.delegate = self

        // Retrieve the corresponding Place object
        let place = places[indexPath.row]
        
        // Set the name as the main title of the cell
        cell.textLabel?.text = place.name ?? "no places added yet"
        
//        // Show picture
//           if let imageData = places[indexPath.row].imageData {
//               cell.imageView?.image = UIImage(data: imageData) // Assign each city's photo to the cell
//           } else {
//               cell.imageView?.image = nil // Assign nil if there is no image
//           }
        
        // Set the date as a subtitle
        if let date = place.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        } else {
            cell.detailTextLabel?.text = "No date available"
        }
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toDetailsVC", sender: self)
        
    }
    
    // MARK: - Data manipulation
    func savePlaces () {
        
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
        // Deleting from Core Data
        context.delete(places[indexPath.row])
        places.remove(at: indexPath.row)
        
        // Save changes to Core Data
        do {
            try context.save()
        } catch {
            print("Error saving context after delete: \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            if let destinationVC = segue.destination as? DetailsVC {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.place = places[indexPath.row]
                    print("Passing place: \(places[indexPath.row].name ?? "No name")") // Debug message
                }
            }
        }
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
