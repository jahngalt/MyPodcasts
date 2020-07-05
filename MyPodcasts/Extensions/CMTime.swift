//
//  CMTime.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/30/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import AVKit

extension CMTime {
    
    
    func toDisplayString() -> String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds % (60 * 60) / 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
}
