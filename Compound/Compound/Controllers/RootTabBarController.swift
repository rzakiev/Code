//
//  RootTabBarController.swift
//  Compound
//
//  Created by robert on 03/10/2018.
//  Copyright © 2018 Robert Zakiev. All rights reserved.
//

import UIKit
import CoreData

class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.accessibilityIdentifier = "RootTabBar" //for UI tests
        BiometricAuthentication.performBiometricAuthentication()
    }
}
