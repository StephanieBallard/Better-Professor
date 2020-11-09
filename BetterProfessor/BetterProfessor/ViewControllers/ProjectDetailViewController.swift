//
//  ProjectDetailViewController.swift
//  BetterProfessor
//
//  Created by Hunter Oppel on 6/25/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import MessageUI
protocol ProjectDetailDelegate {
    func didCreateProject() -> Void
}

class ProjectDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var sendEmailButton: UIButton!
    @IBOutlet var projectNameTextField: UITextField!
    @IBOutlet var saveProjectButton: UIButton!
    @IBOutlet var projectTypeTextField: UITextField!
    @IBOutlet var completedButton: UIButton!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var projectNameLabel: UILabel!
     @IBOutlet var projectTypeLabel: UILabel!
     @IBOutlet var completedLabel: UILabel!
     @IBOutlet var dueDateLabel: UILabel!
     @IBOutlet var notesLabel: UILabel!
     @IBOutlet var sendEmailLabel: UILabel!
    
    var project: Project?
    var student: Student?
    var delegate: ProjectDetailDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if project != nil {
            self.updateViews()
        }
        updateTap()
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.blue.cgColor
        saveProjectButton.layer.cornerRadius = 12
        
        strokeAttributes()
    }
    
    func strokeAttributes() {
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .strokeWidth: -2.8,
            ]

        projectNameLabel.attributedText = NSAttributedString(string: "Project Name:", attributes: strokeTextAttributes)
        projectTypeLabel.attributedText = NSAttributedString(string: "Project Type:", attributes: strokeTextAttributes)
        completedLabel.attributedText = NSAttributedString(string: "Completed?:", attributes: strokeTextAttributes)
        dueDateLabel.attributedText = NSAttributedString(string: "Due Date:", attributes: strokeTextAttributes)
        notesLabel.attributedText = NSAttributedString(string: "Notes Label", attributes: strokeTextAttributes)
        sendEmailLabel.attributedText = NSAttributedString(string: "Send an Email:", attributes: strokeTextAttributes)
    }
    
    func updateTap() {
             let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
             view.addGestureRecognizer(tapGesture)
         }
         @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
             print("tap")
             view.endEditing(true)
          switch(tapGesture.state) {
             case .ended:
                 print("tapped again")
             default:
                 print("Handled other states: \(tapGesture.state)")
             }
         }

    private func updateViews() {
        guard let project = project else { return }

        projectNameTextField.text = project.projectName
        projectTypeTextField.text = project.projectType
        dueDatePicker.date = project.dueDate
        notesTextView.text = project.description

        switch project.completed {
        case true:
            completedButton.isSelected = true
        case false:
            completedButton.isSelected = false
        }
    }

    @IBAction func toggleCompleteState(_ sender: Any) {
        completedButton.isSelected.toggle()
    }

    @IBAction func toggleEmailState(_ sender: Any) {
        sendEmailButton.isSelected.toggle()
    }

    @IBAction func saveProject(_ sender: Any) {
        guard let projectName = projectNameTextField.text,
            !projectName.isEmpty,
            let projectType = projectTypeTextField.text,
            !projectType.isEmpty,
            let notes = notesTextView.text,
            let student = student else { return }

        if let project = project {
            updateProject(project: project, projectName: projectName, projectType: projectType, notes: notes, student: student)
        } else {
            createProject(projectName: projectName, projectType: projectType, notes: notes, student: student)
        }
    }

    private func createProject(projectName: String, projectType: String, notes: String, student: Student) {
        // swiftlint:disable:next all
        BackendController.shared.createProject(name: projectName, studentID: "\(student.id)", projectType: projectType, dueDate: dueDatePicker.date, description: notes, completed: completedButton.isSelected) { result, error in
            if let error = error {
                NSLog("Failed to create project with error: \(error)")
                return
            }

            if result {
                NSLog("Successfully created project 🙌")
            }

            DispatchQueue.main.async {
                self.delegate?.didCreateProject()
            }
        }

        if sendEmailButton.isSelected {
            guard let projectName = projectNameTextField.text,
               let notes = notesTextView.text else { return }
            if MFMailComposeViewController.canSendMail() {
                     let mail: MFMailComposeViewController = MFMailComposeViewController()
                     mail.mailComposeDelegate = self
            
                mail.setToRecipients(nil)
                mail.setSubject("Your \(projectName) is due")
                mail.setMessageBody("\(notes)", isHTML: false)

                     self.present(mail, animated: true, completion: nil)
                 } else {
                     let alert = UIAlertController(title: "Accounts", message: "Please log into your email", preferredStyle: .alert)
                     let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)

                     alert.addAction(okAction)
                     self.present(alert, animated: true, completion: nil)
                 }
        }
        navigationController?.popViewController(animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }


    private func updateProject(project: Project, projectName: String, projectType: String, notes: String, student: Student) {
        // swiftlint:disable:next all
        BackendController.shared.updateProject(project: project, name: projectName, studentID: "\(student.id)", projectType: projectType, dueDate: dueDatePicker.date, description: notes, completed: completedButton.isSelected) { result, error in
            if let error = error {
                NSLog("Failed to update project with error: \(error)")
                return
            }

            if result {
                NSLog("Successfully updated project 🙌")
            }

            DispatchQueue.main.async {
                self.delegate?.didCreateProject()
            }
        }

        navigationController?.popViewController(animated: true)
    }
}

