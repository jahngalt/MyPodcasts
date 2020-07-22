//
//  APIService.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/20/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileURL: String, episodeTitle: String)
    
    //singleton
    static let shared = APIService()
    
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episode using Alamofire at streamURL: ", episode.streamURL)

        let downloadRequest = DownloadRequest.suggestedDownloadDestination()

        AF.download(episode.streamURL, to: downloadRequest)
            .downloadProgress { progress in
                //print(progress.fractionCompleted)
                //notify DownloadsController about progress
                NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
        }
            .response { response in
                
                //print(response.fileURL?.absoluteString)
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(fileURL: response.fileURL?.absoluteString  ?? "", episode.title)
                
                print(episodeDownloadComplete)
                
                
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                //update UserDefaults downloaded episodes with temp file
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) else { return }
                
                downloadedEpisodes[index].fileURL = response.fileURL?.absoluteString ?? ""
                
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
                } catch let err {
                    print("Failed to encode downloaded episodes with file url update: ", err)
                }
                
               
        }
        
    }
    
    
    func fetchEpisodes(feedURL: String, completionHandler: @escaping ([Episode]) -> ()) {
        let secureFeedUrl = feedURL.contains("https") ? feedURL : feedURL.replacingOccurrences(of: "http", with: "https")
        
        guard let url = URL(string: secureFeedUrl) else { return }
        //parse in background thread
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            // Parse asynchronously, not to block the UI.
            parser.parseAsync { (result) in
                switch result {
                case .success(let feed):
                    guard let feed = feed.rssFeed else { return }
                    let episodes = feed.toEpisodes()
                    completionHandler(episodes)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("searching for podcasts...")
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": searchText, "media": "podcast"]
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            
            if let err = dataResponse.error {
                print("Error to contact to Yahoo ", err)
                return
            }
            
            guard let data = dataResponse.data else { return }
            do {
                let searchResult = try JSONDecoder().decode(searchResults.self, from: data)
                print(searchResult.resultCount)
                completionHandler(searchResult.results)
//                self.podcasts = searchResult.results
//                self.tableView.reloadData()
                
            } catch let err {
                print("Failed to decode ", err)
            }
        }
        
        //AF.request(url, method: .get, parameters: parameters, encoder: URLEncoding.default, headers: nil)
    }
    
    struct searchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
