//
//  DetailViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    
    @IBOutlet weak var currentlyWatchingButton: UIButton!
    @IBOutlet weak var watchLaterButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var animeTitle = "Title"
    var animeImage = UIImage(named: "defaultPlaceholderImage")
    var numberOfEpisodes = "Episodes"
    var status = "Status"
    var summary = "Summary"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewComponents()
        setupButtonComponents()
    }
    
    func setupViewComponents() {
        titleLabel.text = animeTitle
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        imageView.image = animeImage
        imageView.contentMode = .scaleAspectFit
        
        episodeLabel.text = "Episodes: \(numberOfEpisodes)"
        
        statusLabel.text = "Status: \(status)"
        
        summaryTextView.text = summary
        summaryTextView.isEditable = false
    }
    
    func setupButtonImageColors(button: UIButton) {
        button.imageView?.tintColor = UIColor.lightGray
    }
    
    func setupButtonComponents() {
        setupButtonImageColors(button: favoritesButton)
        setupButtonImageColors(button: watchLaterButton)
        setupButtonImageColors(button: currentlyWatchingButton)
    }
    
    var currentlyWatchingIsPressed: Bool = false
    var watchLaterIsPressed: Bool = false
    var favoritesIsPressed: Bool = false
    
    func buttonPressed(button: UIButton, isPressed: Bool) -> Bool {
        let buttonIsPressed = !isPressed
        button.isHighlighted = buttonIsPressed
        button.imageView?.tintColor = button.isHighlighted ? UIColor.blue : UIColor.lightGray
        return buttonIsPressed
    }
    
    @IBAction func addToCurrentlyWatching(_ sender: Any) {
        print("Add to currently watching")
        currentlyWatchingIsPressed = buttonPressed(button: currentlyWatchingButton, isPressed: currentlyWatchingIsPressed)
    }
    
    @IBAction func addToWatchLater(_ sender: Any) {
        print("Add to watch later")
        watchLaterIsPressed = buttonPressed(button: watchLaterButton, isPressed: watchLaterIsPressed)
    }
    
    @IBAction func addToFavorites(_ sender: Any) {
        print("Add to favorites")
        favoritesIsPressed = buttonPressed(button: favoritesButton, isPressed: favoritesIsPressed)
    }
    
}

