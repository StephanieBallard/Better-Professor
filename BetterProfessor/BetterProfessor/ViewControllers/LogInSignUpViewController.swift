//
//  LogInSignUpViewController.swift
//  BetterProfessor
//
//  Created by Hunter Oppel on 6/23/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class LogInSignUpViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet var logInTypeSegmentedControl: UISegmentedControl!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var departmentTextField: UITextField!
    @IBOutlet var logInSignUpButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var typePicker = UIPickerView()
     var typeData = ["Choose a Department", "Computer Science", "iOS Development", "Data Science", "Web Development", "Arts", "Mathematics" ]
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
typePicker.delegate = self
        typePicker.dataSource = self
        typePicker.tag = 1
        departmentTextField.inputView = typePicker
        self.updateViews()
        updateTap()
        logInSignUpButton.layer.cornerRadius = 12
        
    }
     @IBAction func unwindLoginSegue(segue: UIStoryboardSegue) { }
    
    private func updateViews() {
        UIView.animate(withDuration: 0.4) {
            switch self.logInTypeSegmentedControl.selectedSegmentIndex {
                  
                  case 0:
                    self.confirmPasswordTextField.isHidden = false
                    self.emailTextField.isHidden = false
                    self.departmentTextField.isHidden = false

                    self.logInSignUpButton.setTitle("Sign Up", for: .normal)
                  default:
                    self.confirmPasswordTextField.isHidden = true
                    self.emailTextField.isHidden = true
                    self.departmentTextField.isHidden = true

                    self.logInSignUpButton.setTitle("Log In", for: .normal)
                  }
        }
      
    }

    @IBAction func didSwitchLogInType(_ sender: Any) {
        self.updateViews()
    }

    @IBAction func logInSignUp(_ sender: Any) {

        switch logInTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            self.signUp()
        default:
            self.logIn()
        }
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

    private func signUp() {
        activityIndicator.startAnimating()

        guard let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text,
            password == confirmPassword,
            !password.isEmpty,
            let department = departmentTextField.text,
            !department.isEmpty else {
                self.showAlertMessage(title: "ERROR", message: "Failed to sign up", actiontitle: "OK")
                self.activityIndicator.stopAnimating()
                return
        }

        BackendController.shared.signUp(username: username, password: password, department: department) { result, _, error in
            defer {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlertMessage(title: "ERROR", message: "Failed to sign up", actiontitle: "OK")
                    NSLog("⚠️ ERROR: \(error)")
                    return
                }
            }

            if result {
                DispatchQueue.main.async {
                    self.showAlertMessage(title: "Success", message: "You have been successfully signed up", actiontitle: "OK")
                    self.logIn()
                }
            }
        }
    }

    private func logIn() {
        activityIndicator.startAnimating()

        guard let username = usernameTextField.text,
        !username.isEmpty,
        let password = passwordTextField.text,
        !password.isEmpty else {
            self.activityIndicator.stopAnimating()
            return
        }

        BackendController.shared.signIn(username: username, password: password) { result in
            defer {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }

            DispatchQueue.main.async {
                if result {
                    self.performSegue(withIdentifier: "StudentViewSegue", sender: self)
                } else {
                    self.showAlertMessage(title: "ERROR", message: "Failed to log in", actiontitle: "OK")
                    return
                }
            }
        }
    }

    func showAlertMessage(title: String, message: String, actiontitle: String) {
        let endAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let endAction = UIAlertAction(title: actiontitle, style: .default) { (action: UIAlertAction ) in
        }
        endAlert.addAction(endAction)
        present(endAlert, animated: true, completion: nil)
    }
}

extension LogInSignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
              return typeData.count
      }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
              return typeData[row]
      }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return  departmentTextField.text = typeData[row]
    }
    
    func dismissPickerView() {
         let toolBar = UIToolbar()
         toolBar.sizeToFit()
         let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
         toolBar.setItems([doneButton], animated: false)
         toolBar.isUserInteractionEnabled = true
         departmentTextField.inputAccessoryView = toolBar

     }
    
    @objc func dismissKeyboard() {
           view.endEditing(true)
       }
    
    
}
