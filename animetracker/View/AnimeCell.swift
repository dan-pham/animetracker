//
//  AnimeCell.swift
//  animetracker
//
//  Created by Dan Pham on 7/10/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class AnimeCell: UITableViewCell {

    // Programmatic tableView cell setup method referenced from https://www.letsbuildthatapp.com/course_video?id=58
    var anime: Anime? {
        didSet {
            textLabel?.text = anime?.title
            
            if let image = anime?.image {
                animeImageView.image = image
            } else {
                animeImageView.image = UIImage(named: "defaultPlaceholderImage")
            }
            
            if let numberOfEpisodes = anime?.episodes {
                if numberOfEpisodes > 1 {
                    detailTextLabel?.text =  "\(numberOfEpisodes) episodes"
                } else if numberOfEpisodes == 1 {
                    detailTextLabel?.text =  "\(numberOfEpisodes) episode"
                } else {
                    detailTextLabel?.text = "No episodes listed"
                }
            } else {
                detailTextLabel?.text = "No episodes listed"
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.superview!.frame.width - 72, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.superview!.frame.width - 72, height: detailTextLabel!.frame.height)
    }
    
    let animeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        TabBarViewController.setBackgroundColor(vc: self)
        addSubview(animeImageView)
        
        // x, y, width, height anchors
        animeImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        animeImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        animeImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        animeImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
