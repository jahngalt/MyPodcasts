//
//  RSSFeed.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/23/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import FeedKit

extension RSSFeed {
    
    
    func toEpisodes() -> [Episode] {
        
        let imageURL = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]()
        
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            
            if episode.imageURL == nil {
                episode.imageURL = imageURL
            }
            
            
            episodes.append(episode)
        })
        
        return episodes
        
    }
}
