//
//  DownloadsController.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 7/15/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit


class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        setupObservers()
    }
    
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    
    @objc fileprivate func handleDownloadComplete(notification: Notification) {
        
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else { return }
        
        guard let index = self.episodes.firstIndex(where: {$0.title == episodeDownloadComplete.episodeTitle}) else { return }
        print(episodeDownloadComplete.fileURL)
        self.episodes[index].fileURL = episodeDownloadComplete.fileURL
        
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        print(progress, title)
        
        //find the index using title
        guard let index = self.episodes.firstIndex(where: {$0.title == title}) else { return }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        cell.progressLabel.text = "\(Int(progress * 100))%"
        cell.progressLabel.isHidden = false 
        
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
        
        
    }
    
    //MARK:- Setup
    
    fileprivate func setupTableView() {
        
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        //register cell
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
    }
    
    
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Launch episode player")
        
        let episode = self.episodes[indexPath.row]
        
        if episode.fileURL != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
            
        } else {
            let ac = UIAlertController(title: "File URL not found", message: "Cannot find local file, play using stream url instead", preferredStyle: .actionSheet)
            
            ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
            }))
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            present(ac, animated: true)
        }
        
        
    }
    
    //swipe to delete
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction  = UIContextualAction(style: .destructive, title: "Delete") { (action, view, success) in
            
            let episode = self.episodes[indexPath.row]
            
            self.episodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaults.standard.deleteEpisode(episode: episode)
            
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        
        cell.episode = self.episodes[indexPath.row]
        return cell
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()

    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
