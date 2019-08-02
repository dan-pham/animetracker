//
//  Extensions.swift
//  animetracker
//
//  Created by Dan Pham on 7/26/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit
import Firebase

// Image caching referenced from Let's Build That App's "Lets Fix Some Bugs" video https://www.letsbuildthatapp.com/course_video?id=57
let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String){
        self.image = nil
        
        // Check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // Otherwise download the image into cache
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
    
}
