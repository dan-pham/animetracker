//
//  Alerts.swift
//  animetracker
//
//  Created by Dan Pham on 7/17/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

// Alert refactoring referenced from Sean Allen's "UIAlertController Refactor" on YouTube: https://www.youtube.com/watch?v=ZBS2uRP6_2U
struct Alerts {
    
    private static func showBasicAlertVC(on vc: UIViewController, with title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            vc.present(alertVC, animated: true)
        }
    }
    
    static func showSignInFailedAlertVC(on vc: UIViewController) {
        showBasicAlertVC(on: vc, with: "Sign In Failed", message: "Please enter your registered email and password")
    }
    
    static func showAuthenticateUserFailedAlertVC(on vc: UIViewController, message: String) {
        showBasicAlertVC(on: vc, with: "Sign In Failed", message: message)
    }
    
    static func showSignUpFailedAlertVC(on vc: UIViewController) {
        showBasicAlertVC(on: vc, with: "Sign Up Failed", message: "Please make sure you fill out every field")
    }
    
    static func showCreateUserFailedAlertVC(on vc: UIViewController, message: String) {
        showBasicAlertVC(on: vc, with: "Sign Up Failed", message: message)
    }
    
    static func showSearchInformationFailedAlertVC(on vc: UIViewController) {
        showBasicAlertVC(on: vc, with: "Search Failed", message: "Unable to retrieve the information for this anime. Please check your network connection and try again or try a different search term")
    }
    
    static func showSearchImageUrlFailedAlertVC(on vc: UIViewController) {
        showBasicAlertVC(on: vc, with: "Search Failed", message: "Unable to retrieve the image URL for this anime. Please check your network connection and try again or try a different search term")
    }
    
    static func showSearchImageFailedAlertVC(on vc: UIViewController) {
        showBasicAlertVC(on: vc, with: "Search Failed", message: "Unable to retrieve the image for this anime. Please check your network connection and try again or try a different search term")
    }
    
    private static func showConfirmationAlertVC(on vc: UIViewController, with title: String, message: String, action: UIAlertAction) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(action)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        DispatchQueue.main.async {
            vc.present(alertVC, animated: true)
        }
    }
    
    static func showSignOutAlertVC(on vc: UIViewController, action: UIAlertAction) {
        showConfirmationAlertVC(on: vc, with: "Sign Out", message: "Are you sure you want to sign out?", action: action)
    }
    
}
