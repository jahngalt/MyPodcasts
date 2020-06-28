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

class APIService {
    
    
    //singleton
    static let shared = APIService()
    
    
    func fetchEpisodes(feedURL: String, completionHandler: @escaping ([Episode]) -> ()) {
        let secureFeedUrl = feedURL.contains("https") ? feedURL : feedURL.replacingOccurrences(of: "http", with: "https")
        
        guard let url = URL(string: secureFeedUrl) else { return }
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
