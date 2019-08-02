//
//  SignUpViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TabBarViewController.setBackgroundColor(vc: self.view)
        delegateTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        clearTextFields()
    }
    
    @IBAction func cancelSignUp(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneSignUp(_ sender: Any) {
        
        guard usernameTextField.hasText, firstNameTextField.hasText, lastNameTextField.hasText, emailTextField.hasText, passwordTextField.hasText else {
            Alerts.showSignUpFailedAlertVC(on: self)
            return
        }
        
        guard let username = usernameTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            Alerts.showSignUpFailedAlertVC(on: self)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                Alerts.showCreateUserFailedAlertVC(on: self, message: "\(error.localizedDescription)")
                print("Error creating user: ", error)
                return
            }
            
            guard let uid = user?.user.uid else {
                return
            }
            
            // User authentication successful
            let values = [Constants.username: username, Constants.firstName: firstName, Constants.lastName: lastName, Constants.email: email]
            
            self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
        }
    }
    
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child(Constants.users).child(uid)
        usersReference.updateChildValues(values) { (error, ref) in
            
            if let error = error {
                print("Error updating child values in database: ", error)
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    func delegateTextFields() {
        usernameTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func clearTextFields() {
        usernameTextField.text = ""
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
