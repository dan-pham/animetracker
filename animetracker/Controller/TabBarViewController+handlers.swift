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
    
    static func setupTabBarItem(vc: UIViewController, title: String, imageName: String) {
        vc.title = title
        let image = UIImage(named: imageName)
        vc.tabBarItem.image = image
    }
    
    static func presentDetailVC(vc: UIViewController, animes: [Anime], indexPath: IndexPath) {
        let detailVC = vc.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
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
