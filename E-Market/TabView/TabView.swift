//
//  TabViewController.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import Foundation
import UIKit

class TabViewController: UITabBarController {
    let sharedViewModel = HomesViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeVC.viewModel = sharedViewModel
        let basketVC = BasketViewController(nibName: "BasketViewController", bundle: nil)
        let favoritesVC = FavoritesViewController(nibName: "FavoritesViewController", bundle: nil)
        favoritesVC.viewModel = sharedViewModel
        let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        homeVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "house"), tag: 0)
        basketVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "cart"), tag: 1)
        favoritesVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "heart"), tag: 2)
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [homeVC, basketVC, favoritesVC, profileVC].map {
            UINavigationController(rootViewController: $0)
        }
        selectedIndex = 0
    }
}
