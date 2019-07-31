//
//  FavoritesViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/17/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

class FavoritesViewController: UITableViewController {
    
    let cellId = "cellId"
    var animes = [Anime]()
    var animesDictionary = [String: Anime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
        observeUserAnimes()
    }
    
    func initializeTableView() {
        tableView.register(AnimeCell.self, forCellReuseIdentifier: cellId)
        TabBarViewController.setupTabBarItem(vc: self, title: "Favorites", imageName: "heart")
        tableView.allowsMultipleSelectionDuringEditing = true
        
        animes.removeAll()
        animesDictionary.removeAll()
        tableView.reloadData()
        
        // Remove in final revision
        self.view.backgroundColor = UIColor.yellow
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let anime = self.animes[indexPath.row]
        
        if let animeId = anime.id {
             Database.database().reference().child("user-favorites").child(uid).child(animeId).removeValue { (error, ref) in
                
                if error != nil {
                    print("Failed to delete anime: ", error?.localizedDescription)
                    return
                }
                
                self.animesDictionary.removeValue(forKey: animeId)
                tableView.reloadData()
            }
        }
    }
    
    func observeUserAnimes() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-favorites").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let animeId = snapshot.key
            self.fetchAnimeWithAnimeId(animeId: animeId)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.animesDictionary.removeValue(forKey: snapshot.key)
            self.handleReloadTable()
            
        }, withCancel: nil)
    }
    
    fileprivate func fetchAnimeWithAnimeId(animeId: String) {
        let animeReference = Database.database().reference().child("animes").child(animeId)
        animeReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let anime = Anime()
                var imageUrl = String()
                
                anime.id = dictionary["animeId"] as? String
                anime.title = dictionary["title"] as? String
                anime.episodes = dictionary["episodes"] as? Int
                anime.status = dictionary["status"] as? String
                anime.summary = dictionary["summary"] as? String
                
                imageUrl = dictionary["imageUrl"] as! String
                
                let imageView = UIImageView()
                imageView.loadImageUsingCacheWithUrlString(imageUrl)
                anime.image = imageView.image
                
                self.animesDictionary[animeId] = anime
                self.handleReloadTable()
            }
        }, withCancel: nil)
    }
    
    func handleReloadTable() {
        self.animes = Array(self.animesDictionary.values)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AnimeCell
        
        let anime = animes[indexPath.row]
        cell.anime = anime
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TabBarViewController.presentDetailVC(vc: self, animes: animes, indexPath: indexPath)
    }

}
