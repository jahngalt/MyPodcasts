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
        setupNavigationBarButtons()
        //navigationItem.title = "Episodes"
    }
    
    //MARK:- Setup Work
    
    fileprivate func setupNavigationBarButtons() {
        
        //check if we already saved a podcast as favorite
        let savedPodcasts = UserDefaults.standard.savedPodcast()
        let hasFavorited = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
        
        if hasFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItems = [
                    UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
                    //UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts)),
                ]
            }
        }
        
        
    @objc fileprivate func handleSaveFavorite() {
        print("Fetching saved Podcasts from UserDefaults")
        guard let podcast = self.podcast else { return }
                
        // 1. Transform Podcast into Data
        do {
            var listOfPodcasts = UserDefaults.standard.savedPodcast()
            listOfPodcasts.append(podcast)
            let data = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
            
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
            
        } catch  {
            print("There is some error whith NSKeydArchiver")
        }
        
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil )
    }
    
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
    }
    
    
    @objc fileprivate func handleFetchSavedPodcasts() {
        print("Saving info into UserDefaults")
    
        //2. Retrieve our data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey:UserDefaults.favoritedPodcastKey) else { return }
        
        do {
            if let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Podcast]  {
                
                savedPodcasts.forEach { (p) in
                    print(p.artworkUrl600 ?? "")
                }
            }
        } catch {
            print("Couldn't read file.")
        }
    }
    
    
    fileprivate func setupTableView() {
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
        tableView.tableFooterView = UIView()
        print("setup table view")
    }
    
    
    //MARK:- UITableView
    
    //swipe to download
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let downloadAction  = UIContextualAction(style: .normal, title: "Download") { (action, view, success) in
            print("Download")
            
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            //hide after complete swipe and click download 
            tableView.isEditing = false
            
            //download the podcast episode using Alamofire
            APIService.shared.downloadEpisode(episode: episode)
            
        } 
        
        return UISwipeActionsConfiguration(actions: [downloadAction])
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       
        let activityIndicatorView  = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0 
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episode = self.episodes[indexPath.row]
        let mainTabBarController = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController as? MainTabBarController
        
        mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
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
