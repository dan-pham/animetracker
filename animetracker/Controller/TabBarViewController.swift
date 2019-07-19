//
//  TabBarViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        reloadViewControllers()
        setupNavTabBars()
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
    
    static func setupTabBarItem(vc: UIViewController, title: String, imageName: String) {
        vc.title = title
        let image = UIImage(named: imageName)
        vc.tabBarItem.image = image
    }
    
    let noListing = "No Listing"
    
    static func presentDetailVC(vc: UIViewController, animes: [Anime], indexPath: IndexPath) {
        let detailVC = vc.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        let noListing = "No Listing"
        let anime = animes[indexPath.item]
        
        if let image = anime.image {
            detailVC.animeImage = image
        }
        
        detailVC.animeTitle = anime.title!
        detailVC.numberOfEpisodes = ((anime.episodes ?? 0) >= 1) ? "\(anime.episodes!)" : noListing
        detailVC.status = anime.status ?? noListing
        detailVC.summary = anime.summary ?? noListing
        
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func signOut(_ sender: Any) {
        Alerts.showSignOutAlertVC(on: self)
    }
}
