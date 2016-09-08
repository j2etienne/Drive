//
//  SettingsTabBarController.swift
//  Drive
//
//  Created by Martin Normark on 08/09/16.
//  Copyright © 2016 Milkshake Software. All rights reserved.
//

import UIKit

class SettingsTabBarController: UITabBarController {
    
    @IBAction func dismissButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}