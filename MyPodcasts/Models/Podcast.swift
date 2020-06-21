//
//  Podcast.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/18/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
