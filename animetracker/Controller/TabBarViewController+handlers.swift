//
//  TabBarViewController+handlers.swift
//  animetracker
//
//  Created by Dan Pham on 7/26/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

extension TabBarViewController {
    
    static func initializeTableView(vc: UIViewController, tableView: UITableView, cellId: String, title: String, imageName: String) {
        tableView.register(AnimeCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        setupTabBarItem(vc: vc, title: title, imageName: imageName)
        setBackgroundColor(vc: vc.view)
    }
    
    static func setupTabBarItem(vc: UIViewController, title: String, imageName: String) {
        vc.title = title
        let image = UIImage(named: imageName)
        vc.tabBarItem.image = image
    }
    
    static func setBackgroundColor(vc: UIView) {
        vc.backgroundColor = UIColor(red: 170/255, green: 204/255, blue: 223/255, alpha: 1)
    }
    
    static func presentDetailVC(vc: UIViewController, animes: [Anime], indexPath: IndexPath) {
        let detailVC = vc.storyboard?.instantiateViewController(withIdentifier: Constants.detailViewController) as! DetailViewController
        let anime = animes[indexPath.item]
        
        detailVC.anime = anime
        
        switch vc {
        case is CurrentlyWatchingViewController:
            detailVC.isEnteredForCurrentlyWatching = true
        case is WatchLaterViewController:
            detailVC.isEnteredForWatchLater = true
        case is FavoritesViewController:
            detailVC.isEnteredForFavorites = true
        default:
            break
        }
        
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
