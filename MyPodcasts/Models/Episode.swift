//
//  Episode.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/22/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let description: String
    var imageURL: String?
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageURL = feedItem.iTunes?.iTunesImage?.attributes?.href 
    }
}
