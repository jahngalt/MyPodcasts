//
//  PodcastCell.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/21/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
  
    @IBOutlet weak var podcastImageView: UIImageView!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast!  {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            //print("Loading image with URL: ", podcast.artworkUrl600 ?? "")
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            
            //without caching
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//                print("Finished downloading image data: ", data)
//                guard let data = data else { return }
//
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//            }.resume()
            
            //with caching
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
