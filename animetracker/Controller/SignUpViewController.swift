//
//  SignUpViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var textFieldsFilled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        checkTextFields()
        
        if (textFieldsFilled) {
            navigationController?.popViewController(animated: true)
        } else {
            Alerts.showSignUpFailedAlertVC(on: self)
        }
    }
    
    func checkTextFields() {
        textFieldsFilled = (usernameTextField.hasText && firstNameTextField.hasText && lastNameTextField.hasText && emailTextField.hasText && passwordTextField.hasText) ? true : false
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
