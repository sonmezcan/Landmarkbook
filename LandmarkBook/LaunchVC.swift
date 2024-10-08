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
            // Yeni yer oluşturuluyor
            let newPlace = Place(context: self.context)
            newPlace.name = textField.text!
            newPlace.date = Date()  // Şu anki tarihi ekle

            // Kategori kaydedin
            self.saveCategories()

            // Yeni yeri yükle
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
        // Hücreyi SwipeTableViewCell olarak kullanıyoruz
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") as? SwipeTableViewCell ?? SwipeTableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        
        // SwipeCellKit'in çalışması için delegate atıyoruz
        cell.delegate = self

        // İlgili Place nesnesini alıyoruz
        let place = places[indexPath.row]
        
        // Hücreye ana başlık olarak ismi ekliyoruz
        cell.textLabel?.text = place.name ?? "no places added yet"
        
//        // Fotoğrafı göster
//           if let imageData = places[indexPath.row].imageData {
//               cell.imageView?.image = UIImage(data: imageData) // Her şehrin fotoğrafını cell'e ata
//           } else {
//               cell.imageView?.image = nil // Eğer fotoğraf yoksa nil ata
//           }
        
        // Alt başlık olarak tarihi eklemek
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
        // Core Data'dan silme işlemi
        context.delete(places[indexPath.row])
        places.remove(at: indexPath.row)
        
        // Değişiklikleri Core Data'ya kaydet
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
                    print("Passing place: \(places[indexPath.row].name ?? "No name")") // Debug mesajı
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
