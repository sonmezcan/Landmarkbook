import UIKit
import MapKit
import CoreData

class DetailsVC: UIViewController {
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeLocation: MKMapView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var place: Place? // Hold the Place object
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Selected place: \(place?.name ?? "No place selected")")
        print("Latitude: \(place?.lat ?? 0.0), Longitude: \(place?.lon ?? 0.0)")
        if let place = place {
            placeLabel.text = place.name
            
            let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
            placeLocation.removeAnnotations(placeLocation.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = place.name
            placeLocation.addAnnotation(annotation) // Add annotation to map
            
            // Set map center
            placeLocation.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
            
            if let date = place.date { // Retrieve date from the Place object
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                dateLabel.text = dateFormatter.string(from: date)
            } else {
                dateLabel.text = "No date available"
            }

            // Display previously saved photo
            if let imageData = place.imageData {
                placeImage.image = UIImage(data: imageData)
            }
        }
        
        // Add Tap Gesture for Image
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        placeImage.isUserInteractionEnabled = true
        placeImage.addGestureRecognizer(tapGestureImage)
        
        // Add Tap Gesture for Map
        let tapGestureMap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        placeLocation.addGestureRecognizer(tapGestureMap)
    }

    @IBAction func zoomInButton(_ sender: UIButton) {
        zoomIn()
    }
    
    @IBAction func zoomOutButton(_ sender: UIButton) {
        zoomOut()
    }
    
    func zoomIn() {
        let currentRegion = placeLocation.region
        let zoomedRegion = MKCoordinateRegion(center: currentRegion.center,
                                              span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta / 2,
                                                                     longitudeDelta: currentRegion.span.longitudeDelta / 2))
        placeLocation.setRegion(zoomedRegion, animated: true)
    }

    func zoomOut() {
        let currentRegion = placeLocation.region
        let zoomedRegion = MKCoordinateRegion(center: currentRegion.center,
                                              span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta * 2,
                                                                     longitudeDelta: currentRegion.span.longitudeDelta * 2))
        placeLocation.setRegion(zoomedRegion, animated: true)
    }

    @objc func mapTapped(gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: placeLocation)
        let coordinate = placeLocation.convert(locationInView, toCoordinateFrom: placeLocation)
        
        placeLocation.removeAnnotations(placeLocation.annotations)
        
        // Save the selected location
        saveLocation(coordinate: coordinate)
        
        // Display a pin on the map for the selected location
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Selected Location"
        placeLocation.addAnnotation(annotation)
        
        if let place = place {
            // Display previously saved location
            let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = place.name
            placeLocation.addAnnotation(annotation)
            placeLocation.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        }
    }
    
    func saveLocation(coordinate: CLLocationCoordinate2D) {
        if let place = place {
            place.lat = coordinate.latitude // Don't forget to add a latitude property to Core Data
            place.lon = coordinate.longitude // Similarly, add a longitude property
            do {
                try context.save()
                print("Location saved successfully!") // Successful save message
            } catch {
                print("Error saving location: \(error.localizedDescription)") // Error message
            }
        } else {
            print("Place object is nil") // Error message
        }
    }
    
    @objc func imageTapped() {
        selectPhoto() // Call the photo selection function
    }
}

// MARK: - Picture
extension DetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            placeImage.image = image // Set selected image to UIImageView
            print("Image selected successfully") // Debug message

            // Check if the Place object exists
            if place != nil {
                savePhoto(image: image) // Save the photo
            } else {
                print("Place object is nil") // Error message
            }
        } else {
            print("Failed to select image") // Error message
        }
        dismiss(animated: true)
    }
    
    func savePhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("Error converting image to data")
            return
        }

        if let place = place {
            place.imageData = imageData // Assign photo to the Place object
            do {
                try context.save() // Save to Core Data
                print("Photo saved successfully!") // Successful save message
            } catch {
                print("Error saving photo: \(error.localizedDescription)") // Error message
            }
        } else {
            print("Place object is nil") // Error message
        }
    }
   
}
