//
//  SampleAnimeArray.swift
//  animetracker
//
//  Created by Dan Pham on 7/10/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class SampleAnimeArray {
    // MARK: Sample anime array
    
    // Shared instance
    static var sharedInstance = SampleAnimeArray()
    
    var animes = [Anime]()
    
    let sampleSummary = "When Cowboy Bebop first aired in spring of 1998 on TV Tokyo, only episodes 2, 3, 7-15, and 18 were broadcast, it was concluded with a recap special known as Yose Atsume Blues. This was due to anime censorship having increased following the big controversies over Evangelion, as a result most of the series was pulled from the air due to violent content. Satellite channel WOWOW picked up the series in the fall of that year and aired it in its entirety uncensored. Cowboy Bebop was not a ratings hit in Japan, but sold over 19,000 DVD units in the initial release run, and 81,000 overall. Protagonist Spike Spiegel won Best Male Character, and Megumi Hayashibara won Best Voice Actor for her role as Faye Valentine in the 1999 and 2000 Anime Grand Prix, respectively.Cowboy Bebop's biggest influence has been in the United States, where it premiered on Adult Swim in 2001 with many reruns since. The show's heavy Western influence struck a chord with American viewers, where it became a \"gateway drug\" to anime aimed at adult audiences."
    
    func setupSampleAnimeArray() {
        let anime1 = Anime()
        anime1.title = "Star Wars"
        anime1.image = UIImage(named: "starwars")
        anime1.episodes = 1
        anime1.status = "Completed"
        anime1.summary = sampleSummary
        
        let anime2 = Anime()
        anime2.title = "Pokemon"
        //anime2.image = UIImage(named: "starwars")
        anime2.episodes = 36
        anime2.status = "Airing"
        anime2.summary = sampleSummary
        
        let anime3 = Anime()
        anime3.title = "Digimon"
        anime3.image = UIImage(named: "starwars")
        //anime3.episodes = 24
        anime3.status = "Completed"
        anime3.summary = sampleSummary
        
        let anime4 = Anime()
        anime4.title = "Shingeki no Kyojin Shingeki no Kyojin Shingeki no Kyojin"
        anime4.image = UIImage(named: "starwars")
        anime4.episodes = 12
        anime4.status = "Completed"
        //anime4.summary = sampleSummary
        
        let anime5 = Anime()
        anime5.title = "Tate no Yuusha"
        anime5.image = UIImage(named: "starwars")
        anime5.episodes = 0
        //anime5.status = "Airing"
        anime5.summary = sampleSummary
        
        animes = [anime1, anime2, anime3, anime4, anime5]
    }
}
