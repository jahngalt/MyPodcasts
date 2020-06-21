//
//  APIService.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/20/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import Foundation
import Alamofire


class APIService {
    
    
    //singleton
    static let shared = APIService()
    
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
