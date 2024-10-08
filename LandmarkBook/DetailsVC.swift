import UIKit
import MapKit
import CoreData

class DetailsVC: UIViewController {
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeLocation: MKMapView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var place: Place? // Place nesnesini tut
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
                    placeLocation.addAnnotation(annotation) // Haritaya ekle
                    
                    // Harita merkezini ayarla
                    placeLocation.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
            
            
            if let date = place.date { // date değişkenini place'den al
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                dateLabel.text = dateFormatter.string(from: date)
            } else {
                dateLabel.text = "No date available"
            }

            // Daha önce kaydedilmiş fotoğrafı göster
            if let imageData = place.imageData {
                placeImage.image = UIImage(data: imageData)
            }
        }
        
        // Tap Gesture Ekle
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        placeImage.isUserInteractionEnabled = true
        placeImage.addGestureRecognizer(tapGestureImage)
        
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
        // Seçilen konumu kaydet
        saveLocation(coordinate: coordinate)
        
        // Harita üzerinde bir pin (işaretçi) göster
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Seçilen Konum"
        placeLocation.addAnnotation(annotation)
        
        if let place = place {
                // Daha önce kaydedilmiş konumu göster
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
            place.lat = coordinate.latitude // Latitude için Core Data'da bir özellik eklemeyi unutma
            place.lon = coordinate.longitude // Longitude için de aynı şekilde
            do {
                try context.save()
                print("Location saved successfully!") // Başarılı kaydetme mesajı
            } catch {
                print("Error saving location: \(error.localizedDescription)") // Hata mesajı
            }
        } else {
            print("Place object is nil") // Hata mesajı
        }
    }
    
    @objc func imageTapped() {
        selectPhoto() // Fotoğraf seçme fonksiyonunu çağır
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
            placeImage.image = image // Seçilen resmi UIImageView'a ata
            print("Image selected successfully") // Debug mesajı

            // place nesnesinin varlığını kontrol et
            if place != nil {
                savePhoto(image: image) // Fotoğrafı kaydet
            } else {
                print("Place object is nil") // Hata mesajı
            }
        } else {
            print("Failed to select image") // Hata mesajı
        }
        dismiss(animated: true)
    }
    func savePhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("Error converting image to data")
            return
        }

        if let place = place {
            place.imageData = imageData // Fotoğrafı Place nesnesine ata
            do {
                try context.save() // Core Data'da kaydet
                print("Photo saved successfully!") // Başarılı kaydetme mesajı
            } catch {
                print("Error saving photo: \(error.localizedDescription)") // Hata mesajı
            }
        } else {
            print("Place object is nil") // Hata mesajı
        }
    }
   
}
