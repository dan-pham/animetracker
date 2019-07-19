//
//  SearchViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/10/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let cellId = "cellId"
    
    var searchUrl = String()
    var animes = [Anime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.reloadData()
        tableView.register(AnimeCell.self, forCellReuseIdentifier: cellId)
        TabBarViewController.setupTabBarItem(vc: self, title: "Search", imageName: "search")
        
        self.view.backgroundColor = UIColor.green
    }
    
    // Searchbar implementation referenced from Jared Davidson's "Spotify Search!" on Youtube: https://www.youtube.com/watch?v=Aegohk-3ffo
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        animes.removeAll()
        
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "_").lowercased()

        searchUrl = JikanClient.Endpoints.base + JikanClient.Endpoints.animeSearchQuery + "\(finalKeywords!)" + JikanClient.Endpoints.limit
        
        let url = URL(string: searchUrl)!
        
        JikanClient.sharedInstance.retrieveInfoForAnime(url: url) { (success, title, imageUrl, episodes, airing, summary, error) in
            if success {
                if let imageUrl = imageUrl {
                    JikanClient.sharedInstance.retrieveAnimeImage(imageUrl) { (success, image, error) in
                        if error != nil {
                            debugPrint("Error: ", error)
                        }

                        if success {
                            let status = airing == 0 ? "Finished Airing" : "Airing"
                            let anime = Anime()
                            
                            anime.title = title
                            anime.image = image
                            anime.episodes = episodes
                            anime.status = status
                            anime.summary = summary
                            
                            self.animes.append(anime)
                        }
                        DispatchQueue.main.async {
//                            print("Reloading tableView")
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    print("error: ", error)
                }
            } else {
                print("error: ", error)
            }
        }
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AnimeCell

        let animeCell = animes[indexPath.row]
        cell.anime = animeCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TabBarViewController.presentDetailVC(vc: self, animes: animes, indexPath: indexPath)
    }
    
}
