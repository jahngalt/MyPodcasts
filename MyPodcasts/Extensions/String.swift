//
//  String.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/23/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import Foundation


extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
