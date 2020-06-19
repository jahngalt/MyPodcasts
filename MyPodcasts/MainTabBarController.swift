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
    }
    
    
    //MARK:-  Setup Functions
    
    func setupViewControllers() {
        viewControllers =  [
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
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
            tabBar.standardAppearance = appearance
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
