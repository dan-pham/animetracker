//
//  ViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fetchAnimeInfoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialViewComponents()
    }
    
    var clicked: Bool = false

    @IBAction func fetchAnimeInfo(_ sender: Any) {
        
        JikanClient.sharedInstance.retrieveInfoForAnime(url: JikanClient.Endpoints.retrieveAnimeFromJikan.url) { (success, title, imageUrl, error) in
            
            if success {
                print("success")
                
                if let title = title {
                    DispatchQueue.main.async {
                        self.titleLabel.text = title
                    }
                }
                
                if let imageUrl = imageUrl {
                    JikanClient.sharedInstance.retrieveAnimeImage(imageUrl) { (success, image, error) in
                        
                        if error != nil {
                            debugPrint("Error: ", error)
                        }
                        
                        if success {
                            DispatchQueue.main.async {
                                self.imageView.image = image
                            }
                        }
                    }
                    
                } else {
                    print("error: ", error)
                }
            }
        }
    }
    
    func setupInitialViewComponents() {
        titleLabel.text = "Default Title"
        
        imageView.image = UIImage(named: "defaultPlaceholderImage")
        imageView.contentMode = .scaleAspectFit
    }
    
}

