//
//  StudentTableViewController.swift
//  BetterProfessor
//
//  Created by Hunter Oppel on 6/23/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import CoreData

class StudentTableViewController: UIViewController {

   
    // MARK: - Properties
    var studentFetchedResultsController: NSFetchedResultsController<Student>!
    private func setUpFetchResultController(with predicate: NSPredicate = NSPredicate(value: true)) {
        self.studentFetchedResultsController = nil
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        fetchRequest.predicate = predicate
        let context = CoreDataStack.shared.mainContext
        //        context.reset()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            print("Error performing initial fetch inside fetchedResultsController: \(error)")
        }
        self.studentFetchedResultsController = frc
    }

    // MARK: - Outlets

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar(searchBar, textDidChange: "")
        setUpFetchResultController()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        studentFetchedResultsController.delegate = self
        fetchStudents()
        //        fetchStudents()
    }
    @IBAction func signOutTapped(_ sender: Any) {
        BackendController.shared.signOut()
    }

    private func fetchStudents() {
        BackendController.shared.syncStudent { error in
            DispatchQueue.main.async {
                if let error = error {
                    NSLog("Error trying to fetch student: \(error)")
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func fetchStudents1() {
        BackendController.shared.forceLoadInstructorStudents { result, error in
            if let error = error {
                NSLog("ERROR: \(error)")
                return
            }

            if result {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func createStudent() {
        let alert = UIAlertController(title: "Create Student", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default) { (action: UIAlertAction ) in
            guard let name = alert.textFields?[0].text,
                let email = alert.textFields?[1].text,
                let subject = alert.textFields?[2].text else { return }

            BackendController.shared.createStudentForInstructor(name: name, email: email, subject: subject) { result, error in
                if let error = error {
                    NSLog("ERROR: \(error)")
                    return
                }

                if result {
                    DispatchQueue.main.async {
                        self.fetchStudents()
                        NSLog("Created Student ⭐️")
                    }
                }
            }
        }

        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Student Name"

        }
        alert.addTextField { (emailTextField) in
            emailTextField.placeholder = "Student Email"
        }
        alert.addTextField { (subjectTextField) in
            subjectTextField.placeholder = "Student Subject"
        }

        alert.addAction(cancelAction)
        alert.addAction(createAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func createStudent(_ sender: Any) {
        self.createStudent()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case "ProjectCollectionSegue":
            guard let collectionVC = segue.destination as? ProjectCollectionViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let student = studentFetchedResultsController.object(at: indexPath)
            collectionVC.student = student
        case "addReminderSegue":
           guard let collectionVC = segue.destination as? ReminderDetailViewController,
                           let indexPath = tableView.indexPathForSelectedRow else { return }
                       let student = studentFetchedResultsController.object(at: indexPath)
                       collectionVC.student = student
            
        default:
            break
        }
    }
}

extension StudentTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as? StudentTableViewCell else { return UITableViewCell() }

        cell.student = studentFetchedResultsController.object(at: indexPath)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
                          // Delete the row from the data source
                          
                          // TODO: expected to decode Int but found dictionary instead.
                           let student = studentFetchedResultsController.object(at: indexPath)
            BackendController.shared.deleteEntryFromServe(student: student) { result  in
                                        guard let _ = try? result.get() else {
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            CoreDataStack.shared.mainContext.delete(student)
                                        
                                        do {
                                            try CoreDataStack.shared.mainContext.save()
                                        } catch {
                                            CoreDataStack.shared.mainContext.reset()
                                            NSLog("Error saving object : \(error)")
                                        }
                                        }
                                    }
                      }
    }
    
}

extension StudentTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
extension StudentTableViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
            setUpFetchResultController(with: predicate)
        } else {
            setUpFetchResultController()
        }
        tableView.reloadData()
    }
}
