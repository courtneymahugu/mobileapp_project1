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
    }

    func setupUI() {
        guard let task = task else { return }
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        photoImageView.image = task.photo ?? UIImage(systemName: "photo")
        mapView.isHidden = task.location == nil

        if let location = task.location {
            addMapPin(location)
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
}
