//
//  MainTabBarController.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/12/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewControllers()
        setupPlayerDetailsView()
    }
    

    @objc func minimizePlayerDetails() {
        
        maximizedTopAnchorConstraint.isActive = false
        //minimizedTopAnchorConstraint.constant = -64
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            //self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            //
            //self.tabBar.frame = frame.offsetBy(dx: 0, dy: 100)
            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
        })
    }
    
    
    func maximizePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
       
        
        
        bottomAnchorConstraint.constant = 0
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        playerDetailsView.playlistEpisodes = playlistEpisodes
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            let frame = self.tabBar.frame
            
            //CGAffineTranform not working correct in ios13
            self.tabBar.frame = frame.offsetBy(dx: 0, dy: 100)
            //self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailsView.maximizedStackView.alpha = 1
            self.playerDetailsView.miniPlayerView.alpha = 0
        })
        
    }
    
    //MARK:-  Setup Functions
    let playerDetailsView = PlayerDetailsView.initFromNib()
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    fileprivate func setupPlayerDetailsView() {
        print("Setting up PlayerDetailsView")
        
        //use autolayout

        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        //enables autolayout
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        
        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        bottomAnchorConstraint.isActive = true
        
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        //        minimizedTopAnchorConstraint.isActive = true
        
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        //
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setupViewControllers() {
        
        let layout = UICollectionViewFlowLayout()
        let favoritesController = FavoritesController(collectionViewLayout: layout)
        
        
        viewControllers =  [
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(with: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    func setupUI() {
        
        //Customization  NavBar
        if #available(iOS 13.0, *) {
            UINavigationBar.appearance().prefersLargeTitles = true
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            
            
            UINavigationBar.appearance().tintColor = .purple
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = .purple
            UINavigationBar.appearance().isTranslucent = false
        }
        
        //Customization  TabBar
        if #available(iOS 13, *) {
            let appearance = self.tabBar.standardAppearance.copy()
            appearance.configureWithTransparentBackground()
            tabBar.isTranslucent = false
            tabBar.standardAppearance = appearance
            tabBar.backgroundColor = .white
            tabBar.tintColor = .purple
        } else {
            tabBar.tintColor = .purple
            tabBar.barTintColor = UIColor.clear
        }
    }
    
    
    //MARK:- Helper Functions
    fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        //navController.navigationBar.prefersLargeTitles = true
        //navController.navigationBar.barTintColor = .black
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        
        return navController
    }
    
}
