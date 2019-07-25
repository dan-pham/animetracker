//
//  DetailViewController.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    
    @IBOutlet weak var currentlyWatchingButton: UIButton!
    @IBOutlet weak var watchLaterButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var anime = Anime()
    let noListing = "No listing"
    
//    var animeTitle = String()
//    var animeImage = UIImage(named: "defaultPlaceholderImage")
//    var numberOfEpisodes = Int()
//    var animeStatus = String()
//    var animeSummary = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewComponents()
        setupButtonComponents()
    }
    
    var episodes = String()
    
    func setupViewComponents() {
//        titleLabel.text = animeTitle
        titleLabel.text = anime.title
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
//        imageView.image = animeImage
        imageView.image = anime.image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
//        episodeLabel.text = "Episodes: \(numberOfEpisodes)"
        episodes = (anime.episodes == 0) ? noListing : "\(anime.episodes!)"
        episodeLabel.text = "Episodes: \(episodes)"
        
//        statusLabel.text = "Status: \(animeStatus)"
        statusLabel.text = "Status: \(anime.status ?? noListing)"
        
//        summaryTextView.text = animeSummary
        summaryTextView.text = anime.summary
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
    
    // Image zoom in and zoom out feature referenced from Let's Build That App's "How to Implement Image Zoom" video https://www.letsbuildthatapp.com/course_video?id=202
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            performZoomInForStartingImageView(imageView)
        }
    }
    
    var startingImageView: UIImageView?
    var blackBackgroundView: UIView?
    var startingFrame: CGRect?
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {

        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.contentMode = .scaleAspectFit
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                // h2 / w2 = h1 / w1 => h2 = h1 / w1 * w2
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.height
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.contentMode = .scaleAspectFit
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
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
        
        if let image = anime.image {
            uploadImageToFirebaseStorage(image) { (imageUrl) in
                self.displayAnimeWithImageUrl(imageUrl, image: image)
            }
        }
        
    }
    
    fileprivate func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("anime_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Failed to upload image: ", error)
                    return
                }
                
                ref.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("Failed to download from URL: ", err)
                        return
                    }
                    
                    completion(url?.absoluteString ?? "")
                })
            }
        }
    }
    
    fileprivate func displayAnimeWithImageUrl(_ imageUrl: String, image: UIImage) {
        let ref = Database.database().reference().child("favorites")
        let childRef = ref.childByAutoId()
        
        let image = image
        let title = anime.title
        let episodes = anime.episodes
        let status = anime.status
        let summary = anime.summary
        
//        var values: [String: AnyObject] = ["title": title as AnyObject, "image": image as AnyObject, "episodes": episodes as AnyObject, "status": status as AnyObject, "summary": summary as AnyObject]
        
        // Anime attributes
        var values: [String: AnyObject] = ["title": title as AnyObject, "episodes": episodes as AnyObject, "status": status as AnyObject, "summary": summary as AnyObject]
        
        // Image attributes
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Error updating child values for favorites: ", error)
                return
            }
            
            guard let animeId = childRef.key else {
                return
            }
            
            let userAnimesRef = ref.child(animeId)
            userAnimesRef.setValue(1)
        }
        
    }
    
}

