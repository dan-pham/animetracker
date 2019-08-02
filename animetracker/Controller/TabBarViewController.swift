//
//  TabBarViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        checkIfUserIsLoggedIn()
    }
    
    // User authentication referenced from Let's Build That App's "Logging in with Email and Password" video https://www.letsbuildthatapp.com/course_video?id=61
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleSignOut), with: nil, afterDelay: 0)
        } else {
            reloadViewControllers()
            setupNavTabBars()
        }
    }
    
    func reloadViewControllers() {
        let viewControllers = self.viewControllers

        for viewController in viewControllers! {
            viewController.loadView()
            viewController.viewDidLoad()
        }
    }
    
    func setupNavTabBars() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBar.isTranslucent = false
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewController.loadViewIfNeeded()
        viewController.viewDidLoad()
    }
    
    @IBAction func signOut(_ sender: Any) {
        Alerts.showSignOutAlertVC(on: self, action: (UIAlertAction(title: "Sign Out", style: .default) {_ in
            self.handleSignOut()
        }))
    }
    
    // User authentication referenced from Let's Build That App's "Logging in with Email and Password" video https://www.letsbuildthatapp.com/course_video?id=61
    @objc func handleSignOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError {
            print(signOutError)
        }
        
        let signInNC = storyboard?.instantiateViewController(withIdentifier: "SignInNavController")
        present(signInNC!, animated: true, completion: nil)
    }
    
}
