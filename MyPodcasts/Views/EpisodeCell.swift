//
//  EpisodeCell.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/22/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    var episode: Episode! {
        didSet {
           titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            //cell.textLabel?.numberOfLines = 0
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            let url = URL(string: episode.imageURL?.toSecureHTTPS() ?? "")
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel! 
    
    
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
}
