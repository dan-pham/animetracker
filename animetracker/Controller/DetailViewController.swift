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
    var episodes = String()
    var isEnteredForCurrentlyWatching = Bool()
    var isEnteredForWatchLater = Bool()
    var isEnteredForFavorites = Bool()
    
    let noListing = "No listing"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewComponents()
        setupButtonComponents()
    }
    
    func setupViewComponents() {
        titleLabel.text = anime.title
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        imageView.image = anime.image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        episodes = (anime.episodes == 0 || anime.episodes == nil) ? noListing : "\(anime.episodes!)"
        episodeLabel.text = "Episodes: \(episodes)"
        
        statusLabel.text = "Status: \(anime.status ?? noListing)"
        
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
        
        checkFirebaseDatabaseForAnime(button: favoritesButton, category: "favorites")
        
    }
    
    func isEnteredForCategory(category: String, isEntered: Bool) {
        switch category {
        case "currentlyWatching":
            isEnteredForCurrentlyWatching = isEntered
        case "watchLater":
            isEnteredForWatchLater = isEntered
        case "favorites":
            isEnteredForFavorites = isEntered
        default:
            return
        }
    }
    
    fileprivate func checkFirebaseDatabaseForAnime(button: UIButton, category: String){
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("user-\(category)").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let animeDictionary = dictionary.keys
                let animesReference = Database.database().reference().child("animes")
                
                for animeId in animeDictionary {
                    animesReference.child(animeId).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let animeDetailDictionary = snapshot.value as? [String: AnyObject] {
                            let animeTitle = animeDetailDictionary["title"] as! String
                            
                            if (self.anime.title! == animeTitle) {
                                self.isEnteredForCategory(category: category, isEntered: true)
                                button.imageView?.tintColor = UIColor.blue
                            }
                        }
                    }, withCancel: nil)
                }
            }
        }, withCancel: nil)
    }
    
    @IBAction func addToCurrentlyWatching(_ sender: Any) {
        print("Add to currently watching")
    }
    
    @IBAction func addToWatchLater(_ sender: Any) {
        print("Add to watch later")
    }
    
    @IBAction func addToFavorites(_ sender: Any) {
        if isEnteredForFavorites {
            // Remove anime from favorites in database
            removeFromFirebase(button: favoritesButton, category: "favorites")
        } else {
            // Add anime to favorites in database
            uploadToFirebase(button: favoritesButton, category: "favorites")
        }
    }
    
    fileprivate func removeFromFirebase(button: UIButton, category: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if let animeId = anime.id {
            Database.database().reference().child("user-\(category)").child(uid).child(animeId).removeValue { (error, ref) in
                
                if error != nil {
                    print("Failed to delete anime: ", error!.localizedDescription)
                    return
                }
                
                self.isEnteredForCategory(category: category, isEntered: false)
                button.imageView?.tintColor = UIColor.lightGray
            }
        }
    }
    
    fileprivate func uploadToFirebase(button: UIButton, category: String) {
        if let image = anime.image {
            uploadImageToFirebaseStorage(image) { (imageUrl) in
                self.saveAnimeWithImageUrl(imageUrl, button: button, category: category)
            }
        }
    }
    
    fileprivate func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("anime_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.5) {
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Failed to upload image: ", error!.localizedDescription)
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
    
    fileprivate func saveAnimeWithImageUrl(_ imageUrl: String, button: UIButton, category: String) {
        let ref = Database.database().reference().child("animes")
        let childRef = ref.childByAutoId()
        let userId = Auth.auth().currentUser!.uid
        
        let title = anime.title
        let episodes = anime.episodes
        let status = anime.status
        let summary = anime.summary
        
        anime.id = childRef.key
        let animeId = anime.id
        
        // Anime attributes
        var values: [String: AnyObject] = ["animeId": animeId as AnyObject, "title": title as AnyObject, "episodes": episodes as AnyObject, "status": status as AnyObject, "summary": summary as AnyObject]
        
        // Image attribute
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Error updating child values for favorites: ", error)
                return
            }
            
            let userAnimesRef = Database.database().reference().child("user-\(category)").child(userId).child(animeId!)
            userAnimesRef.setValue(1)
            
            self.isEnteredForCategory(category: category, isEntered: true)
            button.imageView?.tintColor = UIColor.blue
        }
    }
    
    // Image zoom in and zoom out feature referenced from Let's Build That App's "How to Implement Image Zoom" video https://www.letsbuildthatapp.com/course_video?id=202
    
    var startingImageView: UIImageView?
    var blackBackgroundView: UIView?
    var startingFrame: CGRect?
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            performZoomInForStartingImageView(imageView)
        }
    }
    
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
}

