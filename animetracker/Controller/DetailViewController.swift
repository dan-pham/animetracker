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
    
    var startingImageView: UIImageView?
    var blackBackgroundView: UIView?
    var startingFrame: CGRect?
    
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
        
        episodes = (anime.episodes == 0 || anime.episodes == nil) ? Constants.noListing : "\(anime.episodes!)"
        episodeLabel.text = "Episodes: \(episodes)"
        
        statusLabel.text = "Status: \(anime.status ?? Constants.noListing)"
        
        summaryTextView.text = anime.summary
        summaryTextView.isEditable = false
    }
    
    func setupButtonComponents() {
        setupButtonImageColors(button: currentlyWatchingButton)
        setupButtonImageColors(button: watchLaterButton)
        setupButtonImageColors(button: favoritesButton)
        
        checkFirebaseDatabaseForAnime(button: currentlyWatchingButton, category: Constants.currentlyWatchingCategory)
        checkFirebaseDatabaseForAnime(button: watchLaterButton, category: Constants.watchLaterCategory)
        checkFirebaseDatabaseForAnime(button: favoritesButton, category: Constants.favoritesCategory)
    }
    
    func setupButtonImageColors(button: UIButton) {
        button.imageView?.tintColor = UIColor.lightGray
    }
    
    func isEnteredForCategory(category: String, isEntered: Bool) {
        switch category {
        case Constants.currentlyWatchingCategory:
            isEnteredForCurrentlyWatching = isEntered
        case Constants.watchLaterCategory:
            isEnteredForWatchLater = isEntered
        case Constants.favoritesCategory:
            isEnteredForFavorites = isEntered
        default:
            return
        }
    }
    
    func checkFirebaseDatabaseForAnime(button: UIButton, category: String){
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("user-\(category)").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let animeDictionary = dictionary.keys
                let animesReference = Database.database().reference().child(Constants.animes)
                
                for animeId in animeDictionary {
                    animesReference.child(animeId).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let animeDetailDictionary = snapshot.value as? [String: AnyObject] {
                            let animeTitle = animeDetailDictionary[Constants.title] as! String
                            
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
        isEnteredForCategory(isEntered: isEnteredForCurrentlyWatching, button: currentlyWatchingButton, category: Constants.currentlyWatchingCategory)
    }
    
    @IBAction func addToWatchLater(_ sender: Any) {
        isEnteredForCategory(isEntered: isEnteredForWatchLater, button: watchLaterButton, category: Constants.watchLaterCategory)
    }
    
    @IBAction func addToFavorites(_ sender: Any) {
        isEnteredForCategory(isEntered: isEnteredForFavorites, button: favoritesButton, category: Constants.favoritesCategory)
    }
    
    // Uploading to and removing from Firebase referenced from Let's Build That App's "Firebase Chat Messenger" videos https://www.letsbuildthatapp.com/course/Firebase-Chat-Messenger
    func isEnteredForCategory(isEntered: Bool, button: UIButton, category: String) {
        if isEntered {
            // Remove anime from category in database
            removeFromFirebase(button: button, category: category)
        } else {
            // Add anime to category in database
            uploadToFirebase(button: button, category: category)
        }
    }
    
    func removeFromFirebase(button: UIButton, category: String) {
        let uid = Auth.auth().currentUser!.uid
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
    
    func uploadToFirebase(button: UIButton, category: String) {
        if let image = anime.image {
            uploadImageToFirebaseStorage(image) { (imageUrl) in
                self.saveAnimeWithImageUrl(imageUrl, button: button, category: category)
            }
        }
    }
    
    func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child(Constants.animeImages).child(imageName)
        
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
    
    func saveAnimeWithImageUrl(_ imageUrl: String, button: UIButton, category: String) {
        let ref = Database.database().reference().child(Constants.animes)
        let childRef = ref.childByAutoId()
        let userId = Auth.auth().currentUser!.uid
        
        let title = anime.title
        let episodes = anime.episodes
        let status = anime.status
        let summary = anime.summary
        
        anime.id = childRef.key
        let animeId = anime.id
        
        // Anime attributes
        var values: [String: AnyObject] = [Constants.animeId: animeId as AnyObject, Constants.title: title as AnyObject, Constants.episodes: episodes as AnyObject, Constants.status: status as AnyObject, Constants.summary: summary as AnyObject]
        
        // Image attribute
        let properties: [String: AnyObject] = [Constants.imageUrl: imageUrl as AnyObject]
        
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
}

// Image zoom in and zoom out feature referenced from Let's Build That App's "How to Implement Image Zoom" video https://www.letsbuildthatapp.com/course_video?id=202
extension DetailViewController {
    
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

