//
//  PodcastsSearchController.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/18/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit

class PodcastsSearchController: UITableViewController {
    
    let podcasts = [
        Podcast(name: "Hop hey", artistName: "Joy Leion"),
        Podcast(name: "Trala la", artistName: "Zolar Moran"),
    ]
    
    let cellId = "cellId"
    
    
    //implementing search bar
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //add search controller to navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false 
        
        //1. Register cell for a tableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let podcast = self.podcasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.name)\n\(podcast.artistName)"
        cell.textLabel?.numberOfLines = -1
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }
}
