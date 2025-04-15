//
//  Task.swift
//  Project 1 Scavenger Hunt
//
//  Created by Courtney Mahugu on 4/14/25.
//

import UIKit
import CoreLocation

struct Task {
    var title: String
    var description: String
    var isCompleted: Bool = false
    var photo: UIImage? = nil
    var location: CLLocationCoordinate2D? = nil
}
