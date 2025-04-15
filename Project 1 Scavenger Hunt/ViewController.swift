//
//  ViewController.swift
//  Project 1 Scavenger Hunt
//
//  Created by Courtney Mahugu on 3/9/25.
//

import UIKit

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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title

        // ✅ Show checkmark for completed task
        cell.accessoryType = task.isCompleted ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTaskDetail", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTaskDetail",
           let destination = segue.destination as? TaskDetailViewController,
           let indexPath = sender as? IndexPath {
            destination.task = tasks[indexPath.row]
            destination.taskIndex = indexPath.row
            destination.delegate = self
        }
    }
}

// MARK: - Update Task from Detail

extension ViewController: TaskUpdateDelegate {
    func updateTask(_ task: Task, at index: Int) {
        tasks[index] = task
        tableView.reloadData()
    }
}


