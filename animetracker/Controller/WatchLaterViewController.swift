//
//  WatchLaterViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/17/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

class WatchLaterViewController: UITableViewController {

    var animes = [Anime]()
    var animesDictionary = [String: Anime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TabBarViewController.initializeTableView(vc: self, tableView: tableView, cellId: Constants.cellId, title: Constants.watchLater, imageName: Constants.bookmark)
        setupTableView()
        observeUserAnimes()
    }
    
    func setupTableView() {
        animes.removeAll()
        animesDictionary.removeAll()
        tableView.reloadData()
    }
    
    // Observing snapshots from Firebase loosely referenced from Let's Build That App's "Firebase Chat Messenger" videos https://www.letsbuildthatapp.com/course/Firebase-Chat-Messenger
    func observeUserAnimes() {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child(Constants.userWatchLater).child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let animeId = snapshot.key
            self.fetchAnimeWithAnimeId(animeId: animeId)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.animesDictionary.removeValue(forKey: snapshot.key)
            self.handleReloadTable()
            
        }, withCancel: nil)
    }
    
    func fetchAnimeWithAnimeId(animeId: String) {
        let animeReference = Database.database().reference().child(Constants.animes).child(animeId)
        animeReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let anime = self.createAnimeFromDictionary(dictionary)
                
                self.animesDictionary[animeId] = anime
                self.handleReloadTable()
            }
        }, withCancel: nil)
    }
    
    func createAnimeFromDictionary(_ dictionary: [String: AnyObject]) -> Anime {
        let anime = Anime()
        var imageUrl = String()
        
        anime.id = dictionary[Constants.animeId] as? String
        anime.title = dictionary[Constants.title] as? String
        anime.episodes = dictionary[Constants.episodes] as? Int
        anime.status = dictionary[Constants.status] as? String
        anime.summary = dictionary[Constants.summary] as? String
        
        imageUrl = dictionary[Constants.imageUrl] as! String
        
        let imageView = UIImageView()
        imageView.loadImageUsingCacheWithUrlString(imageUrl)
        anime.image = imageView.image
        return anime
    }
    
    // Alphabetical array sort referenced from StackOverflow post "Swift: Sort array of objects alphabetically" https://stackoverflow.com/questions/26719744/swift-sort-array-of-objects-alphabetically
    func handleReloadTable() {
        self.animes = Array(self.animesDictionary.values)
        self.animes.sort { (anime1, anime2) -> Bool in
            return anime1.title! < anime2.title!
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableView delegate methods

extension WatchLaterViewController {
    
    // Swipe to Delete feature referenced from Let's Build That App's "How to Swipe and Delete Messages in UITableView" video https://www.letsbuildthatapp.com/course_video?id=232
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let anime = self.animes[indexPath.row]
        
        if let animeId = anime.id {
            Database.database().reference().child(Constants.userWatchLater).child(uid).child(animeId).removeValue { (error, ref) in
                
                if error != nil {
                    print("Failed to delete anime: ", error!.localizedDescription)
                    return
                }
                
                self.animesDictionary.removeValue(forKey: animeId)
                self.handleReloadTable()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as! AnimeCell
        
        let anime = animes[indexPath.row]
        cell.anime = anime
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TabBarViewController.presentDetailVC(vc: self, animes: animes, indexPath: indexPath)
    }
    
}
