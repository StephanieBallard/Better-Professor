//
//  ProjectCollectionViewController.swift
//  BetterProfessor
//
//  Created by Hunter Oppel on 6/24/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class ProjectCollectionViewController: UICollectionViewController {

    private let reuseIdentifier = "ProjectCell"

    var student: Student?
    private var projects = [Project]()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchProjects()
    }

    private func updateViews() {
        collectionView.reloadData()
    }

    private func fetchProjects() {
        guard let student = student else { return }

        BackendController.shared.fetchAllProjects { projects, error in
            if let error = error {
                NSLog("Failed to fetch projects with error: \(error)")
                return
            }

            guard let projects = projects else {
                NSLog("No projects found")
                return
            }

            // We only want to display projects associated with the particular student so I filter it here
            for project in projects {
                if project.studentName == student.name {
                    self.projects.append(project)
                }
            }

            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewProjectSegue" {
            guard let detailVC = segue.destination as? ProjectDetailViewController,
                let cell = sender as? ProjectCollectionViewCell,
                let indexPath = collectionView.indexPath(for: cell) else { return }

            detailVC.project = self.projects[indexPath.row]
            detailVC.student = self.student
            detailVC.delegate = self
        } else if segue.identifier == "AddProjectSegue" {
            guard let detailVC = segue.destination as? ProjectDetailViewController else { return }

            detailVC.student = self.student
            detailVC.delegate = self
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return projects.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ProjectCollectionViewCell else { fatalError() }

        cell.project = projects[indexPath.row]
    
        return cell
    }
}

extension ProjectCollectionViewController: ProjectDetailDelegate {
    func didCreateProject() {
        projects = []
        self.fetchProjects()
    }
}
