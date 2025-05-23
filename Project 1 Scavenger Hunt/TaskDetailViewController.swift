//
//  TaskDetailViewController.swift
//  Project 1 Scavenger Hunt
//
//  Created by Courtney Mahugu on 4/14/25.
//
import UIKit
import PhotosUI
import MapKit
import CoreLocation

protocol TaskUpdateDelegate: AnyObject {
    func updateTask(_ task: Task, at index: Int)
}

class TaskDetailViewController: UIViewController, PHPickerViewControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var task: Task?
    var taskIndex: Int?
    weak var delegate: TaskUpdateDelegate?

    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Task Detail"
        setupUI()
        setupLocation()
        
        let defaultLocation = CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369) // DC
        let region = MKCoordinateRegion(center: defaultLocation,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)

        let annotation = MKPointAnnotation()
        annotation.coordinate = defaultLocation
        annotation.title = "Default Location"
        mapView.addAnnotation(annotation)

    }

    func setupUI() {
        guard let task = task else { return }
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        photoImageView.image = task.photo ?? UIImage(systemName: "photo")

        // Always show the map view and set a default location
        mapView.isHidden = false

        if let location = task.location {
            addMapPin(location)
        } else {
            // Force a default map region (e.g., DC or campus)
            let defaultLocation = CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369)
            let defaultRegion = MKCoordinateRegion(center: defaultLocation,
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(defaultRegion, animated: false)
        }
    }

    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    @IBAction func completeTaskTapped(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self,
                  let image = object as? UIImage else { return }

            // Get location & update task
            DispatchQueue.main.async {
                self.task?.photo = image
                self.task?.isCompleted = true
                self.task?.location = self.currentLocation

                self.photoImageView.image = image
                self.view.setNeedsLayout()       //Tell the view to update layout
                self.view.layoutIfNeeded()       //Force it to layout immediately

                if let location = self.currentLocation {
                    self.mapView.isHidden = false
                    self.addMapPin(location)
                }

                if let updatedTask = self.task, let index = self.taskIndex {
                    self.delegate?.updateTask(updatedTask, at: index)
                }
            }
        }
    }

    func addMapPin(_ coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Photo Location"
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: coordinate,
                                             span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)),
                          animated: true)
    }

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currentLocation = locations.first?.coordinate
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate

        // Only run this if we have a photo already but the location came in late
        if task?.isCompleted == true, task?.location == nil, let coord = currentLocation {
            task?.location = coord
            mapView.isHidden = false
            addMapPin(coord)

            if let updatedTask = task, let index = taskIndex {
                delegate?.updateTask(updatedTask, at: index)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
}
