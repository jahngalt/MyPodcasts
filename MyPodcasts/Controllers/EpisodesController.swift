//
//  EpisodesController.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/21/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    
    fileprivate func fetchEpisodes() {
        print("Looking at episodes at feed URL: ", podcast?.feedUrl ?? "")
        
        guard let feedURL = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodes(feedURL: feedURL) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }

    fileprivate let cellId = "cellId"
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        //navigationItem.title = "Episodes"
    }
    
    //MARK:- Setup Work
    fileprivate func setupTableView() {
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
        tableView.tableFooterView = UIView()
        
        
    }
    
    
    //MARK:- UITableView
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        print("Trying to play episode: ", episode.title)
        
        if let keyWindow = UIWindow.key {
            
            let playerDetailsView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
            
            playerDetailsView.episode = episode
            
            
            playerDetailsView.frame = keyWindow.frame
            keyWindow.addSubview(playerDetailsView)
        }

        //let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:cellId, for: indexPath) as! EpisodeCell
        
        let episode = episodes[indexPath.row]
        
        cell.episode = episode
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}


extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
