//
//  SignInViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var userConfirmed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegateTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        clearTextFields()
    }
    
    @IBAction func signIn(_ sender: Any) {
        confirmUser()
        
        if (userConfirmed) {
        navigationController?.isNavigationBarHidden = true
        
        let tabBarNavController = storyboard?.instantiateViewController(withIdentifier: "TabBarNavController")
        present(tabBarNavController!, animated: true)
        } else {
            Alerts.showSignInFailedAlertVC(on: self)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        navigationController?.isNavigationBarHidden = true
        
        let signUpViewController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    func confirmUser() {
        userConfirmed = (emailTextField.hasText && passwordTextField.hasText) ? true : false
    }
    
}

// MARK: - UITextFieldDelegate

extension SignInViewController: UITextFieldDelegate {
    func delegateTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
