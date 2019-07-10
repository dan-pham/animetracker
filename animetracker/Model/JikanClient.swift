//
//  JikanClient.swift
//  animetracker
//
//  Created by Dan Pham on 7/9/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class JikanClient {
    
    // MARK: Properties
    
    // Shared instance
    static var sharedInstance = JikanClient()
    
    // Jikan API Endpoints
    enum Endpoints {
        static let base = "https://api.jikan.moe/"
        static let anime = "anime/1"
        
        case retrieveAnimeFromJikan
        
        var stringValue: String {
            switch self {
            case.retrieveAnimeFromJikan:
                return Endpoints.base + Endpoints.anime
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }

    func retrieveInfoForAnime(url: URL, completion: @escaping (_ success: Bool, _ title: String?, _ imageUrl: String?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                debugPrint("Error with request: \(error)")
                completion(false, nil, nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode == 200) else {
                debugPrint("Response: \(response)")
                completion(false, nil, nil, error)
                return
            }
            
            guard let data = data else {
                debugPrint("Error with returning data")
                completion(false, nil, nil, error)
                return
            }
            
            let parsedData: [String: AnyObject]
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                debugPrint("ParsedData: \n", parsedData)
            } catch {
                debugPrint("Error with parsing data")
                completion(false, nil, nil, error)
                return
            }
            
            guard let title = parsedData["title"] as? String else {
                debugPrint("Error with parsing title")
                completion(false, nil, nil, error)
                return
            }
            
            guard let imageUrl = parsedData["image_url"] as? String else {
                debugPrint("Error with parsing image url")
                completion(false, nil, nil, error)
                return
            }
            
            completion(true, title, imageUrl, nil)
        }
        task.resume()
    }
    
    func retrieveAnimeImage(_ imageUrl: String, completion: @escaping (_ success: Bool, _ image: UIImage?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            if let image = UIImage(data: data!) {
                completion(true, image, nil)
            } else {
                debugPrint("Error retrieving image")
                completion(false, nil, error)
                return
            }
            
        })
        task.resume()
    }
    
}



