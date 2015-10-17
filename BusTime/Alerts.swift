//
//  Alerts.swift
//  BusTime
//
//  Created by Mathieu Clement on 10/17/15.
//  Copyright © 2015 Mathieu Clement. All rights reserved.
//

import UIKit

public class Alerts {
    
    var viewController : UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        LOG.verbose("Constructor called")
    }
    
    public func displayNoLocation(onRetry onRetry: ()->Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "Location not found",
            message: "Verify GPS is on and you allowed BusTime to use it in the system preferences.",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(
            title: "Retry",
            style: .Default,
            handler: { (action) -> Void in
                onRetry()
        }))
        alert.addAction(UIAlertAction(
            title: "Quit",
            style: .Destructive,
            handler: { (alert) -> Void in
                exit(0)
        }))
        displayAlert(alert)
        return alert
    }
    
    func displayAlert(alert: UIAlertController) {
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}