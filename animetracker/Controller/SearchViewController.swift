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
    
    var searchUrl = String()
    var animes = [Anime]()
    let activityIndicator = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TabBarViewController.initializeTableView(vc: self, tableView: tableView, cellId: Constants.cellId, title: Constants.search, imageName: Constants.searchImage)
        setupTableView()
    }
    
    func setupTableView() {
        animes.removeAll()
        tableView.reloadData()
    }
    
    // Searchbar implementation referenced from Jared Davidson's "Spotify Search!" video: https://www.youtube.com/watch?v=Aegohk-3ffo
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.showActivityIndicator()
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
                            self.activityIndicator.hideActivityIndicator()
                            Alerts.showSearchImageFailedAlertVC(on: self)
                            debugPrint("Error: ", error)
                        }

                        if success {
                            let status = airing == 0 ? Constants.finishedAiring : Constants.airing
                            let anime = Anime()
                            
                            anime.title = title
                            anime.image = image
                            anime.episodes = episodes
                            anime.status = status
                            anime.summary = summary
                            
                            self.animes.append(anime)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.activityIndicator.hideActivityIndicator()
                        }
                    }
                } else {
                    self.activityIndicator.hideActivityIndicator()
                    Alerts.showSearchImageUrlFailedAlertVC(on: self)
                    print("error: ", error!.localizedDescription)
                }
            } else {
                self.activityIndicator.hideActivityIndicator()
                Alerts.showSearchInformationFailedAlertVC(on: self)
                print("error: ", error!.localizedDescription)
            }
        }
        self.view.endEditing(true)
    }
}

// MARK: - UITableView delegate methods

extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as! AnimeCell
        
        let animeCell = animes[indexPath.row]
        cell.anime = animeCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TabBarViewController.presentDetailVC(vc: self, animes: animes, indexPath: indexPath)
    }
    
}
