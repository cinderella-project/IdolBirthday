//
//  RootViewController.swift
//  App iOS
//
//  Created by user on 2020/07/27.
//

import UIKit

class RootViewController: UISplitViewController {
    override var displayMode: UISplitViewController.DisplayMode {
        .oneBesideSecondary
    }
    
    override func viewDidLoad() {
        let navVC = UINavigationController(rootViewController: IdolListViewController())
        navVC.navigationBar.prefersLargeTitles = true
        viewControllers = [
             navVC,
        ]
        preferredDisplayMode = .oneBesideSecondary
    }
}
