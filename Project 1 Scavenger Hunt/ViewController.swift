//
//  ViewController.swift
//  Project 1 Scavenger Hunt
//
//  Created by Courtney Mahugu on 3/9/25.
//

import UIKit

struct Task {
    var title: String
    var description: String
    var isCompleted: Bool = false
    var photo: UIImage?  // This will hold the attached photo for the task
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tasks: [Task] = [
            Task(title: "Find a Red Ball", description: "Find a red ball in the park"),
            Task(title: "Take a Selfie", description: "Take a selfie with a statue"),
            Task(title: "Capture a Landmark", description: "Snap a picture of the famous bridge")
        ]

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
        }
    
    // TableView DataSource Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tasks.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
            let task = tasks[indexPath.row]
            cell.textLabel?.text = task.title
            return cell
        }

        // TableView Delegate Method (optional)
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedTask = tasks[indexPath.row]
            // Perform segue to task detail screen
            performSegue(withIdentifier: "goToTaskDetail", sender: selectedTask)
        }
    
}

