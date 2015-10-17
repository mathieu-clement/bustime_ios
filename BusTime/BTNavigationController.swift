//
//  BTNavigationController.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/16/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit

class BTNavigationController: UINavigationController {
    var currentStop : Stop? {
        didSet {
            mainViewController.refreshStop()
        }
    }
    
    var mainViewController : MainViewController! {
        get {
            for ctrl in childViewControllers {
                if ctrl is MainViewController {
                    return ctrl as! MainViewController
                }
            }
            return nil
        }
    }
}
