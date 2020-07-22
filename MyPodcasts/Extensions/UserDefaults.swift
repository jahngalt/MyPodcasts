//
//  UserDefaults.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 7/14/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import Foundation


extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodesKey = "downloadedEpisodesKey"
    
    
    func downloadEpisode(episode: Episode) {
        
        do {
            var episodes = downloadedEpisodes()
            episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeErr {
            print(encodeErr)
        }
    }
    
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
    
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        } catch let err{
           print(err)
        }
        return []
    }
    
    
    func savedPodcast() -> [Podcast] {
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return []}
               
        do {
            guard let savedPodcasts = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastData) as? [Podcast] else { return []}
            return savedPodcasts
        }
    }
    
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcast()
        let filterPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: filterPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
        } catch let err {
            print("Error when trying to delete Podcast: ", err)
        }
    }
    
    
    func deleteEpisode(episode: Episode) {
        let savedEpisodes = downloadedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        }  catch let err {
            print("Error when trying to delete episode: ", err)
        }
        
    }
}
