//
//  PlayerDetailsView.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/28/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            
            guard let url = URL(string: episode.imageURL ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    
    @IBAction func handleDismiss(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
