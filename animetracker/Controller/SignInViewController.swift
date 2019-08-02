//
//  SignInViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    let activityIndicator = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TabBarViewController.setBackgroundColor(vc: self.view)
        delegateTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        clearTextFields()
    }
    
    @IBAction func signIn(_ sender: Any) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            Alerts.showSignInFailedAlertVC(on: self)
            return
        }
        
        activityIndicator.showActivityIndicator()
    
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.activityIndicator.hideActivityIndicator()
                Alerts.showAuthenticateUserFailedAlertVC(on: self, message: "\(error.localizedDescription)")
                print("Error signing in: ", error)
                return
            }
            
            // User successfully signed in
            self.navigationController?.isNavigationBarHidden = true
            self.activityIndicator.hideActivityIndicator()
            
            let tabBarNavController = self.storyboard?.instantiateViewController(withIdentifier: Constants.tabBarNavController)
            self.present(tabBarNavController!, animated: true)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        navigationController?.isNavigationBarHidden = true
        
        let signUpViewController = storyboard?.instantiateViewController(withIdentifier: Constants.signUpViewController) as! SignUpViewController
        navigationController?.pushViewController(signUpViewController, animated: true)
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
