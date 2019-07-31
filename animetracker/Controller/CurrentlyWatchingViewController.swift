//
//  CurrentlyWatchingViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/17/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

class CurrentlyWatchingViewController: UITableViewController {

    let cellId = "cellId"
    let noListing = "No Listing"
    
    let sampleArray = SampleAnimeArray.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.reloadData()
        tableView.register(AnimeCell.self, forCellReuseIdentifier: cellId)
        TabBarViewController.setupTabBarItem(vc: self, title: "Currently Watching", imageName: "main_menu")
        
        self.view.backgroundColor = UIColor.red
        sampleArray.setupSampleAnimeArray()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleArray.animes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AnimeCell
        
        let anime = sampleArray.animes[indexPath.row]
        cell.anime = anime
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TabBarViewController.presentDetailVC(vc: self, animes: sampleArray.animes, indexPath: indexPath)
    }

}
