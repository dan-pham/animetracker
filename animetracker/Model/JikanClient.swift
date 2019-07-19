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
    
    //searchUrl = "https://api.jikan.moe/v3/search/anime/?q=\(finalKeywords!)&limit=20"
    
    // Jikan API Endpoints
    enum Endpoints {
        static let base = "https://api.jikan.moe/v3"
        static let animeSearchQuery = "/search/anime/?q="
        static let limit = "&limit=20"
        
//
//        case retrieveAnimeFromJikan
//
//        var stringValue: String {
//            switch self {
//            case .retrieveAnimeFromJikan:
//                return Endpoints.base + Endpoints.search + Endpoints.anime + Endpoints.query
//            }
//        }
//
//        var url: URL {
//            return URL(string: stringValue)!
//        }
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
    
    func retrieveInfoForAnime(url: URL, completion: @escaping (_ success: Bool, _ title: String?, _ imageUrl: String?, _ episodes: Int?, _ airing: Int?, _ summary: String?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                debugPrint("Error with request: \(error)")
                completion(false, nil, nil, nil, nil, nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode == 200) else {
                debugPrint("Response: \(response)")
                completion(false, nil, nil, nil, nil, nil, error)
                return
            }
            
            guard let data = data else {
                debugPrint("Error with returning data")
                completion(false, nil, nil, nil, nil, nil, error)
                return
            }
            
            let parsedData: [String: AnyObject]
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                debugPrint("Error with parsing data")
                completion(false, nil, nil, nil, nil, nil, error)
                return
            }
            
            guard let results = parsedData["results"] as? [[String: AnyObject]] else {
                debugPrint("ParsedData: ", parsedData)
                debugPrint("Error with parsing results")
                completion(false, nil, nil, nil, nil, nil, error)
                return
            }
            
            for result in results {
                
                guard let title = result["title"] as? String else {
                    debugPrint("Error with parsing title")
                    completion(false, nil, nil, nil, nil, nil, error)
                    return
                }
                
                guard let imageUrl = result["image_url"] as? String else {
                    debugPrint("Error with parsing image url")
                    completion(false, nil, nil, nil, nil, nil, error)
                    return
                }
                
                guard let episodes = result["episodes"] as? Int else {
                    debugPrint("Error with parsing episodes")
                    completion(false, nil, nil, nil, nil, nil, error)
                    return
                }
                
                guard let airing = result["airing"] as? Int else {
                    debugPrint("result: ", result)
                    debugPrint("Error with parsing airing")
                    completion(false, nil, nil, nil, nil, nil, error)
                    return
                }
                
                guard let summary = result["synopsis"] as? String else {
                    debugPrint("Error with parsing synopsis")
                    completion(false, nil, nil, nil, nil, nil, error)
                    return
                }
                
                completion(true, title, imageUrl, episodes, airing, summary, nil)
            }
        }
        task.resume()
    }
    
}



