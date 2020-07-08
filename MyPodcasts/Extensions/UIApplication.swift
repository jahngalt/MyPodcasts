//
//  UIApplication.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 7/8/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit



extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        //UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController as? MainTabBarController
        
        return shared.windows.filter { $0.isKeyWindow }.first?.rootViewController as?  MainTabBarController
    }
}
