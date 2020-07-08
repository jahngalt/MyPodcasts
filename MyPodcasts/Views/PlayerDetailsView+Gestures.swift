//
//  PlayerDetailsView+Gestures.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 7/8/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit


extension PlayerDetailsView {
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
           
           if gesture.state == .changed {
               handlePanChange(gesture: gesture)
           } else if gesture.state == .ended {
               handlePanEnded(gesture: gesture)
           }
       }
    
    
    func handlePanChange(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self.superview)
        let translation = gesture.translation(in: superview)
        
        print("Ended: ", velocity.y)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
                
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        })
    }
    
    
    @objc func handleTapMaximize() {
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
    }
    
}
